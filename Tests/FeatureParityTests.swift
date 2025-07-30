import XCTest
import ZIPFoundation
@testable import MarkdownToDocx

final class FeatureParityTests: XCTestCase {
    
    func testPageSizeConfiguration() throws {
        // Test different page sizes
        let a4Config = UserFriendlyDocxStylingConfig(pageSize: .a4)
        let letterConfig = UserFriendlyDocxStylingConfig(pageSize: .letter)
        let legalConfig = UserFriendlyDocxStylingConfig(pageSize: .legal)
        
        XCTAssertEqual(a4Config.pageSize.width.twips, 11900) // 595pt * 20
        XCTAssertEqual(a4Config.pageSize.height.twips, 16840) // 842pt * 20
        
        XCTAssertEqual(letterConfig.pageSize.width.twips, 12240) // 612pt * 20
        XCTAssertEqual(letterConfig.pageSize.height.twips, 15840) // 792pt * 20
        
        XCTAssertEqual(legalConfig.pageSize.width.twips, 12240) // 612pt * 20
        XCTAssertEqual(legalConfig.pageSize.height.twips, 20160) // 1008pt * 20
    }
    
    func testSystemFontSupport() throws {
        // Test system font configurations
        let systemFont = UserFriendlyFontConfig(systemFont: .system, size: .points(12.0))
        let monoFont = UserFriendlyFontConfig(systemFont: .systemMono, size: .points(11.0))
        let serifFont = UserFriendlyFontConfig(systemFont: .serif, size: .points(12.0))
        
        let systemConfig = systemFont.toFontConfig()
        let monoConfig = monoFont.toFontConfig()
        let serifConfig = serifFont.toFontConfig()
        
        XCTAssertTrue(systemConfig.name.contains("Calibri"))
        XCTAssertTrue(systemConfig.name.contains("-apple-system"))
        XCTAssertTrue(systemConfig.name.contains("BlinkMacSystemFont"))
        
        XCTAssertTrue(monoConfig.name.contains("Consolas"))
        XCTAssertTrue(monoConfig.name.contains("SF Mono"))
        XCTAssertTrue(monoConfig.name.contains("Monaco"))
        
        XCTAssertTrue(serifConfig.name.contains("Times New Roman"))
        XCTAssertTrue(serifConfig.name.contains("Georgia"))
    }
    
    func testLinkColorSupport() throws {
        let config = UserFriendlyDocxStylingConfig(linkColor: "FF0000")
        let internalConfig = config.toDocxStylingConfig()
        
        XCTAssertEqual(internalConfig.linkColor, "FF0000")
        
        // Test default link color
        let defaultConfig = UserFriendlyDocxStylingConfig()
        let defaultInternalConfig = defaultConfig.toDocxStylingConfig()
        
        XCTAssertEqual(defaultInternalConfig.linkColor, "0066cc")
    }
    
    func testFullFeatureParityConfiguration() throws {
        // Recreate the PDF configuration exactly
        let coverLetterOptimized = UserFriendlyDocxStylingConfig(
            pageSize: .letter, // 612.0 x 792.0 points
            pageMargins: UserFriendlyPageMargins(
                top: .points(40.0),      // 40pt = 0.556 inches
                right: .points(40.0),    // 40pt = 0.556 inches
                bottom: .points(40.0),   // 40pt = 0.556 inches
                left: .points(40.0)      // 40pt = 0.556 inches
            ),
            defaultFont: UserFriendlyFontConfig(
                systemFont: .system,
                size: .points(12.0),
                color: "333333"
            ),
            lineSpacing: LineSpacing(
                type: .multiple,
                value: 360 // 1.5 * 240 (12pt * 20)
            ),
            headings: HeadingStyles(
                h1: HeadingStyle(
                    level: 1,
                    font: FontConfig(
                        name: "Calibri",
                        size: 36, // 18pt * 2
                        color: "000000"
                    ),
                    spacing: Spacing(before: 280, after: 280) // 14pt * 20
                ),
                h2: HeadingStyle(
                    level: 2,
                    font: FontConfig(
                        name: "Calibri", 
                        size: 28, // 14pt * 2
                        color: "000000"
                    ),
                    spacing: Spacing(before: 280, after: 280)
                ),
                h3: HeadingStyle(
                    level: 3,
                    font: FontConfig(
                        name: "Calibri",
                        size: 24, // 12pt * 2
                        color: "000000"
                    ),
                    spacing: Spacing(before: 280, after: 280)
                )
            ),
            paragraphs: ParagraphStyles(
                spacing: Spacing(before: 200, after: 200) // 10pt * 20
            ),
            codeBlocks: CodeBlockStyles(
                font: FontConfig(
                    name: "Consolas", // Monospace font
                    size: 22, // 11pt * 2
                    color: "000000"
                ),
                background: "F5F5F5"
            ),
            lists: ListStyles(
                indentation: 100 // 5pt * 20
            ),
            linkColor: "0066cc"
        )
        
        // Verify all properties match the PDF configuration
        XCTAssertEqual(coverLetterOptimized.pageSize.width.twips, 12240) // 612pt * 20
        XCTAssertEqual(coverLetterOptimized.pageSize.height.twips, 15840) // 792pt * 20
        
        XCTAssertEqual(coverLetterOptimized.pageMargins.top.twips, 800) // 40pt * 20
        XCTAssertEqual(coverLetterOptimized.pageMargins.bottom.twips, 800) // 40pt * 20
        XCTAssertEqual(coverLetterOptimized.pageMargins.left.twips, 800) // 40pt * 20
        XCTAssertEqual(coverLetterOptimized.pageMargins.right.twips, 800) // 40pt * 20
        
        XCTAssertEqual(coverLetterOptimized.defaultFont.size.twips, 240) // 12pt * 20
        XCTAssertEqual(coverLetterOptimized.defaultFont.color, "333333")
        
        XCTAssertEqual(coverLetterOptimized.lineSpacing.type, LineSpacingType.multiple)
        XCTAssertEqual(coverLetterOptimized.lineSpacing.value, 360)
        
        XCTAssertEqual(coverLetterOptimized.headings.h1.font.size, 36) // 18pt * 2
        XCTAssertEqual(coverLetterOptimized.headings.h2.font.size, 28) // 14pt * 2
        XCTAssertEqual(coverLetterOptimized.headings.h3.font.size, 24) // 12pt * 2
        
        XCTAssertEqual(coverLetterOptimized.paragraphs.spacing.before, 200) // 10pt * 20
        XCTAssertEqual(coverLetterOptimized.paragraphs.spacing.after, 200) // 10pt * 20
        
        XCTAssertEqual(coverLetterOptimized.codeBlocks.font.size, 22) // 11pt * 2
        XCTAssertEqual(coverLetterOptimized.codeBlocks.background, "F5F5F5")
        
        XCTAssertEqual(coverLetterOptimized.lists.indentation, 100) // 5pt * 20
        
        XCTAssertEqual(coverLetterOptimized.linkColor, "0066cc")
    }
    
