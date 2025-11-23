#!perl -w
use strict;
use Getopt::Long;
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

sub read_input {
    my ($file) = @_;
    local $/;
    if ($file) {
        open my $fh, '<', $file
          or die "Error: Cannot open file: $file\n";
        my $content = <$fh>;
        close $fh;
        return $content;
    }
    return <STDIN>;
}

my $output_file;
my $help = 0;
my $version = 0;

GetOptions(
    'help|h'     => \$help,
    'version|v'  => \$version,
    'output|o=s' => \$output_file,
) or show_help();

show_help() if $help;
show_version() if $version;

my $input_file = shift @ARGV;

my $input = read_input($input_file);

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
