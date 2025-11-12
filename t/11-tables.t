#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 4;
use MarkdownParser;

my $parser = MarkdownParser->new();

my $input = <<'EOF';
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
EOF

my $expected = <<'EOF';
<table>
<tr>
<th>Header 1</th>
<th>Header 2</th>
</tr>
<tr>
<td>Cell 1</td>
<td>Cell 2</td>
</tr>
<tr>
<td>Cell 3</td>
<td>Cell 4</td>
</tr>
</table>
EOF

is( $parser->parse($input), $expected, "Basic table" );

$input = <<'EOF';
| Name | Age |
|------|-----|
| John | 25  |
| Jane | 30  |
EOF

$expected = <<'EOF';
<table>
<tr>
<th>Name</th>
<th>Age</th>
</tr>
<tr>
<td>John</td>
<td>25</td>
</tr>
<tr>
<td>Jane</td>
<td>30</td>
</tr>
</table>
EOF

is( $parser->parse($input), $expected, "Table with different content" );

$input = <<'EOF';
# Title

| Col1 | Col2 |
|------|------|
| Data | Info |

More text.
EOF

$expected = <<'EOF';
<h1>Title</h1>
<table>
<tr>
<th>Col1</th>
<th>Col2</th>
</tr>
<tr>
<td>Data</td>
<td>Info</td>
</tr>
</table>
<p>More text.</p>
EOF

is( $parser->parse($input), $expected, "Table with surrounding content" );

$input = <<'EOF';
| **Bold** | *Italic* | [Link](url) |
|----------|----------|-------------|
| Text     | More     | Info        |
EOF

$expected = <<'EOF';
<table>
<tr>
<th><strong>Bold</strong></th>
<th><em>Italic</em></th>
<th><a href="url">Link</a></th>
</tr>
<tr>
<td>Text</td>
<td>More</td>
<td>Info</td>
</tr>
</table>
EOF

is( $parser->parse($input), $expected, "Table with inline formatting" );

