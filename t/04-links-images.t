#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 17;
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
is(
    $parser->parse("[Click me](javascript&#x3A;alert('XSS'))"),
    "<p>Click me</p>\n",
    "Encoded JavaScript protocol blocked in links"
);
is( $parser->parse("![Image](javascript:alert('XSS'))"),
    "<p>Image</p>\n", "JavaScript protocol blocked in images" );
is( $parser->parse("![Image](file:///etc/passwd)"),
    "<p>Image</p>\n", "File protocol blocked in images" );
is( $parser->parse("![Image](javascript:%2f%2falert('XSS'))"),
    "<p>Image</p>\n", "Encoded JavaScript protocol blocked in images" );
is(
    $parser->parse("[Click me](javascript&#10;:alert('XSS'))"),
    "<p>Click me</p>\n",
    "JavaScript protocol with numeric newline entity blocked"
);
is(
    $parser->parse("[Click me](java&#x0D;script:alert('XSS'))"),
    "<p>Click me</p>\n",
    "JavaScript protocol with hex carriage return entity blocked"
);
is(
    $parser->parse("[Click me](javascr&#x69;pt%3Aalert('XSS'))"),
    "<p>Click me</p>\n",
    "Mixed encoded JavaScript protocol blocked"
);
is(
    $parser->parse("![Image](java&#9;script:alert('XSS'))"),
    "<p>Image</p>\n",
    "JavaScript protocol with tab entity blocked in images"
);
is(
    $parser->parse("[email](mailto:user\@example.com)"),
    "<p><a href=\"mailto:user\@example.com\">email</a></p>\n",
    "Mailto protocol remains allowed"
);
is(
    $parser->parse("[safe](%68%74%74%70%73://example.com/path)"),
    "<p><a href=\"%68%74%74%70%73://example.com/path\">safe</a></p>\n",
    "Percent-encoded https scheme remains allowed"
);
is(
    $parser->parse("[relative](/docs/java script:guide)"),
    "<p><a href=\"/docs/java script:guide\">relative</a></p>\n",
    "Relative URL with colon in path remains allowed"
);
