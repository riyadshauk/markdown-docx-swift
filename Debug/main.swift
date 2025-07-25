#!/usr/bin/env swift

import Foundation
import MarkdownToDocx
import ZIPFoundation

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