# m2h - Markdown to HTML Converter

A lightweight, pure Perl markdown to HTML converter that uses a state machine for parsing.

## Features

- Pure Perl implementation - no external dependencies
- State machine-based parsing for efficient and maintainable code
- Converts standard markdown syntax to HTML
- Secure HTML output, especially against XSS or file protocols 
- Fast and lightweight

## Requirements

- Perl 5.42 or higher

## Installation

No installation required. Simply download the script and make it executable:

```bash
chmod +x m2h.pl
```

## Usage

### Basic Usage

Convert a markdown file to HTML:

```bash
perl -Ilibm2h.pl input.md > output.html
```

Or read from stdin:

```bash
cat input.md | perl -Ilib m2h.pl > output.html
```

### Command Line Options

```
m2h [options] [file]

Options:
    -h, --help      Show this help message
    -v, --version   Show version information
    -o, --output    Specify output file (default: stdout)
```

Install the script using:

```bash
make install
```

Run the test suite using:

```bash
make test
```

## Supported Markdown Features

- Headers (H1-H6)
- Paragraphs
- Bold and italic text
- Links
- Images
- Lists (ordered and unordered)
- Code blocks and inline code
- Blockquotes
- Horizontal rules
- Tables

## How It Works

m2h uses a state machine to parse markdown text. The parser transitions between different states (e.g., paragraph, code block, list) based on the input it encounters, allowing for efficient and accurate parsing of markdown syntax.

## Example

### Input (markdown)

```markdown
# Hello World

This is a **bold** and _italic_ example.

- Item 1
- Item 2
- Item 3
```

### Output (HTML)

```html
<h1>Hello World</h1>
<p>This is a <strong>bold</strong> and <em>italic</em> example.</p>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ul>
```

## License

MIT License, see [LICENSE](LICENSE) for details.
