#!perl -w
use strict;
use MarkdownParser;

sub show_help {
    print <<"EOF";
m2h - Markdown to HTML Converter

Usage: $0 [options] [file]

Options:
    -h, --help      Show this help message
    -v, --version   Show version information
    -o, --output    Specify output file (default: stdout)

If no file is specified, input is read from stdin.
EOF
    exit 0;
}

sub show_version {
    print "m2h version $MarkdownParser::VERSION\n";
    exit 0;
}

my $output_file;
my $input_file;

for ( my $i = 0 ; $i < @ARGV ; $i++ ) {
    my $arg = $ARGV[$i];
    if ( $arg eq '-h' || $arg eq '--help' ) {
        show_help();
    }
    elsif ( $arg eq '-v' || $arg eq '--version' ) {
        show_version();
    }
    elsif ( $arg eq '-o' || $arg eq '--output' ) {
        $output_file = $ARGV[ ++$i ]
          or die "Error: -o requires a filename\n";
    }
    elsif ( $arg =~ /^-/ ) {
        die "Error: Unknown option: $arg\n";
    }
    else {
        $input_file = $arg;
    }
}

my $input;
if ($input_file) {
    open my $fh, '<', $input_file
      or die "Error: Cannot open file: $input_file\n";
    local $/;
    $input = <$fh>;
    close $fh;
}
else {
    local $/;
    $input = <STDIN>;
}

my $output;
if ($output_file) {
    open $output, '>', $output_file
      or die "Error: Cannot write to file: $output_file\n";
}
else {
    $output = \*STDOUT;
}

my $parser = MarkdownParser->new();
print $output $parser->parse($input);

close $output if $output_file;
