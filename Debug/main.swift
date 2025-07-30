#!/usr/bin/env swift

import Foundation
import MarkdownToDocx
import ZIPFoundation

print("🚀 Markdown to DOCX Converter - User-Friendly Styling Configuration Test")
print("📏 Using intuitive units: inches, points, centimeters, millimeters")
print(String(repeating: "=", count: 60))

// Test markdown content
// Note: This example uses the user-friendly API with familiar units:
// - .inches(1.0) for page margins and indentation
// - .points(12.0) for font sizes and spacing
// - .centimeters(2.54) for metric measurements
// - .millimeters(25.4) for precise metric measurements
let testMarkdown = """
# Styling Configuration Test

This document demonstrates different styling configurations.

## Features Tested

- **Bold text** and *italic text*
- `Inline code` formatting
- [Links](https://example.com)
- ~~Strikethrough text~~

### Code Block Example

```swift
func hello() {
    print("Hello, World!")
}
```

> This is a blockquote that demonstrates custom styling.

| Feature | Support | Notes |
|---------|---------|-------|
| Headers | ✅ | All levels supported |
| Lists | ✅ | Bullet and numbered |
| Tables | ✅ | Basic table support |

---

End of document.
"""

// Test 1: Default styling
print("\n1️⃣ Testing default styling...")
let defaultConverter = MarkdownToDocxConverter()
do {
    let defaultData = try defaultConverter.convert(markdown: testMarkdown)
    let defaultURL = FileManager.default.temporaryDirectory.appendingPathComponent("default_styling.docx")
    try defaultData.write(to: defaultURL)
    print("✅ Default styling saved to: \(defaultURL.path)")
    print("📊 File size: \(defaultData.count) bytes")
} catch {
    print("❌ Error with default styling: \(error)")
}

// Test 2: Professional styling
print("\n2️⃣ Testing professional styling...")
let professionalConfig = UserFriendlyDocxStylingConfig(
    defaultFont: UserFriendlyFontConfig(
        name: "Times New Roman",
        size: .points(12.0),      // 12pt font
        color: "000000"
    ),
    headings: HeadingStyles(
        h1: HeadingStyle(
            level: 1,
            font: FontConfig(name: "Arial", size: 36, color: "2E5984"),
            spacing: UserFriendlySpacing(
                before: .points(18.0),  // 18pt before
                after: .points(6.0)     // 6pt after
            ).toSpacing()
        ),
        h2: HeadingStyle(
            level: 2,
            font: FontConfig(name: "Arial", size: 32, color: "2E5984"),
            spacing: UserFriendlySpacing(
                before: .points(15.0),  // 15pt before
                after: .points(6.0)     // 6pt after
            ).toSpacing()
        ),
        h3: HeadingStyle(
            level: 3,
            font: FontConfig(name: "Arial", size: 28, color: "2E5984"),
            spacing: UserFriendlySpacing(
                before: .points(12.0),  // 12pt before
                after: .points(6.0)     // 6pt after
            ).toSpacing()
        )
    ),
    codeBlocks: CodeBlockStyles(
        font: FontConfig(name: "Courier New", size: 20, color: "C7254E"),
        background: "F8F9FA",
        border: UserFriendlyBorder(
            top: UserFriendlyBorderSide(
                width: .points(0.25),   // 0.25pt border
                color: "DEE2E6",
                style: .single
            ),
            right: UserFriendlyBorderSide(
                width: .points(0.25),
                color: "DEE2E6",
                style: .single
            ),
            bottom: UserFriendlyBorderSide(
                width: .points(0.25),
                color: "DEE2E6",
                style: .single
            ),
            left: UserFriendlyBorderSide(
                width: .points(0.25),
                color: "DEE2E6",
                style: .single
            )
        ).toBorder(),
        indentation: UserFriendlyIndentation(
            left: .inches(0.5),     // 0.5 inch left margin
            right: .inches(0.5)     // 0.5 inch right margin
        ).toIndentation(),
        spacing: UserFriendlySpacing(
            before: .points(6.0),   // 6pt before
            after: .points(6.0)     // 6pt after
        ).toSpacing()
    ),
    blockquotes: BlockquoteStyles(
        font: FontConfig(name: "Times New Roman", size: 24, color: "6C757D"),
        border: Border(
            left: BorderSide(width: 8, color: "6C757D", style: .single)
        ),
        indentation: UserFriendlyIndentation(
            left: .inches(0.5),     // 0.5 inch left indent
            right: .inches(0.5)     // 0.5 inch right indent
        ).toIndentation(),
        spacing: UserFriendlySpacing(
            before: .points(6.0),   // 6pt before
            after: .points(6.0)     // 6pt after
        ).toSpacing()
    )
)

