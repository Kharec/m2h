#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 3;
use MarkdownParser;

my $parser = MarkdownParser->new();

is( $parser->parse("---"), "<hr>\n", "Horizontal rule with ---" );
is( $parser->parse("***"), "<hr>\n", "Horizontal rule with ***" );
is( $parser->parse("___"), "<hr>\n", "Horizontal rule with ___" );

