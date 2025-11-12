#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;
use MarkdownParser;

my $parser = MarkdownParser->new();

is( $parser->parse("# Header 1"),      "<h1>Header 1</h1>\n", "H1 header" );
is( $parser->parse("## Header 2"),     "<h2>Header 2</h2>\n", "H2 header" );
is( $parser->parse("### Header 3"),    "<h3>Header 3</h3>\n", "H3 header" );
is( $parser->parse("#### Header 4"),   "<h4>Header 4</h4>\n", "H4 header" );
is( $parser->parse("##### Header 5"),  "<h5>Header 5</h5>\n", "H5 header" );
is( $parser->parse("###### Header 6"), "<h6>Header 6</h6>\n", "H6 header" );

