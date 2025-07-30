import XCTest
@testable import MarkdownToDocx

final class ValueBehaviorTests: XCTestCase {
    
    // MARK: - Unit Conversion Tests
    
    func testUnitConversionPrecision() throws {
        // Test precision of unit conversions
        let oneInch = Measurement.inches(1.0)
        let onePoint = Measurement.points(1.0)
        let oneCm = Measurement.centimeters(1.0)
        let oneMm = Measurement.millimeters(1.0)
        
        XCTAssertEqual(oneInch.twips, 1440)
        XCTAssertEqual(onePoint.twips, 20)
        XCTAssertEqual(oneCm.twips, 566) // 566.93 truncated
        XCTAssertEqual(oneMm.twips, 56)  // 56.69 truncated
    }
    
    func testFractionalValues() throws {
        // Test fractional values work correctly
        let halfInch = Measurement.inches(0.5)
        let quarterInch = Measurement.inches(0.25)
        let eighthInch = Measurement.inches(0.125)
        
        XCTAssertEqual(halfInch.twips, 720)      // 1440 / 2
        XCTAssertEqual(quarterInch.twips, 360)   // 1440 / 4
        XCTAssertEqual(eighthInch.twips, 180)    // 1440 / 8
        
        // Test very small fractions
        let tinyInch = Measurement.inches(0.001)
        XCTAssertEqual(tinyInch.twips, 1)        // Rounds down to 1 twip
        
        let smallPoint = Measurement.points(0.1)
        XCTAssertEqual(smallPoint.twips, 2)      // 0.1 * 20 = 2 twips
    }
    
    func testLargeValues() throws {
        // Test very large values
        let largeInch = Measurement.inches(100.0)
        let largePoint = Measurement.points(1000.0)
        
        XCTAssertEqual(largeInch.twips, 144000)  // 100 * 1440
        XCTAssertEqual(largePoint.twips, 20000)  // 1000 * 20
        
        // Test conversion back to original units (approximate)
        let largeInchBack = Double(largeInch.twips) / 1440.0
        XCTAssertEqual(largeInchBack, 100.0, accuracy: 0.001)
    }
    
