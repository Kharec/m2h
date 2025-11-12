#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 4;
use MarkdownParser;

my $parser = MarkdownParser->new();

my $input = <<'EOF';
# Title

This is a paragraph with **bold** and *italic* text.

- List item 1
- List item 2

[Link](http://example.com)
EOF

my $expected = <<'EOF';
<h1>Title</h1>
<p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
<ul>
<li>List item 1</li>
<li>List item 2</li>
</ul>
<p><a href="http://example.com">Link</a></p>
EOF

is( $parser->parse($input), $expected, "Complex document" );

$input = <<'EOF';
## Section

Paragraph one.

> Blockquote here

Another paragraph.
EOF

$expected = <<'EOF';
<h2>Section</h2>
<p>Paragraph one.</p>
<blockquote>
<p>Blockquote here</p>
</blockquote>
<p>Another paragraph.</p>
EOF

is( $parser->parse($input), $expected, "Document with blockquote" );

$input = <<'EOF';
# Code Example

Here is some `inline code` and a code block:

```
function test() {
    return true;
}
```
EOF

$expected = <<'EOF';
<h1>Code Example</h1>
<p>Here is some <code>inline code</code> and a code block:</p>
<pre><code>
function test() {
    return true;
}
</code></pre>
EOF

is( $parser->parse($input), $expected, "Document with code" );

$input = <<'EOF';
# Header

Paragraph with [link](url) and ![image](img.png).

---

## Another Header
EOF

$expected = <<'EOF';
<h1>Header</h1>
<p>Paragraph with <a href="url">link</a> and <img src="img.png" alt="image">.</p>
<hr>
<h2>Another Header</h2>
EOF

is( $parser->parse($input),
    $expected, "Document with links, images, and horizontal rule" );

