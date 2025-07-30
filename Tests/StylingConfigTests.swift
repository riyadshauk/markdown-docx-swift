import XCTest
@testable import MarkdownToDocx

final class StylingConfigTests: XCTestCase {
    
    func testDefaultStylingConfig() throws {
        // Test that default configuration works
        let config = DocxStylingConfig()
        let converter = MarkdownToDocxConverter(stylingConfig: config)
        
        let markdown = "# Test Heading\n\nThis is a test paragraph."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
        
        // Verify it's a valid ZIP file (DOCX is a ZIP archive)
        let zipSignature = Data([0x50, 0x4B, 0x03, 0x04])
        XCTAssertTrue(docxData.starts(with: zipSignature), "Should be a valid ZIP/DOCX file")
    }
    
    func testCustomFontConfiguration() throws {
        // Test custom font configuration
        let customConfig = DocxStylingConfig(
            defaultFont: FontConfig(
                name: "Arial",
                size: 28, // 14pt
                color: "FF0000" // Red
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = "This text should use Arial font in red."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testCustomHeadingStyles() throws {
        // Test custom heading styles
        let customConfig = DocxStylingConfig(
            headings: HeadingStyles(
                h1: HeadingStyle(
                    level: 1,
                    font: FontConfig(name: "Times New Roman", size: 40, color: "0000FF"), // Blue, 20pt
                    spacing: Spacing(before: 480, after: 240), // 24pt before, 12pt after
                    keepWithNext: true,
                    keepLines: true
                ),
                h2: HeadingStyle(
                    level: 2,
                    font: FontConfig(name: "Arial", size: 32, color: "008000"), // Green, 16pt
                    spacing: Spacing(before: 360, after: 180), // 18pt before, 9pt after
                    keepWithNext: true,
                    keepLines: true
                )
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = """
        # Main Heading
        
        ## Sub Heading
        
        Regular paragraph text.
        """
        
        let docxData = try converter.convert(markdown: markdown)
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testCustomCodeBlockStyles() throws {
        // Test custom code block styling
        let customConfig = DocxStylingConfig(
            codeBlocks: CodeBlockStyles(
                font: FontConfig(name: "Courier New", size: 20, color: "C7254E"),
                background: "F8F9FA",
                border: Border(
                    top: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    right: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    bottom: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    left: BorderSide(width: 4, color: "DEE2E6", style: .single)
                ),
                indentation: Indentation(left: 720, right: 720),
                spacing: Spacing(before: 120, after: 120)
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = """
        Here's some code:
        
        ```swift
        func hello() {
            print("Hello, World!")
        }
        ```
        """
        
        let docxData = try converter.convert(markdown: markdown)
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testCustomBlockquoteStyles() throws {
        // Test custom blockquote styling
        let customConfig = DocxStylingConfig(
            blockquotes: BlockquoteStyles(
                font: FontConfig(name: "Georgia", size: 24, color: "6C757D"),
                border: Border(
                    left: BorderSide(width: 8, color: "6C757D", style: .single)
                ),
                indentation: Indentation(left: 720, right: 720),
                spacing: Spacing(before: 120, after: 120)
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = """
        > This is a blockquote with custom styling.
        > It should have a left border and custom font.
        """
        
        let docxData = try converter.convert(markdown: markdown)
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testCustomPageMargins() throws {
        // Test custom page margins
        let customConfig = DocxStylingConfig(
            pageMargins: PageMargins(
                top: 1800,      // 1.25 inches
                right: 1440,    // 1 inch
                bottom: 1800,   // 1.25 inches
                left: 1440,     // 1 inch
                header: 720,    // 0.5 inch
                footer: 720     // 0.5 inch
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = "Test document with custom margins."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testComplexStylingConfiguration() throws {
        // Test a complex configuration with multiple customizations
        let customConfig = DocxStylingConfig(
            pageMargins: PageMargins(top: 1440, right: 1080, bottom: 1440, left: 1080),
            defaultFont: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
            lineSpacing: LineSpacing(type: .atLeast, value: 360),
            headings: HeadingStyles(
                h1: HeadingStyle(
                    level: 1,
                    font: FontConfig(name: "Arial", size: 36, color: "2E5984"),
                    spacing: Spacing(before: 360, after: 120)
                )
            ),
            paragraphs: ParagraphStyles(
                normal: ParagraphStyle(
                    font: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
                    alignment: .justify,
                    indentation: Indentation(firstLine: 720)
                ),
                spacing: Spacing(before: 0, after: 120)
            ),
            codeBlocks: CodeBlockStyles(
                font: FontConfig(name: "Courier New", size: 20, color: "C7254E"),
                background: "F8F9FA",
                border: Border(
                    top: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    right: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    bottom: BorderSide(width: 4, color: "DEE2E6", style: .single),
                    left: BorderSide(width: 4, color: "DEE2E6", style: .single)
                ),
                indentation: Indentation(left: 720, right: 720),
                spacing: Spacing(before: 120, after: 120)
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
        let markdown = """
        # Document Title
        
        This is a paragraph with custom styling. It should be justified and have a first-line indent.
        
        ```swift
        func example() {
            print("This code block should have custom styling")
        }
        ```
        
        > This is a blockquote that should use default styling.
        
        ## Section Heading
        
        More content here.
        """
        
        let docxData = try converter.convert(markdown: markdown)
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
        
        // Verify it's a valid ZIP file
        let zipSignature = Data([0x50, 0x4B, 0x03, 0x04])
        XCTAssertTrue(docxData.starts(with: zipSignature), "Should be a valid ZIP/DOCX file")
    }
    
    func testBackwardCompatibility() throws {
        // Test that the old API still works (backward compatibility)
        let converter = MarkdownToDocxConverter() // No styling config parameter
        let markdown = "# Test\n\nThis should work with default styling."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
} 