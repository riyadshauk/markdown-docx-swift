import XCTest
@testable import MarkdownToDocx

final class UserFriendlyStylingTests: XCTestCase {
    
    func testUserFriendlyPageMargins() throws {
        // Test user-friendly page margins with inches
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(1.25),      // 1.25 inches
                right: .inches(0.75),    // 0.75 inches
                bottom: .inches(1.25),   // 1.25 inches
                left: .inches(0.75)      // 0.75 inches
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = "Test document with user-friendly margins."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testUserFriendlyFontConfiguration() throws {
        // Test user-friendly font configuration with points
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            defaultFont: UserFriendlyFontConfig(
                name: "Arial",
                size: .points(14.0),  // 14pt font
                color: "FF0000"       // Red color
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = "This text should be 14pt Arial in red."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testMixedUnits() throws {
        // Test mixing different units
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(1.0),        // 1 inch
                right: .centimeters(2.0), // 2 cm
                bottom: .inches(1.0),     // 1 inch
                left: .centimeters(2.0)   // 2 cm
            ),
            defaultFont: UserFriendlyFontConfig(
                name: "Times New Roman",
                size: .points(12.0),      // 12pt
                color: "000000"
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = "Test document with mixed units."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testUserFriendlySpacing() throws {
        // Test user-friendly spacing with points
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            headings: HeadingStyles(
                h1: HeadingStyle(
                    level: 1,
                    font: FontConfig(name: "Arial", size: 36, color: "000000"),
                    spacing: UserFriendlySpacing(
                        before: .points(18.0),  // 18pt before
                        after: .points(12.0)    // 12pt after
                    ).toSpacing(),
                    keepWithNext: true,
                    keepLines: true
                )
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = "# Test Heading\n\nThis is a test paragraph."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testUserFriendlyIndentation() throws {
        // Test user-friendly indentation with inches
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            paragraphs: ParagraphStyles(
                normal: ParagraphStyle(
                    font: FontConfig(),
                    alignment: .left,
                    indentation: UserFriendlyIndentation(
                        left: .inches(0.5),      // 0.5 inch left indent
                        firstLine: .inches(0.25) // 0.25 inch first line indent
                    ).toIndentation()
                ),
                spacing: Spacing()
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = "This paragraph should have custom indentation."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testUserFriendlyBorders() throws {
        // Test user-friendly borders with points
        let userFriendlyConfig = UserFriendlyDocxStylingConfig(
            codeBlocks: CodeBlockStyles(
                font: FontConfig(name: "Courier New", size: 20, color: "000000"),
                background: "F5F5F5",
                border: UserFriendlyBorder(
                    top: UserFriendlyBorderSide(
                        width: .points(1.0),    // 1pt border
                        color: "CCCCCC",
                        style: .single
                    ),
                    right: UserFriendlyBorderSide(
                        width: .points(1.0),
                        color: "CCCCCC",
                        style: .single
                    ),
                    bottom: UserFriendlyBorderSide(
                        width: .points(1.0),
                        color: "CCCCCC",
                        style: .single
                    ),
                    left: UserFriendlyBorderSide(
                        width: .points(1.0),
                        color: "CCCCCC",
                        style: .single
                    )
                ).toBorder(),
                indentation: Indentation(),
                spacing: Spacing()
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
        let markdown = """
        Here's some code:
        
        ```swift
        func test() {
            print("Hello")
        }
        ```
        """
        
        let docxData = try converter.convert(markdown: markdown)
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
    
    func testMeasurementConversions() throws {
        // Test that measurements convert correctly
        let oneInch = Measurement.inches(1.0)
        let twelvePoints = Measurement.points(12.0)
        let twoCentimeters = Measurement.centimeters(2.0)
        
        // 1 inch should equal 1440 twips
        XCTAssertEqual(oneInch.twips, 1440)
        
        // 12 points should equal 240 twips
        XCTAssertEqual(twelvePoints.twips, 240)
        
        // 2 cm should be approximately 1133 twips (2 * 566.93, rounded)
        XCTAssertEqual(twoCentimeters.twips, 1133)
    }
    
    func testBackwardCompatibility() throws {
        // Test that the old API still works
        let oldConfig = DocxStylingConfig(
            pageMargins: PageMargins(
                top: 1440,    // 1 inch in twips
                right: 1080,  // 0.75 inch in twips
                bottom: 1440, // 1 inch in twips
                left: 1080    // 0.75 inch in twips
            )
        )
        
        let converter = MarkdownToDocxConverter(stylingConfig: oldConfig)
        let markdown = "Test backward compatibility."
        let docxData = try converter.convert(markdown: markdown)
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX data")
    }
} 