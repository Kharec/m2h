package MarkdownParser;

use strict;
use warnings;

our $VERSION = '1.0';

my %CLOSING_TAGS = (
    ulist      => "</ul>",
    olist      => "</ol>",
    blockquote => "</blockquote>",
    table      => "</table>",
);

sub new {
    my $class = shift;
    return bless {
        state  => 'paragraph',
        output => '',
        lines  => [],
    }, $class;
}

sub _init_handlers {
    my $self = shift;
    $self->{handlers} = {
        code_block_start => sub {
            my ( $self, $line_type ) = @_;
            $self->transition_to_state('code_block');
            $self->{output} .= "<pre><code>\n";
        },
        header => sub {
            my ( $self, $line_type ) = @_;
            $self->transition_to_state('paragraph');
            my $level = length( $line_type->{match} );
            $self->{output} .=
                "<h$level>"
              . $self->parse_inline( $line_type->{text} )
              . "</h$level>\n";
        },
        blockquote => sub {
            my ( $self, $line_type ) = @_;
            $self->handle_list_or_blockquote( 'blockquote', '<blockquote>',
                $line_type->{text} );
        },
        ulist => sub {
            my ( $self, $line_type ) = @_;
            $self->handle_list_or_blockquote( 'ulist', '<ul>',
                $line_type->{text} );
        },
        olist => sub {
            my ( $self, $line_type ) = @_;
            $self->handle_list_or_blockquote( 'olist', '<ol>',
                $line_type->{text} );
        },
        horizontal_rule => sub {
            my ( $self, $line_type ) = @_;
            $self->transition_to_state('paragraph');
            $self->{output} .= "<hr>\n";
        },
        table_row => sub {
            my ( $self, $line_type ) = @_;
            if ( $self->{state} ne 'table' ) {
                $self->transition_to_state('table');
                $self->{output} .= "<table>\n";
                $self->{table_is_header} = 1;
            }
            $self->handle_table_row( $line_type->{text} );
        },
        table_separator => sub {
            my ( $self, $line_type ) = @_;
            if ( $self->{state} eq 'table' ) {
                $self->{table_is_header} = 0;
            }
        },
        blank => sub {
            my ( $self, $line_type ) = @_;
            $self->finish_state();
        },
    };
}

sub parse {
    my ( $self, $text ) = @_;
    $self->{output} = '';
    $self->{lines}  = [ split /\r?\n/, $text ];
    $self->{state}  = 'paragraph';
    delete $self->{paragraph_buffer};
    $self->_init_handlers();

    foreach my $line ( @{ $self->{lines} } ) {
        $self->process_line($line);
    }

    $self->finish_state();
    return $self->{output};
}

sub process_line {
    my ( $self, $line ) = @_;

    if ( $self->{state} eq 'code_block' ) {
        $self->handle_code_block_line($line);
        return;
    }

    if ( $self->{state} eq 'table' ) {
        $self->handle_table_line($line);
        return;
    }

    my $line_type = $self->detect_line_type($line);
    my $handler   = $self->{handlers}->{ $line_type->{type} };
    if ($handler) {
        $handler->( $self, $line_type );
    }
    else {
        $self->handle_paragraph_line($line);
    }
}

sub detect_line_type {
    my ( $self, $line ) = @_;

    return { type => 'code_block_start' } if $line =~ /^```/;

    if ( $line =~ /^(#{1,6})\s+(.+)/ ) {
        return { type => 'header', match => $1, text => $2 };
    }

    if ( $line =~ /^>\s+(.+)/ ) {
        return { type => 'blockquote', text => $1 };
    }

    if ( $line =~ /^[-*+]\s+(.+)/ ) {
        return { type => 'ulist', text => $1 };
    }

    if ( $line =~ /^\d+\.\s+(.+)/ ) {
        return { type => 'olist', text => $1 };
    }

    return { type => 'horizontal_rule' } if $line =~ /^[-*_]{3,}$/;
    return { type => 'blank' }           if $line =~ /^\s*$/;

    if ( $line =~ /^\|.+\|/ ) {
        if ( $line =~ /^\|[\s\-:]*\|/ ) {
            return { type => 'table_separator' };
        }
        return { type => 'table_row', text => $line };
    }

    return { type => 'paragraph' };
}

sub transition_to_state {
    my ( $self, $new_state ) = @_;

    if ( $self->{state} ne $new_state ) {
        $self->finish_state();
        $self->{state} = $new_state;
    }
}

sub handle_code_block_line {
    my ( $self, $line ) = @_;

    if ( $line =~ /^```/ ) {
        $self->{output} .= "</code></pre>\n";
        $self->transition_to_state('paragraph');
    }
    else {
        $self->{output} .= escape_html($line) . "\n";
    }
}

