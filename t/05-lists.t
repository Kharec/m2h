#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("- Item 1\n- Item 2\n- Item 3"),
    "<ul>\n<li>Item 1</li>\n<li>Item 2</li>\n<li>Item 3</li>\n</ul>\n",
    "Unordered list with -"
);
is(
    $parser->parse("* Item 1\n* Item 2"),
    "<ul>\n<li>Item 1</li>\n<li>Item 2</li>\n</ul>\n",
    "Unordered list with *"
);
is(
    $parser->parse("+ Item 1\n+ Item 2"),
    "<ul>\n<li>Item 1</li>\n<li>Item 2</li>\n</ul>\n",
    "Unordered list with +"
);
is(
    $parser->parse("1. First item\n2. Second item\n3. Third item"),
"<ol>\n<li>First item</li>\n<li>Second item</li>\n<li>Third item</li>\n</ol>\n",
    "Ordered list"
);
is(
    $parser->parse("- Item 1\n\n- Item 2"),
    "<ul>\n<li>Item 1</li>\n</ul>\n<ul>\n<li>Item 2</li>\n</ul>\n",
    "Multiple list blocks"
);
is(
    $parser->parse("- **Bold item**\n- *Italic item*"),
"<ul>\n<li><strong>Bold item</strong></li>\n<li><em>Italic item</em></li>\n</ul>\n",
    "List items with formatting"
);

