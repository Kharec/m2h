#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 3;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("Simple paragraph"),
    "<p>Simple paragraph</p>\n",
    "Single paragraph"
);
is(
    $parser->parse("First paragraph\n\nSecond paragraph"),
    "<p>First paragraph</p>\n<p>Second paragraph</p>\n",
    "Multiple paragraphs"
);
is(
    $parser->parse("Paragraph with\nmultiple lines"),
    "<p>Paragraph with multiple lines</p>\n",
    "Multi-line paragraph"
);