let professionalConverter = MarkdownToDocxConverter(userFriendlyConfig: professionalConfig)

do {
    let professionalData = try professionalConverter.convert(markdown: testMarkdown)
    let professionalURL = FileManager.default.temporaryDirectory.appendingPathComponent("professional_styling.docx")
    try professionalData.write(to: professionalURL)
    print("✅ Professional styling saved to: \(professionalURL.path)")
    print("📊 File size: \(professionalData.count) bytes")
} catch {
    print("❌ Error with professional styling: \(error)")
}

// Test 3: Creative styling
print("\n3️⃣ Testing creative styling...")
let creativeConfig = UserFriendlyDocxStylingConfig(
    defaultFont: UserFriendlyFontConfig(
        name: "Arial",
        size: .points(12.0),      // 12pt font
        color: "333333"
    ),
    headings: HeadingStyles(
        h1: HeadingStyle(
            level: 1,
            font: FontConfig(name: "Arial", size: 40, color: "E74C3C"),
            spacing: UserFriendlySpacing(
                before: .points(24.0),  // 24pt before
                after: .points(12.0)    // 12pt after
            ).toSpacing()
        ),
        h2: HeadingStyle(
            level: 2,
            font: FontConfig(name: "Arial", size: 32, color: "3498DB"),
            spacing: UserFriendlySpacing(
                before: .points(18.0),  // 18pt before
                after: .points(9.0)     // 9pt after
            ).toSpacing()
        ),
        h3: HeadingStyle(
            level: 3,
            font: FontConfig(name: "Arial", size: 28, color: "27AE60"),
            spacing: UserFriendlySpacing(
                before: .points(12.0),  // 12pt before
                after: .points(6.0)     // 6pt after
            ).toSpacing()
        )
    ),
    codeBlocks: CodeBlockStyles(
        font: FontConfig(name: "Courier New", size: 20, color: "8E44AD"),
        background: "FDF2F8",
        border: UserFriendlyBorder(
            top: UserFriendlyBorderSide(
                width: .points(0.5),    // 0.5pt border
                color: "E91E63",
                style: .dashed
            ),
            right: UserFriendlyBorderSide(
                width: .points(0.5),
                color: "E91E63",
                style: .dashed
            ),
            bottom: UserFriendlyBorderSide(
                width: .points(0.5),
                color: "E91E63",
                style: .dashed
            ),
            left: UserFriendlyBorderSide(
                width: .points(0.5),
                color: "E91E63",
                style: .dashed
            )
        ).toBorder(),
        indentation: UserFriendlyIndentation(
            left: .inches(0.5),     // 0.5 inch left margin
            right: .inches(0.5)     // 0.5 inch right margin
        ).toIndentation(),
        spacing: UserFriendlySpacing(
            before: .points(6.0),   // 6pt before
            after: .points(6.0)     // 6pt after
        ).toSpacing()
    ),
    blockquotes: BlockquoteStyles(
        font: FontConfig(name: "Georgia", size: 24, color: "7F8C8D"),
        border: Border(
            left: BorderSide(width: 12, color: "F39C12", style: .double)
        ),
        indentation: UserFriendlyIndentation(
            left: .inches(0.5),     // 0.5 inch left indent
            right: .inches(0.5)     // 0.5 inch right indent
        ).toIndentation(),
        spacing: UserFriendlySpacing(
            before: .points(6.0),   // 6pt before
            after: .points(6.0)     // 6pt after
        ).toSpacing()
    )
)

let creativeConverter = MarkdownToDocxConverter(userFriendlyConfig: creativeConfig)

do {
    let creativeData = try creativeConverter.convert(markdown: testMarkdown)
    let creativeURL = FileManager.default.temporaryDirectory.appendingPathComponent("creative_styling.docx")
    try creativeData.write(to: creativeURL)
    print("✅ Creative styling saved to: \(creativeURL.path)")
    print("📊 File size: \(creativeData.count) bytes")
} catch {
    print("❌ Error with creative styling: \(error)")
}

