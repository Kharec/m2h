#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 11;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("**bold text**"),
    "<p><strong>bold text</strong></p>\n",
    "Bold with **"
);
is(
    $parser->parse("__bold text__"),
    "<p><strong>bold text</strong></p>\n",
    "Bold with __"
);
is(
    $parser->parse("*italic text*"),
    "<p><em>italic text</em></p>\n",
    "Italic with *"
);
is(
    $parser->parse("_italic text_"),
    "<p><em>italic text</em></p>\n",
    "Italic with _"
);
is(
    $parser->parse("**bold** and *italic*"),
    "<p><strong>bold</strong> and <em>italic</em></p>\n",
    "Bold and italic together"
);
is(
    $parser->parse("Text with **bold** in middle"),
    "<p>Text with <strong>bold</strong> in middle</p>\n",
    "Bold in middle of text"
);
is(
    $parser->parse("Text with *italic* in middle"),
    "<p>Text with <em>italic</em> in middle</p>\n",
    "Italic in middle of text"
);
is(
    $parser->parse("**bold** *italic* **bold again**"),
"<p><strong>bold</strong> <em>italic</em> <strong>bold again</strong></p>\n",
    "Multiple formatting"
);
is(
    $parser->parse("***bold text***"),
    "<p><strong>bold text</strong></p>\n",
    "Bold with ***"
);
is(
    $parser->parse("**bold *italic* bold**"),
    "<p><strong>bold <em>italic</em> bold</strong></p>\n",
    "Nested formatting"
);
is(
    $parser->parse("___bold text___"),
    "<p><strong>bold text</strong></p>\n",
    "Bold with ___"
);