    func testDocumentGenerationWithNewFeatures() throws {
        let config = UserFriendlyDocxStylingConfig(
            pageSize: .a4,
            defaultFont: UserFriendlyFontConfig(systemFont: .system, size: .points(12.0)),
            linkColor: "FF0000"
        )
        
        let converter = MarkdownToDocxConverter(userFriendlyConfig: config)
        let markdown = """
        # Test Document
        
        This is a [link](https://example.com) with custom color.
        
        ```swift
        func test() {
            print("Hello, World!")
        }
        ```
        """
        
        let docxData = try converter.convert(markdown: markdown)
        
        // Verify the document was generated successfully
        XCTAssertFalse(docxData.isEmpty)
        
        // Extract and verify the document contains our configuration
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test_docx.docx")
        try docxData.write(to: tempURL)
        let archive = try Archive(url: tempURL, accessMode: .read)
        
        // Check that document.xml exists
        XCTAssertNotNil(archive["word/document.xml"])
        
        // Check that styles.xml exists
        XCTAssertNotNil(archive["word/styles.xml"])
        
        // Check that settings.xml exists
        XCTAssertNotNil(archive["word/settings.xml"])
    }
    
    func testPageSizePresets() throws {
        // Test all predefined page sizes
        let sizes = [
            (PageSize.letter, 12240, 15840),    // 612pt x 792pt
            (PageSize.legal, 12240, 20160),     // 612pt x 1008pt
            (PageSize.a4, 11900, 16840),        // 595pt x 842pt
            (PageSize.a3, 16840, 23820),        // 842pt x 1191pt
            (PageSize.a5, 8400, 11900),         // 420pt x 595pt
            (PageSize.executive, 10440, 15120), // 522pt x 756pt
            (PageSize.tabloid, 15840, 24480)    // 792pt x 1224pt
        ]
        
        for (size, expectedWidth, expectedHeight) in sizes {
            XCTAssertEqual(size.width.twips, expectedWidth)
            XCTAssertEqual(size.height.twips, expectedHeight)
        }
    }
    
    func testSystemFontPresets() throws {
        // Test all predefined system font configurations
        let fonts = [
            SystemFontConfig.system,
            SystemFontConfig.systemMono,
            SystemFontConfig.serif,
            SystemFontConfig.sansSerif
        ]
        
        for font in fonts {
            XCTAssertFalse(font.primary.isEmpty)
            XCTAssertFalse(font.fullFontName.isEmpty)
            XCTAssertTrue(font.fullFontName.contains(font.primary))
        }
        
        // Test specific font configurations
        XCTAssertTrue(SystemFontConfig.system.fullFontName.contains("Calibri"))
        XCTAssertTrue(SystemFontConfig.system.fullFontName.contains("-apple-system"))
        
        XCTAssertTrue(SystemFontConfig.systemMono.fullFontName.contains("Consolas"))
        XCTAssertTrue(SystemFontConfig.systemMono.fullFontName.contains("SF Mono"))
        
        XCTAssertTrue(SystemFontConfig.serif.fullFontName.contains("Times New Roman"))
        XCTAssertTrue(SystemFontConfig.serif.fullFontName.contains("Georgia"))
        
        XCTAssertTrue(SystemFontConfig.sansSerif.fullFontName.contains("Arial"))
        XCTAssertTrue(SystemFontConfig.sansSerif.fullFontName.contains("Helvetica"))
    }
} 