#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 3;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("> Quote text"),
    "<blockquote>\n<p>Quote text</p>\n</blockquote>\n",
    "Simple blockquote"
);
is(
    $parser->parse("> First line\n> Second line"),
    "<blockquote>\n<p>First line</p>\n<p>Second line</p>\n</blockquote>\n",
    "Multi-line blockquote"
);
is(
    $parser->parse("> Quote with **bold**"),
    "<blockquote>\n<p>Quote with <strong>bold</strong></p>\n</blockquote>\n",
    "Blockquote with formatting"
);

