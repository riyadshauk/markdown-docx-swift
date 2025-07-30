# MarkdownToDocx

A Swift library for converting Markdown documents to Microsoft Word (.docx) format. This library uses [Swift Markdown](https://github.com/apple/swift-markdown) for parsing and [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) for creating the DOCX archive.

## Features

- ✅ **Headings** (H1, H2, H3, etc.)
- ✅ **Paragraphs** with rich text formatting
- ✅ **Bold** and *italic* text
- ✅ `Inline code` and code blocks
- ✅ **Bullet lists** and numbered lists
- ✅ [Links](https://example.com)
- ✅ ~~Strikethrough text~~
- ✅ Blockquotes
- ✅ Tables
- ✅ Horizontal rules
- ✅ Images (basic support)

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/markdown-docx-swift.git", from: "1.0.0")
]
```

Or add it to your Xcode project:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Usage

### Basic Conversion

```swift
import MarkdownToDocx

let markdown = """
# My Document

This is a **bold** paragraph with *italic* text.

## Features

- Feature 1
- Feature 2
- Feature 3
"""

do {
    let converter = MarkdownToDocxConverter()
    let docxData = try converter.convert(markdown: markdown)
    
    // Save to file
    try docxData.write(to: outputURL)
} catch {
    print("Error: \(error)")
}
```

### Convert from File

```swift
let converter = MarkdownToDocxConverter()
let docxData = try converter.convert(markdownFile: inputURL)
try docxData.write(to: outputURL)
```

### Advanced Example

```swift
let markdown = """
# Advanced Document

## Code Example

```swift
func helloWorld() {
    print("Hello, World!")
}
```

### Table

| Feature | Support |
|---------|---------|
| Headers | ✅ |
| Lists | ✅ |
| Code | ✅ |

> This is a blockquote.

---

End of document.
"""

// Basic usage
let converter = MarkdownToDocxConverter()
let docxData = try converter.convert(markdown: markdown)

// With custom styling (advanced API)
let customConfig = DocxStylingConfig(
    defaultFont: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
    headings: HeadingStyles(
        h1: HeadingStyle(
            level: 1,
            font: FontConfig(name: "Arial", size: 36, color: "2E5984"),
            spacing: Spacing(before: 360, after: 120)
        )
    )
)
let styledConverter = MarkdownToDocxConverter(stylingConfig: customConfig)
let styledDocxData = try styledConverter.convert(markdown: markdown)

// With user-friendly styling (recommended)
let userFriendlyConfig = UserFriendlyDocxStylingConfig(
    pageMargins: UserFriendlyPageMargins(
        top: .inches(1.0),        // 1 inch
        right: .inches(0.75),     // 0.75 inches
        bottom: .inches(1.0),     // 1 inch
        left: .inches(0.75)       // 0.75 inches
    ),
    defaultFont: UserFriendlyFontConfig(
        name: "Times New Roman",
        size: .points(12.0),      // 12pt font
        color: "000000"
    )
)
let userFriendlyConverter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
let userFriendlyDocxData = try userFriendlyConverter.convert(markdown: markdown)
```

## API Reference

### MarkdownToDocxConverter

The main converter class that handles the conversion process.

#### Methods

- `convert(markdown: String) throws -> Data`
  - Converts a markdown string to DOCX data
  
- `convert(markdownFile: URL) throws -> Data`
  - Converts a markdown file to DOCX data

### DocxElement

Represents different types of content in the DOCX document:

- `.heading(level: Int, text: String)`
- `.paragraph(textRuns: [TextRun])`
- `.bulletList(items: [[TextRun]])`
- `.numberedList(items: [[TextRun]])`
- `.codeBlock(language: String?, code: String)`
- `.blockquote(textRuns: [TextRun])`
- `.table(rows: [TableRow])`
- `.horizontalRule`
- `.image(altText: String, source: String)`

### TextRun

Represents formatted text with various styling options:

- `text: String` - The text content
- `isBold: Bool` - Bold formatting
- `isItalic: Bool` - Italic formatting
- `isUnderlined: Bool` - Underline formatting
- `isStrikethrough: Bool` - Strikethrough formatting
- `isCode: Bool` - Inline code formatting
- `link: String?` - Hyperlink URL

### Styling Configuration

The library supports extensive styling customization through the `DocxStylingConfig` struct:

#### DocxStylingConfig

Main configuration struct that controls all styling aspects:

- `pageMargins: PageMargins` - Document page margins
- `defaultFont: FontConfig` - Default font settings
- `lineSpacing: LineSpacing` - Default line spacing
- `headings: HeadingStyles` - Heading-specific styles
- `paragraphs: ParagraphStyles` - Paragraph formatting
- `codeBlocks: CodeBlockStyles` - Code block appearance
- `blockquotes: BlockquoteStyles` - Blockquote styling
- `tables: TableStyles` - Table formatting
- `lists: ListStyles` - List appearance

#### PageMargins

Controls document page margins (values in twips, where 1 inch = 1440 twips):

- `top: Int` - Top margin
- `right: Int` - Right margin
- `bottom: Int` - Bottom margin
- `left: Int` - Left margin
- `header: Int` - Header margin
- `footer: Int` - Footer margin
- `gutter: Int` - Gutter margin

#### FontConfig

Defines font properties:

- `name: String` - Font family name (e.g., "Arial", "Times New Roman")
- `size: Int` - Font size in half-points (e.g., 24 = 12pt)
- `color: String` - Font color in hex format without # (e.g., "000000" for black)

#### LineSpacing

Controls line spacing:

- `type: LineSpacingType` - Spacing type (.auto, .atLeast, .exactly, .multiple)
- `value: Int?` - Spacing value for non-auto types

#### HeadingStyles

Individual heading level styles (H1-H6):

- `font: FontConfig` - Heading font
- `spacing: Spacing` - Spacing before/after heading
- `keepWithNext: Bool` - Keep heading with next paragraph
- `keepLines: Bool` - Keep heading lines together

#### Spacing

Controls spacing around elements:

- `before: Int` - Space before element (in twips)
- `after: Int` - Space after element (in twips)
- `line: Int?` - Line spacing (in twips)

#### Indentation

Controls text indentation:

- `left: Int` - Left indentation (in twips)
- `right: Int` - Right indentation (in twips)
- `firstLine: Int?` - First line indentation (in twips)
- `hanging: Int?` - Hanging indentation (in twips)

#### Border

Defines border properties:

- `top: BorderSide?` - Top border
- `right: BorderSide?` - Right border
- `bottom: BorderSide?` - Bottom border
- `left: BorderSide?` - Left border

#### BorderSide

Individual border properties:

- `width: Int` - Border width in eighths of a point
- `color: String` - Border color in hex format
- `style: BorderStyle` - Border style (.single, .double, .dashed, .dotted)

#### TextAlignment

Text alignment options:

- `.left` - Left alignment
- `.center` - Center alignment
- `.right` - Right alignment
- `.justify` - Justified alignment

### User-Friendly API

For easier configuration, the library provides a user-friendly API that uses familiar units:

#### Supported Units

- **Inches** (`.inches(1.0)`) - Standard page layout units
- **Points** (`.points(12.0)`) - Standard font and spacing units  
- **Centimeters** (`.centimeters(2.54)`) - Metric units
- **Millimeters** (`.millimeters(25.4)`) - Metric units
- **Twips** (`.twips(1440)`) - Internal DOCX units (advanced users)

#### UserFriendlyDocxStylingConfig

The user-friendly configuration struct:

```swift
let config = UserFriendlyDocxStylingConfig(
    pageMargins: UserFriendlyPageMargins(
        top: .inches(1.0),        // 1 inch
        right: .inches(0.75),     // 0.75 inches
        bottom: .inches(1.0),     // 1 inch
        left: .inches(0.75)       // 0.75 inches
    ),
    defaultFont: UserFriendlyFontConfig(
        name: "Times New Roman",
        size: .points(12.0),      // 12pt font
        color: "000000"
    )
)

let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
```

#### Unit Conversion Examples

| Unit | Value | Twips | Description |
|------|-------|-------|-------------|
| Inches | 1.0 | 1440 | Page margins |
| Points | 12.0 | 240 | Font size |
| Centimeters | 2.54 | 1440 | 1 inch equivalent |
| Millimeters | 25.4 | 1440 | 1 inch equivalent |

#### Mixed Units

You can mix different units in the same configuration:

```swift
let config = UserFriendlyDocxStylingConfig(
    pageMargins: UserFriendlyPageMargins(
        top: .inches(1.0),           // Inches for margins
        right: .centimeters(2.0),    // Centimeters for right margin
        bottom: .inches(1.0),        // Inches for bottom margin
        left: .centimeters(2.0)      // Centimeters for left margin
    ),
    defaultFont: UserFriendlyFontConfig(
        name: "Arial",
        size: .points(14.0),         // Points for font size
        color: "FF0000"
    )
)
```

## Value Behavior and Limitations

### Unit Conversion Behavior

All unit conversions use **truncation** (not rounding) when converting to integers:

```swift
Measurement.points(0.499).twips  // = 9 (not 10)
Measurement.points(0.501).twips  // = 10
Measurement.points(0.999).twips  // = 19 (not 20)
```

### Common Issues

#### 1. Unit Confusion
**Most Common Issue**: Confusing points with inches for page margins.

```swift
// ❌ This will create 72-inch margins!
pageMargins: UserFriendlyPageMargins(
    top: .points(1440),    // 72 inches!
    left: .points(1440)    // 72 inches!
)

// ✅ This creates 1-inch margins:
pageMargins: UserFriendlyPageMargins(
    top: .inches(1.0),     // 1 inch
    left: .inches(1.0)     // 1 inch
)
```

#### 2. Very Small Values
Values smaller than the conversion precision will result in 0 twips:

```swift
Measurement.inches(0.0001).twips  // = 0 (too small)
Measurement.points(0.01).twips    // = 0 (too small)
```

#### 3. Font and Border Width Conversion
Font sizes and border widths use a special conversion: `(points * 20) / 10`

```swift
UserFriendlyFontConfig(size: .points(12.0)).toFontConfig().size  // = 24
UserFriendlyBorderSide(width: .points(1.0)).toBorderSide().width // = 2
```

### Supported Value Ranges

| Value Type | Range | Behavior |
|------------|-------|----------|
| **Positive Values** | 0.0 to ∞ | ✅ Fully supported |
| **Negative Values** | -∞ to 0.0 | ✅ Supported (preserved) |
| **Zero Values** | 0.0 | ✅ Supported |
| **Fractional Values** | Any decimal | ✅ Supported (truncated) |
| **Large Values** | Up to Int.max | ✅ Supported |

For detailed information about value behavior, edge cases, and troubleshooting, see [VALUE_BEHAVIOR_DOCUMENTATION.md](VALUE_BEHAVIOR_DOCUMENTATION.md).

## Supported Markdown Features

| Feature | Support | Notes |
|---------|---------|-------|
| Headers (# ## ###) | ✅ | H1-H6 supported |
| Bold (**text**) | ✅ | |
| Italic (*text*) | ✅ | |
| Inline code (`code`) | ✅ | |
| Code blocks (```) | ✅ | Language syntax highlighting not supported |
| Links ([text](url)) | ✅ | |
| Strikethrough (~~text~~) | ✅ | |
| Bullet lists (- item) | ✅ | |
| Numbered lists (1. item) | ✅ | |
| Blockquotes (> text) | ✅ | |
| Tables (| col1 \| col2 \|) | ✅ | Basic table support |
| Horizontal rules (---) | ✅ | |
| Images (![alt](src)) | ✅ | Basic support, no actual image embedding |

## Dependencies

- [Swift Markdown](https://github.com/apple/swift-markdown) - For parsing Markdown documents
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - For creating DOCX archives

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Example App

The repository includes a sample iOS app that demonstrates the library usage. You can:

1. Open `MarkdownToDocxApp.xcodeproj` in Xcode
2. Build and run the app
3. Enter markdown text in the editor
4. Tap "Convert to DOCX" to generate and save a Word document

## How It Works

1. **Parsing**: The library uses Swift Markdown to parse the input markdown into an abstract syntax tree
2. **Traversal**: It traverses the tree and converts each markdown element to a corresponding DOCX element
3. **Generation**: It generates the necessary XML files for a valid DOCX document:
   - `[Content_Types].xml` - Defines content types
   - `_rels/.rels` - Package relationships
   - `word/document.xml` - Main document content
   - `word/styles.xml` - Document styles
   - `word/_rels/document.xml.rels` - Document relationships
4. **Archiving**: All files are packaged into a ZIP archive using ZIPFoundation

The resulting DOCX file can be opened in Microsoft Word, LibreOffice, or any other compatible word processor. 