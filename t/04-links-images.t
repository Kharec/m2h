#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 8;
use MarkdownParser;

my $parser = MarkdownParser->new();

is(
    $parser->parse("[link text](http://example.com)"),
    "<p><a href=\"http://example.com\">link text</a></p>\n",
    "Simple link"
);
is(
    $parser->parse("[link with spaces](https://example.com/path)"),
    "<p><a href=\"https://example.com/path\">link with spaces</a></p>\n",
    "Link with path"
);
is(
    $parser->parse("![alt text](image.png)"),
    "<p><img src=\"image.png\" alt=\"alt text\"></p>\n",
    "Simple image"
);
is(
    $parser->parse("![alt with spaces](http://example.com/image.jpg)"),
"<p><img src=\"http://example.com/image.jpg\" alt=\"alt with spaces\"></p>\n",
    "Image with URL"
);
is(
    $parser->parse("[Click me](javascript:alert('XSS'))"),
    "<p>Click me</p>\n",
    "JavaScript protocol blocked in links"
);
is(
    $parser->parse("[Click me](data:text/html,<script>alert('XSS')</script>)"),
    "<p>Click me</p>\n",
    "Data protocol blocked in links"
);
is( $parser->parse("![Image](javascript:alert('XSS'))"),
    "<p>Image</p>\n", "JavaScript protocol blocked in images" );
is( $parser->parse("![Image](file:///etc/passwd)"),
    "<p>Image</p>\n", "File protocol blocked in images" );

