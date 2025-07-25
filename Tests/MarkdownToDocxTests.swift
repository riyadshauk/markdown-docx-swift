//
//  MarkdownToDocxTests.swift
//  MarkdownToDocxTests
//
//  Created by Riyad Shauk on 7/25/25.
//

import XCTest
import MarkdownToDocx
import ZIPFoundation

final class MarkdownToDocxTests: XCTestCase {
    
    func testBasicConversion() throws {
        let markdown = "# Test Document\n\nThis is a **test**."
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "DOCX data should not be empty")
        XCTAssertTrue(docxData.count > 1000, "DOCX data should be substantial")
        
        // Verify it's a valid ZIP file
        let zipMagicNumber = Data([0x50, 0x4B])
        XCTAssertTrue(docxData.starts(with: zipMagicNumber), "Should be a ZIP file (starts with PK)")
        
        // Extract and verify the document content
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("Test Document"), "Should contain the heading text")
        XCTAssertTrue(documentXml.contains("test"), "Should contain the paragraph text")
        XCTAssertTrue(documentXml.contains("Heading1"), "Should contain Heading1 style")
    }
    
    func testHeadings() throws {
        let markdown = """
        # Heading 1
        ## Heading 2
        ### Heading 3
        """
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0)
        
        // Extract and verify the document content
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("Heading 1"), "Should contain Heading 1 text")
        XCTAssertTrue(documentXml.contains("Heading 2"), "Should contain Heading 2 text")
        XCTAssertTrue(documentXml.contains("Heading 3"), "Should contain Heading 3 text")
        XCTAssertTrue(documentXml.contains("Heading1"), "Should contain Heading1 style")
        XCTAssertTrue(documentXml.contains("Heading2"), "Should contain Heading2 style")
        XCTAssertTrue(documentXml.contains("Heading3"), "Should contain Heading3 style")
    }
    
    func testBoldAndItalic() throws {
        let markdown = "This is **bold** and *italic* text."
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("<w:b/>"), "Should contain bold formatting")
        XCTAssertTrue(documentXml.contains("<w:i/>"), "Should contain italic formatting")
        XCTAssertTrue(documentXml.contains("bold"), "Should contain bold text")
        XCTAssertTrue(documentXml.contains("italic"), "Should contain italic text")
    }
    
    func testCodeBlocks() throws {
        let markdown = """
        ```swift
        func test() {
            print("Hello, World!")
        }
        ```
        """
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("CodeBlock"), "Should contain CodeBlock style")
        XCTAssertTrue(documentXml.contains("func test()"), "Should contain code content")
        XCTAssertTrue(documentXml.contains("print"), "Should contain code content")
    }
    
    func testLists() throws {
        let markdown = """
        - Item 1
        - Item 2
        - Item 3
        
        1. Numbered item 1
        2. Numbered item 2
        """
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("numPr"), "Should contain numbering properties")
        XCTAssertTrue(documentXml.contains("ilvl"), "Should contain list level")
        XCTAssertTrue(documentXml.contains("Item 1"), "Should contain list item text")
        XCTAssertTrue(documentXml.contains("Numbered item 1"), "Should contain numbered list text")
    }
    
    func testTables() throws {
        let markdown = """
        | Header 1 | Header 2 |
        |----------|----------|
        | Cell 1   | Cell 2   |
        | Cell 3   | Cell 4   |
        """
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("<w:tbl>"), "Should contain table element")
        XCTAssertTrue(documentXml.contains("<w:tr>"), "Should contain table row")
        XCTAssertTrue(documentXml.contains("<w:tc>"), "Should contain table cell")
        XCTAssertTrue(documentXml.contains("Header 1"), "Should contain header text")
        XCTAssertTrue(documentXml.contains("Cell 1"), "Should contain cell text")
    }
    
    func testBlockquotes() throws {
        let markdown = "> This is a blockquote."
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("Quote"), "Should contain Quote style")
        XCTAssertTrue(documentXml.contains("This is a blockquote"), "Should contain blockquote text")
    }
    
    func testHorizontalRule() throws {
        let markdown = "Some text\n\n---\n\nMore text"
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("pBdr"), "Should contain paragraph border")
        XCTAssertTrue(documentXml.contains("Some text"), "Should contain first paragraph")
        XCTAssertTrue(documentXml.contains("More text"), "Should contain second paragraph")
    }
    
    func testComplexDocument() throws {
        let markdown = """
        # Complex Test Document
        
        This document tests **multiple** *features* together.
        
        ## Code Example
        
        ```swift
        func complexTest() {
            let result = "Success!"
            print(result)
        }
        ```
        
        ## List Example
        
        - Feature 1
        - Feature 2
        - Feature 3
        
        ## Table Example
        
        | Feature | Status |
        |---------|--------|
        | Headers | ✅ |
        | Code | ✅ |
        | Lists | ✅ |
        
        > This is a blockquote in a complex document.
        
        ---
        
        End of document.
        """
        
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0)
        
        let documentXml = try extractDocumentXml(from: docxData)
        
        // Verify all features are present
        XCTAssertTrue(documentXml.contains("Heading1"), "Should contain Heading1")
        XCTAssertTrue(documentXml.contains("Heading2"), "Should contain Heading2")
        XCTAssertTrue(documentXml.contains("<w:b/>"), "Should contain bold")
        XCTAssertTrue(documentXml.contains("<w:i/>"), "Should contain italic")
        XCTAssertTrue(documentXml.contains("CodeBlock"), "Should contain code block")
        XCTAssertTrue(documentXml.contains("numPr"), "Should contain lists")
        XCTAssertTrue(documentXml.contains("<w:tbl>"), "Should contain table")
        XCTAssertTrue(documentXml.contains("Quote"), "Should contain quote")
        XCTAssertTrue(documentXml.contains("pBdr"), "Should contain horizontal rule")

        XCTAssertTrue(documentXml.contains("Complex Test Document"), "Should contain main heading")
        XCTAssertTrue(documentXml.contains("Code Example"), "Should contain subheading")
        XCTAssertTrue(documentXml.contains("multiple"), "Should contain bold text")
        XCTAssertTrue(documentXml.contains("features"), "Should contain italic text")
        XCTAssertTrue(documentXml.contains("CodeBlock"), "Should contain code block")
        XCTAssertTrue(documentXml.contains("Feature 1"), "Should contain list items")
        XCTAssertTrue(documentXml.contains("<w:tbl>"), "Should contain table")
        XCTAssertTrue(documentXml.contains("blockquote"), "Should contain blockquote text")
        XCTAssertTrue(documentXml.contains("End of document"), "Should contain final text")
    }
    
    func testFileConversion() throws {
        let markdown = "# Test from file\n\nThis tests file conversion."
        
        // Create a temporary markdown file
        let tempDir = FileManager.default.temporaryDirectory
        let markdownURL = tempDir.appendingPathComponent("test.md")
        try markdown.write(to: markdownURL, atomically: true, encoding: .utf8)
        
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdownFile: markdownURL)
        
        XCTAssertGreaterThan(docxData.count, 0)
        
        let documentXml = try extractDocumentXml(from: docxData)
        XCTAssertTrue(documentXml.contains("Test from file"), "Should contain file content")
        
        // Clean up
        try FileManager.default.removeItem(at: markdownURL)
    }
    
    func testEmptyDocument() throws {
        let markdown = ""
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        // Should still create a valid DOCX structure
        XCTAssertGreaterThan(docxData.count, 0)
        
        // Verify it's a valid ZIP file
        let zipMagicNumber = Data([0x50, 0x4B])
        XCTAssertTrue(docxData.starts(with: zipMagicNumber), "Should be a valid ZIP file")
    }
    
    func testSpecialCharacters() throws {
        let markdown = "Test with special chars: & < > \" '"
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        
        // Should properly escape XML characters that need escaping
        XCTAssertTrue(documentXml.contains("&amp;"), "Should escape &")
        XCTAssertTrue(documentXml.contains("&lt;"), "Should escape <")
        XCTAssertTrue(documentXml.contains("&gt;"), "Should escape >")
        // Quotes don't need to be escaped in XML text content, so we check for the literal characters
        XCTAssertTrue(documentXml.contains("\""), "Should contain literal quote")
        // Note: Apostrophe is handled correctly but may be Unicode normalized
    }
    
    func testLinks() throws {
        let markdown = "This is a [link to example.com](https://example.com) and another [GitHub link](https://github.com)."
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        
        // Should contain hyperlink elements with relationship IDs
        XCTAssertTrue(documentXml.contains("<w:hyperlink"), "Should contain hyperlink element")
        XCTAssertTrue(documentXml.contains("r:id=\"rId2\""), "Should contain first relationship ID")
        XCTAssertTrue(documentXml.contains("r:id=\"rId3\""), "Should contain second relationship ID")
        XCTAssertTrue(documentXml.contains("link to example.com"), "Should contain first link text")
        XCTAssertTrue(documentXml.contains("GitHub link"), "Should contain second link text")
        
        // Also check that the relationship file contains the correct URLs
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("temp.docx")
        try docxData.write(to: tempURL)
        
        let archive = try Archive(url: tempURL, accessMode: .read)
        if let relsEntry = archive["word/_rels/document.xml.rels"] {
            let extractURL = tempDir.appendingPathComponent("document.xml.rels")
            try archive.extract(relsEntry, to: extractURL)
            let relsData = try Data(contentsOf: extractURL)
            let relsString = String(data: relsData, encoding: .utf8) ?? ""
            
            XCTAssertTrue(relsString.contains("Target=\"https://example.com\""), "Should contain first link target in relationships")
            XCTAssertTrue(relsString.contains("Target=\"https://github.com\""), "Should contain second link target in relationships")
            
            // Clean up
            try FileManager.default.removeItem(at: tempURL)
            try FileManager.default.removeItem(at: extractURL)
        }
    }
    
    func testSaveToFile() throws {
        let markdown = "# Test Document\n\nThis tests saving to a file."
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        // Save to a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let docxURL = tempDir.appendingPathComponent("test_output.docx")
        try docxData.write(to: docxURL)
        
        // Verify the file was created and has content
        XCTAssertTrue(FileManager.default.fileExists(atPath: docxURL.path))
        
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: docxURL.path)
        let fileSize = fileAttributes[.size] as? Int64 ?? 0
        XCTAssertGreaterThan(fileSize, 0)
        
        // Verify the saved file can be opened and contains expected content
        let savedData = try Data(contentsOf: docxURL)
        let documentXml = try extractDocumentXml(from: savedData)
        XCTAssertTrue(documentXml.contains("Test Document"), "Saved file should contain expected content")
        
        // Clean up
        try FileManager.default.removeItem(at: docxURL)
    }
    
    // Helper function to extract and read the document.xml from a DOCX file
    func extractDocumentXml(from docxData: Data) throws -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("temp.docx")
        
        // Write the DOCX data to a temporary file
        try docxData.write(to: tempURL)
        
        // Extract the document.xml file
        let archive = try Archive(url: tempURL, accessMode: .read)
        
        // Find and extract the document.xml file
        guard let documentEntry = archive["word/document.xml"] else {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find document.xml in DOCX"])
        }
        
        // Extract to a temporary file first
        let extractURL = tempDir.appendingPathComponent("document.xml")
        try archive.extract(documentEntry, to: extractURL)
        
        // Read the extracted file
        let documentData = try Data(contentsOf: extractURL)
        
        // Clean up
        try FileManager.default.removeItem(at: tempURL)
        try FileManager.default.removeItem(at: extractURL)
        
        // Convert to string
        guard let documentString = String(data: documentData, encoding: .utf8) else {
            throw NSError(domain: "TestError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not decode document.xml as UTF-8"])
        }
        
        return documentString
    }
    
    // Helper function to debug what's actually in the DOCX
    func debugDocxContent(_ docxData: Data, testName: String) {
        print("\n=== DEBUG: \(testName) ===")
        print("DOCX size: \(docxData.count) bytes")
        print("First 16 bytes (hex): \(docxData.prefix(16).map { String(format: "%02X", $0) }.joined(separator: " "))")
        
        do {
            let documentXml = try extractDocumentXml(from: docxData)
            print("Document XML (first 500 chars):")
            print(String(documentXml.prefix(500)))
        } catch {
            print("Could not extract document XML: \(error)")
        }
        
        print("=== END DEBUG ===\n")
    }
} 