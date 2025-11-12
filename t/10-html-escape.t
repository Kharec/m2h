#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 4;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("Text with <tag>"),
    "<p>Text with &lt;tag&gt;</p>\n",
    "HTML tags escaped"
);
is(
    $parser->parse("Text with & symbol"),
    "<p>Text with &amp; symbol</p>\n",
    "Ampersand escaped"
);
is(
    $parser->parse('Text with "quotes"'),
    "<p>Text with &quot;quotes&quot;</p>\n",
    "Quotes escaped"
);
is(
    $parser->parse("Text with 'apostrophe'"),
    "<p>Text with &#39;apostrophe&#39;</p>\n",
    "Apostrophe escaped"
);