sub handle_list_or_blockquote {
    my ( $self, $target_state, $open_tag, $text ) = @_;

    if ( $self->{state} ne $target_state ) {
        $self->transition_to_state($target_state);
        $self->{output} .= "$open_tag\n";
    }

    my $inner_tag = $target_state eq 'blockquote' ? 'p' : 'li';
    $self->{output} .=
      "<$inner_tag>" . $self->parse_inline($text) . "</$inner_tag>\n";
}

sub handle_paragraph_line {
    my ( $self, $line ) = @_;

    if ( $self->{state} ne 'paragraph' ) {
        $self->transition_to_state('paragraph');
    }

    $self->{paragraph_buffer} //= '';
    $self->{paragraph_buffer} .=
      ( $self->{paragraph_buffer} ? ' ' : '' ) . $line;
}

sub handle_table_line {
    my ( $self, $line ) = @_;

    my $line_type = $self->detect_line_type($line);

    if ( $line_type->{type} eq 'table_separator' ) {
        $self->{table_is_header} = 0;
        return;
    }

    if ( $line_type->{type} eq 'table_row' ) {
        $self->handle_table_row( $line_type->{text} );
        return;
    }

    $self->finish_state();
    $self->process_line($line);
}

sub handle_table_row {
    my ( $self, $row ) = @_;

    $row =~ s/^\|\s*//;
    $row =~ s/\s*\|$//;

    my @cells = map { s/^\s+//; s/\s+$//; $_ } split( /\|/, $row );

    $self->{output} .= "<tr>\n";
    for my $cell (@cells) {
        my $tag = $self->{table_is_header} ? 'th' : 'td';
        $self->{output} .= "<$tag>" . $self->parse_inline($cell) . "</$tag>\n";
    }
    $self->{output} .= "</tr>\n";
}

sub finish_state {
    my $self = shift;

    if (   $self->{state} eq 'paragraph'
        && exists $self->{paragraph_buffer}
        && $self->{paragraph_buffer} =~ /\S/ )
    {
        $self->{output} .=
          "<p>" . $self->parse_inline( $self->{paragraph_buffer} ) . "</p>\n";
        delete $self->{paragraph_buffer};
    }
    elsif ( exists $CLOSING_TAGS{ $self->{state} } ) {
        $self->{output} .= $CLOSING_TAGS{ $self->{state} } . "\n";
    }

    $self->{state} = 'paragraph';
}

sub parse_inline {
    my ( $self, $text ) = @_;

    my @placeholders;
    my $placeholder_idx = 0;

    $text =~ s/`([^`]+)`/sub {
        my $idx = $placeholder_idx++;
        push @placeholders, { type => 'code', content => $1 };
        return "\x01$idx\x02";
    }->()/ge;

    $text =~ s/!\[([^\]]*)\]\(((?:[^()]|\([^()]*\))+)\)/sub {
        my $idx = $placeholder_idx++;
        push @placeholders, { type => 'image', alt => $1, url => $2 };
        return "\x01$idx\x02";
    }->()/ge;

    $text =~ s/\[([^\]]+)\]\(((?:[^()]|\([^()]*\))+)\)/sub {
        my $idx = $placeholder_idx++;
        push @placeholders, { type => 'link', text => $1, url => $2 };
        return "\x01$idx\x02";
    }->()/ge;

    my @bold_parts;
    my $bold_idx = 0;
    $text =~ s/\*\*\*((?:[^*]|\*(?!\*))+)\*\*\*/sub {
        my $idx = $bold_idx++;
        push @bold_parts, { type => 'bold', content => $1 };
        return "\x01B$idx\x02";
    }->()/ge;
    $text =~ s/\*\*((?:[^*]|\*(?!\*))+)\*\*/sub {
        my $idx = $bold_idx++;
        push @bold_parts, { type => 'bold', content => $1 };
        return "\x01B$idx\x02";
    }->()/ge;
    $text =~ s/___((?:[^_]|_(?!_))+?)___/<strong>$1<\/strong>/g;
    $text =~ s/__((?:[^_]|_(?!_))+?)__/<strong>$1<\/strong>/g;

    my @italic_parts;
    my $italic_idx = 0;
    $text =~ s/\*([^*]+)\*/sub {
        my $idx = $italic_idx++;
        push @italic_parts, { type => 'italic', content => $1 };
        return "\x01I$idx\x02";
    }->()/ge;
    $text =~ s/_([^_]+)_/sub {
        my $idx = $italic_idx++;
        push @italic_parts, { type => 'italic', content => $1 };
        return "\x01I$idx\x02";
    }->()/ge;

    for ( my $i = 0 ; $i < @bold_parts ; $i++ ) {
        my $part    = $bold_parts[$i];
        my $content = $part->{content};
        $content =~ s/\*([^*]+)\*/sub {
            my $idx = $italic_idx++;
            push @italic_parts, { type => 'italic', content => $1 };
            return "\x01I$idx\x02";
        }->()/ge;
        $content =~ s/_([^_]+)_/sub {
            my $idx = $italic_idx++;
            push @italic_parts, { type => 'italic', content => $1 };
            return "\x01I$idx\x02";
        }->()/ge;
        $text =~ s/\x01B$i\x02/<strong>$content<\/strong>/;
    }

    my @format_parts;
    my $format_idx = 0;
    $text =~ s/<(strong|em)>(.*?)<\/(strong|em)>/sub {
        my $idx = $format_idx++;
        push @format_parts, { tag => $1, content => $2 };
        return "\x01F$idx\x02";
    }->()/gse;

    $text = escape_html($text);

    for ( my $i = 0 ; $i < @format_parts ; $i++ ) {
        my $part = $format_parts[$i];
        $text =~
s/\x01F$i\x02/<$part->{tag}>@{[escape_html($part->{content})]}<\/$part->{tag}>/;
    }

    for ( my $i = 0 ; $i < @italic_parts ; $i++ ) {
        my $part = $italic_parts[$i];
        $text =~ s/\x01I$i\x02/<em>@{[escape_html($part->{content})]}<\/em>/;
    }

    for ( my $i = 0 ; $i < @placeholders ; $i++ ) {
        my $part = $placeholders[$i];
        my $replacement;
        if ( $part->{type} eq 'code' ) {
            $replacement =
              "<code>" . escape_html( $part->{content} ) . "</code>";
        }
        elsif ( $part->{type} eq 'image' ) {
            if ( is_safe_url( $part->{url} ) ) {
                $replacement =
                    "<img src=\""
                  . escape_html( $part->{url} )
                  . "\" alt=\""
                  . escape_html( $part->{alt} ) . "\">";
            }
            else {
                $replacement = escape_html( $part->{alt} );
            }
        }
        elsif ( $part->{type} eq 'link' ) {
            if ( is_safe_url( $part->{url} ) ) {
                $replacement =
                    "<a href=\""
                  . escape_html( $part->{url} ) . "\">"
                  . escape_html( $part->{text} ) . "</a>";
            }
            else {
                $replacement = escape_html( $part->{text} );
            }
        }
        $text =~ s/\x01$i\x02/$replacement/;
    }

    return $text;
}

sub is_safe_url {
    my ($url) = @_;
    return 0 if $url =~ /^\s*javascript:/i;
    return 0 if $url =~ /^\s*data:/i;
    return 0 if $url =~ /^\s*vbscript:/i;
    return 0 if $url =~ /^\s*file:/i;
    return 1;
}

sub escape_html {
    my ($text) = @_;
    $text =~ s/&/&amp;/g;
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    $text =~ s/"/&quot;/g;
    $text =~ s/'/&#39;/g;
    return $text;
}

1;