print("\n🎉 All styling tests completed!")
print("\n📁 Generated files are in: \(FileManager.default.temporaryDirectory.path)")
print("\n💡 Open these files in Microsoft Word, Pages, or any DOCX-compatible app to see the styling differences.")
print("\n📋 Files generated:")
print("   • default_styling.docx - Default configuration")
print("   • professional_styling.docx - Professional business styling")
print("   • creative_styling.docx - Colorful creative styling")

// Test the DOCX generation
let markdown = """
# Test Document

This is a **bold** and *italic* test document with [links](https://www.apple.com) and [more links](https://github.com).

## Features

- Bullet point 1
- Bullet point 2 with [link](https://example.com)
- Bullet point 3

1. Numbered item 1
2. Numbered item 2

> This is a blockquote with some important information and a [link](https://swift.org).

```swift
let code = "This is a code block"
print(code)
```

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2 with [link](https://test.com) |
| Cell 3   | Cell 4   |

---

End of document.
"""

do {
    let converter = MarkdownToDocxConverter()
    let docxData = try converter.convert(markdown: markdown)
    
    print("DOCX Data size: \(docxData.count) bytes")
    
    // Check if it's a valid ZIP file
    let zipMagicNumber = Data([0x50, 0x4B, 0x03, 0x04])
    if docxData.starts(with: zipMagicNumber) {
        print("✅ Valid ZIP file (DOCX)")
    } else {
        print("❌ Not a valid ZIP file")
        print("First 16 bytes: \(Array(docxData.prefix(16)).map { String(format: "%02X", $0) }.joined(separator: " "))")
    }
    
    // Save to file for inspection
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let outputURL = documentsPath.appendingPathComponent("test_document.docx")
    
    try docxData.write(to: outputURL)
    print("✅ DOCX file saved to: \(outputURL.path)")
    
    // Check file size
    let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int64 ?? 0
    print("File size on disk: \(fileSize) bytes")
    
    // Try to extract and examine the content
    if let archive = try? Archive(url: outputURL, accessMode: .read) {
        print("✅ Successfully opened as ZIP archive")
        print("Archive entries:")
        for entry in archive {
            print("  - \(entry.path) (\(entry.uncompressedSize) bytes)")
        }
        
        // Try to extract document.xml
        if let documentEntry = archive["word/document.xml"] {
            print("✅ Found document.xml")
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("document.xml")
            try archive.extract(documentEntry, to: tempURL)
            
            let documentContent = try String(contentsOf: tempURL, encoding: .utf8)
            print("Document XML content (first 1000 chars):")
            print(String(documentContent.prefix(1000)))
            
            // Also search for hyperlink content
            if documentContent.contains("<w:hyperlink") {
                print("✅ Found hyperlink elements in document XML")
                // Find and show hyperlink sections
                let lines = documentContent.components(separatedBy: "\n")
                for (index, line) in lines.enumerated() {
                    if line.contains("<w:hyperlink") {
                        print("Hyperlink at line \(index + 1): \(line)")
                        // Show a few lines after the hyperlink
                        for i in 1...3 {
                            if index + i < lines.count {
                                print("  Line \(index + i + 1): \(lines[index + i])")
                            }
                        }
                    }
                }
            } else {
                print("❌ No hyperlink elements found in document XML")
            }
            
            // Clean up
            try? FileManager.default.removeItem(at: tempURL)
            
            // Also check the relationship file
            if let relsEntry = archive["word/_rels/document.xml.rels"] {
                print("✅ Found document.xml.rels")
                
                let relsTempURL = FileManager.default.temporaryDirectory.appendingPathComponent("document.xml.rels")
                try archive.extract(relsEntry, to: relsTempURL)
                
                let relsContent = try String(contentsOf: relsTempURL, encoding: .utf8)
                print("Relationship file content:")
                print(relsContent)
                
                // Clean up
                try? FileManager.default.removeItem(at: relsTempURL)
            } else {
                print("❌ Could not find document.xml.rels in archive")
            }
        } else {
            print("❌ Could not find document.xml in archive")
        }
    } else {
        print("❌ Could not open as ZIP archive")
    }
    
} catch {
    print("❌ Error: \(error)")
} 