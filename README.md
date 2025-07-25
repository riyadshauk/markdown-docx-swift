# MarkdownToDocx

A Swift library for converting Markdown documents to DOCX format using Apple's Swift Markdown parser.

## Features

- ✅ **Complete Markdown Support**: Headings, paragraphs, lists, code blocks, tables, blockquotes, and more
- ✅ **Proper DOCX Styling**: Generates properly formatted DOCX files with correct styling
- ✅ **Link Support**: Converts Markdown links to plain text (no styling, URLs ignored)
- ✅ **File Conversion**: Convert both strings and files
- ✅ **Comprehensive Testing**: Full test coverage with 14+ test cases
- ✅ **iOS Compatible**: Works seamlessly with iOS apps

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/riyadshauk/markdown-docx-swift.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. Go to File → Add Package Dependencies
2. Enter: `https://github.com/riyadshauk/markdown-docx-swift.git`
3. Click Add Package

## Usage

### Basic Conversion

```swift
import MarkdownToDocx

let converter = MarkdownToDocxConverter()
let markdown = "# Hello World\n\nThis is **bold** text."
let docxData = try converter.convert(markdown: markdown)
```

### Convert from File

```swift
let fileURL = URL(fileURLWithPath: "/path/to/document.md")
let docxData = try converter.convert(markdownFile: fileURL)
```

### Save to File

```swift
let docxData = try converter.convert(markdown: markdown)
try docxData.write(to: URL(fileURLWithPath: "output.docx"))
```

### Link Behavior

Links in Markdown are converted to plain text in the DOCX file. The URL is ignored and only the link text is preserved:

```swift
// Input: [Apple](https://www.apple.com)
// Output: "Apple" (plain text, no styling)
```

This is currently a usability bug – happy to accept PRs to fix any bugs!

## Supported Markdown Features

| Feature | Support |
|---------|---------|
| Headings (H1-H3) | ✅ |
| Paragraphs | ✅ |
| Bold/Italic | ✅ |
| Code (inline & blocks) | ✅ |
| Lists (bullet & numbered) | ✅ |
| Tables | ✅ |
| Blockquotes | ✅ |
| Horizontal Rules | ✅ |
| Links | ✅ (converted to plain text, URLs ignored) |
| Images | ✅ (placeholder support) |

## Example

```swift
let markdown = """
# Sample Document

This is a **bold** and *italic* paragraph.

## Features

- Bullet point 1
- Bullet point 2

1. Numbered item 1
2. Numbered item 2

> This is a blockquote

```swift
let code = "This is a code block"
```

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |

[Link to Apple](https://www.apple.com) <!-- Shows as "Link to Apple" in plain text -->
"""

let converter = MarkdownToDocxConverter()
let docxData = try converter.convert(markdown: markdown)
```

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- [Swift Markdown](https://github.com/swiftlang/swift-markdown) - Apple's Markdown parser
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - ZIP file handling

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Issues

If you encounter any issues, please [open an issue](https://github.com/riyadshauk/markdown-docx-swift/issues) on GitHub.