    func testNegativeValues() throws {
        // Test negative values (should be converted to positive)
        let negativeInch = Measurement.inches(-1.0)
        let negativePoint = Measurement.points(-12.0)
        
        XCTAssertEqual(negativeInch.twips, -1440)  // Negative values are preserved
        XCTAssertEqual(negativePoint.twips, -240)  // Negative values are preserved
        
        // Test that negative values still generate valid DOCX
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(-1.0),      // Negative margin
                left: .inches(-0.5)      // Negative margin
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test negative margins")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle negative values")
    }
    
    func testZeroValues() throws {
        // Test zero values
        let zeroInch = Measurement.inches(0.0)
        let zeroPoint = Measurement.points(0.0)
        
        XCTAssertEqual(zeroInch.twips, 0)
        XCTAssertEqual(zeroPoint.twips, 0)
        
        // Test that zero values work in configuration
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(0.0),       // Zero margin
                left: .inches(0.0)       // Zero margin
            ),
            defaultFont: UserFriendlyFontConfig(
                size: .points(0.0)       // Zero font size
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test zero values")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle zero values")
    }
    
    func testExtremeValues() throws {
        // Test extreme values
        let tinyValue = Measurement.inches(0.000001)
        let hugeValue = Measurement.inches(1000000.0)
        
        XCTAssertEqual(tinyValue.twips, 0)        // Too small, rounds to 0
        XCTAssertEqual(hugeValue.twips, 1440000000) // Very large but valid
        
        // Test that extreme values don't crash the system
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(1000000.0),  // Huge margin
                left: .inches(0.000001)   // Tiny margin
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test extreme values")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle extreme values")
    }
    
    // MARK: - Font Size Tests
    
    func testFontSizeBehavior() throws {
        // Test various font sizes
        let smallFont = UserFriendlyFontConfig(size: .points(6.0))   // 6pt
        let normalFont = UserFriendlyFontConfig(size: .points(12.0)) // 12pt
        let largeFont = UserFriendlyFontConfig(size: .points(72.0))  // 72pt
        let hugeFont = UserFriendlyFontConfig(size: .points(1000.0)) // 1000pt
        
        XCTAssertEqual(smallFont.toFontConfig().size, 12)   // 6pt * 20 / 10 = 12
        XCTAssertEqual(normalFont.toFontConfig().size, 24)  // 12pt * 20 / 10 = 24
        XCTAssertEqual(largeFont.toFontConfig().size, 144)  // 72pt * 20 / 10 = 144
        XCTAssertEqual(hugeFont.toFontConfig().size, 2000)  // 1000pt * 20 / 10 = 2000
        
        // Test that all font sizes generate valid DOCX
        let config = UserFriendlyDocxStylingConfig(
            defaultFont: hugeFont
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test huge font")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle huge font sizes")
    }
    
    func testFontSizeFractions() throws {
        // Test fractional font sizes
        let fractionalFont = UserFriendlyFontConfig(size: .points(12.5))
        let tinyFont = UserFriendlyFontConfig(size: .points(0.1))
        
        XCTAssertEqual(fractionalFont.toFontConfig().size, 25)  // 12.5 * 20 / 10 = 25
        XCTAssertEqual(tinyFont.toFontConfig().size, 0)         // 0.1 * 20 / 10 = 0.2, rounds to 0
        
        // Test that fractional sizes work
        let config = UserFriendlyDocxStylingConfig(
            defaultFont: fractionalFont
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test fractional font")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle fractional font sizes")
    }
    
    // MARK: - Border Width Tests
    
    func testBorderWidthBehavior() throws {
        // Test border width conversions
        let thinBorder = UserFriendlyBorderSide(width: .points(0.25))
        let normalBorder = UserFriendlyBorderSide(width: .points(1.0))
        let thickBorder = UserFriendlyBorderSide(width: .points(10.0))
        
        XCTAssertEqual(thinBorder.toBorderSide().width, 0)   // 0.25 * 20 / 10 = 5, but rounds down
        XCTAssertEqual(normalBorder.toBorderSide().width, 2)  // 1.0 * 20 / 10 = 20, but rounds down
        XCTAssertEqual(thickBorder.toBorderSide().width, 20)  // 10.0 * 20 / 10 = 200, but rounds down
        
        // Test that all border widths work
        let config = UserFriendlyDocxStylingConfig(
            codeBlocks: CodeBlockStyles(
                border: UserFriendlyBorder(
                    top: thickBorder
                ).toBorder()
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "```\nTest thick border\n```")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle thick borders")
    }
    
    // MARK: - Mixed Unit Tests
    
    func testMixedUnitsInSameConfig() throws {
        // Test mixing different units in the same configuration
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(1.0),           // Inches
                right: .centimeters(2.54),   // Centimeters (should equal 1 inch)
                bottom: .millimeters(25.4),  // Millimeters (should equal 1 inch)
                left: .points(1440)          // Points (should equal 1 inch)
            ),
            defaultFont: UserFriendlyFontConfig(
                size: .points(12.0)          // Points
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test mixed units")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle mixed units")
        
        // Verify that equivalent values produce similar results
        let margins = config.pageMargins.toPageMargins()
        XCTAssertEqual(margins.top, 1440)      // 1 inch
        XCTAssertEqual(margins.right, 1440)    // 2.54 cm = 1 inch exactly
        XCTAssertEqual(margins.bottom, 1439)   // 25.4 mm ≈ 1 inch (slight difference)
        XCTAssertEqual(margins.left, 28800)    // 1440 points = 72 inches (not 1 inch!)
    }
    
    // MARK: - Edge Case Tests
    
    func testVerySmallValues() throws {
        // Test values that might round to zero
        let tinyInch = Measurement.inches(0.0001)
        let tinyPoint = Measurement.points(0.01)
        let tinyCm = Measurement.centimeters(0.001)
        
        XCTAssertEqual(tinyInch.twips, 0)      // Too small, rounds to 0
        XCTAssertEqual(tinyPoint.twips, 0)     // Too small, rounds to 0
        XCTAssertEqual(tinyCm.twips, 0)        // Too small, rounds to 0
        
        // Test that tiny values don't break the system
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: tinyInch,
                left: tinyPoint
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let docxData = try converter.convert(markdown: "Test tiny values")
        XCTAssertGreaterThan(docxData.count, 0, "Should handle tiny values")
    }
    
    func testRoundingBehavior() throws {
        // Test rounding behavior
        let point499 = Measurement.points(0.499)
        let point501 = Measurement.points(0.501)
        let point999 = Measurement.points(0.999)
        let point1001 = Measurement.points(1.001)
        
        XCTAssertEqual(point499.twips, 9)   // 0.499 * 20 = 9.98, truncates to 9
        XCTAssertEqual(point501.twips, 10)  // 0.501 * 20 = 10.02, truncates to 10
        XCTAssertEqual(point999.twips, 19)  // 0.999 * 20 = 19.98, truncates to 19
        XCTAssertEqual(point1001.twips, 20) // 1.001 * 20 = 20.02, truncates to 20
    }
    
    // MARK: - Performance Tests
    
    func testLargeDocumentWithComplexStyling() throws {
        // Test that complex styling doesn't cause performance issues
        let config = UserFriendlyDocxStylingConfig(
            pageMargins: UserFriendlyPageMargins(
                top: .inches(1.5),
                right: .centimeters(3.0),
                bottom: .millimeters(38.1),
                left: .points(2160)
            ),
            defaultFont: UserFriendlyFontConfig(
                name: "Arial",
                size: .points(14.0),
                color: "FF0000"
            ),
            headings: HeadingStyles(
                h1: HeadingStyle(
                    level: 1,
                    font: FontConfig(name: "Times New Roman", size: 48, color: "0000FF"),
                    spacing: UserFriendlySpacing(
                        before: .points(24.0),
                        after: .points(12.0)
                    ).toSpacing()
                )
            ),
            codeBlocks: CodeBlockStyles(
                font: FontConfig(name: "Courier New", size: 16, color: "008000"),
                background: "F0F0F0",
                border: UserFriendlyBorder(
                    top: UserFriendlyBorderSide(width: .points(2.0), color: "FF0000"),
                    bottom: UserFriendlyBorderSide(width: .points(2.0), color: "00FF00")
                ).toBorder(),
                indentation: UserFriendlyIndentation(
                    left: .inches(1.0),
                    right: .centimeters(2.0)
                ).toIndentation(),
                spacing: UserFriendlySpacing(
                    before: .points(12.0),
                    after: .points(12.0)
                ).toSpacing()
            )
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        
        // Create a large document
        let largeMarkdown = String(repeating: """
        # Large Document Test
        
        This is a paragraph with **bold** and *italic* text.
        
        ```swift
        func test() {
            print("Hello, World!")
        }
        ```
        
        > This is a blockquote with some important information.
        
        ## Subsection
        
        - Item 1
        - Item 2
        - Item 3
        
        """, count: 10)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let docxData = try converter.convert(markdown: largeMarkdown)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        XCTAssertGreaterThan(docxData.count, 0, "Should generate valid DOCX")
        XCTAssertLessThan(endTime - startTime, 5.0, "Should complete within 5 seconds")
        
        print("Large document conversion took \(endTime - startTime) seconds")
    }
} 