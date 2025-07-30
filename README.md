# MarkdownToDocx

A Swift library for converting Markdown documents to DOCX format using Apple's Swift Markdown parser.

This library is majorly a WIP / initial iteration, and could use a lot of improvements and iteration, which I don't currently plan on doing. Consider this more as a starting point for something greater!

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

````swift
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
````

## Testing

The library includes comprehensive test coverage with multiple test suites and debug tools.

### Running Tests

#### All Tests
```bash
swift test
```

#### Specific Test Suites
```bash
# Run only the main library tests
swift test --filter MarkdownToDocxTests

# Run only the resume-specific tests
swift test --filter ResumeMarkdownTests

# Run a specific test method
swift test --filter testBasicConversion
```

#### Test Coverage
- **Unit Tests** (`MarkdownToDocxTests`): 14 tests covering all core functionality
- **Resume Tests** (`ResumeMarkdownTests`): 3 tests for complex resume-style documents
- **Total**: 17 tests with comprehensive coverage

### Debug Scripts

The library includes several debug tools to help you inspect and troubleshoot DOCX generation.

#### Basic Debug Script
```bash
# Generate a sample DOCX and inspect its structure
swift run debug-docx
```

This script:
- Creates a test DOCX with various markdown elements
- Saves it to your Documents folder
- Extracts and displays the XML structure
- Shows hyperlink handling and relationships

#### Resume Debug Script
```bash
# Generate a full resume DOCX for inspection
swift run debug-resume
```

This script:
- Creates a complete resume DOCX from your markdown
- Saves it to your Desktop as `Riyad_Shauk_Resume.docx`
- Creates a backup in Documents folder
- Provides detailed analysis of the generated content
- Shows paragraph counts, heading counts, and formatting

#### Debug Output Analysis

The debug scripts provide detailed information:

```
=== ANALYSIS ===
Contains <w:b/> (bold): true
Contains <w:i/> (italic): true
Paragraph count: 43
H1 headings: 1
H2 headings: 5
Bullet points: 28
```

### Manual Testing

#### Generate DOCX from Custom Markdown
```swift
import MarkdownToDocx

let markdown = """
# My Document

This is a **test** document with *formatting*.

## Features
- Bullet points
- [Links](https://example.com)
- Code blocks
"""

let converter = MarkdownToDocxConverter()
let docxData = try converter.convert(markdown: markdown)

// Save to file
try docxData.write(to: URL(fileURLWithPath: "output.docx"))
```

#### Inspect DOCX Structure
```swift
import ZIPFoundation

// Extract and examine the XML structure
let archive = try Archive(url: docxURL, accessMode: .read)
if let documentEntry = archive["word/document.xml"] {
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("document.xml")
    try archive.extract(documentEntry, to: tempURL)
    let content = try String(contentsOf: tempURL, encoding: .utf8)
    print(content)
}
```

### Troubleshooting

#### Common Test Issues
1. **Build Errors**: Ensure you have the latest Xcode and Swift version
2. **Missing Dependencies**: Run `swift package resolve` to fetch dependencies
3. **Permission Issues**: Check file permissions for debug script output

#### Debug Tips
- Use `swift run debug-resume` to generate a real DOCX file you can open
- Check the XML output for formatting issues
- Compare generated files with manually created DOCX files
- Use different word processors to test compatibility

#### Performance Testing
```bash
# Run performance tests
swift test --filter testResumeMarkdownPerformance
```

The performance test measures conversion speed and file size for complex documents.

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