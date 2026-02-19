#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("`inline code`"),
    "<p><code>inline code</code></p>\n",
    "Inline code"
);
is(
    $parser->parse("Text with `code` in it"),
    "<p>Text with <code>code</code> in it</p>\n",
    "Inline code in text"
);
is(
    $parser->parse("```\ncode block\n```"),
    "<pre><code>\ncode block\n</code></pre>\n",
    "Code block"
);
is(
    $parser->parse("```\nline 1\nline 2\nline 3\n```"),
    "<pre><code>\nline 1\nline 2\nline 3\n</code></pre>\n",
    "Multi-line code block"
);
is(
    $parser->parse("```\n```"),
    "<pre><code>\n</code></pre>\n",
    "Empty code block"
);
is(
    $parser->parse("```\nunterminated"),
    "<pre><code>\nunterminated\n</code></pre>\n",
    "Unclosed code block is closed at EOF"
);
