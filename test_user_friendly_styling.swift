import Foundation
import MarkdownToDocx

// Example demonstrating the user-friendly styling API
func testUserFriendlyStyling() {
    print("🎨 Testing User-Friendly Styling API")
    print("=" * 50)
    
    // Create a user-friendly configuration with familiar units
    let userFriendlyConfig = UserFriendlyDocxStylingConfig(
        // Page margins in inches (like Microsoft Word)
        pageMargins: UserFriendlyPageMargins(
            top: .inches(1.0),        // 1 inch
            right: .inches(0.75),     // 0.75 inches
            bottom: .inches(1.0),     // 1 inch
            left: .inches(0.75)       // 0.75 inches
        ),
        
        // Font in points (like Microsoft Word)
        defaultFont: UserFriendlyFontConfig(
            name: "Times New Roman",
            size: .points(12.0),      // 12pt font
            color: "000000"           // Black
        ),
        
        // Heading styles with points for spacing
        headings: HeadingStyles(
            h1: HeadingStyle(
                level: 1,
                font: FontConfig(name: "Arial", size: 36, color: "2E5984"),
                spacing: UserFriendlySpacing(
                    before: .points(18.0),  // 18pt before heading
                    after: .points(12.0)    // 12pt after heading
                ).toSpacing(),
                keepWithNext: true,
                keepLines: true
            ),
            h2: HeadingStyle(
                level: 2,
                font: FontConfig(name: "Arial", size: 32, color: "2E5984"),
                spacing: UserFriendlySpacing(
                    before: .points(15.0),  // 15pt before
                    after: .points(9.0)     // 9pt after
                ).toSpacing(),
                keepWithNext: true,
                keepLines: true
            )
        ),
        
        // Code blocks with mixed units
        codeBlocks: CodeBlockStyles(
            font: FontConfig(name: "Courier New", size: 20, color: "C7254E"),
            background: "F8F9FA",
            border: UserFriendlyBorder(
                top: UserFriendlyBorderSide(
                    width: .points(0.5),    // 0.5pt border
                    color: "DEE2E6",
                    style: .single
                ),
                right: UserFriendlyBorderSide(
                    width: .points(0.5),
                    color: "DEE2E6",
                    style: .single
                ),
                bottom: UserFriendlyBorderSide(
                    width: .points(0.5),
                    color: "DEE2E6",
                    style: .single
                ),
                left: UserFriendlyBorderSide(
                    width: .points(0.5),
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
        
        // Blockquotes with mixed units
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
    
    // Create converter with user-friendly config
    let converter = MarkdownToDocxConverter(userFriendlyConfig: userFriendlyConfig)
    
    // Test markdown content
    let markdown = """
    # User-Friendly Styling Test
    
    This document demonstrates the user-friendly styling API with familiar units.
    
    ## Features
    
    - **Bold text** and *italic text*
    - `Inline code` formatting
    - [Links](https://example.com) <!-- Currently broken: shows as plain text only -->
    
    ### Code Block Example
    
    ```swift
    func hello() {
        print("Hello, World!")
    }
    ```
    
    > This is a blockquote that demonstrates the user-friendly styling.
    
    ### Mixed Units
    
    You can mix different units:
    - Inches for margins: 1.0 inch
    - Points for fonts: 12pt
    - Centimeters for spacing: 2.54cm
    
    | Unit | Value | Description |
    |------|-------|-------------|
    | Inches | 1.0 | Page margins |
    | Points | 12.0 | Font size |
    | Centimeters | 2.54 | Alternative spacing |
    """
    
    do {
        let docxData = try converter.convert(markdown: markdown)
        
        // Save to file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("user_friendly_styling.docx")
        try docxData.write(to: outputURL)
        
        print("✅ User-friendly styling document created successfully!")
        print("📁 Saved to: \(outputURL.path)")
        print("📊 File size: \(docxData.count) bytes")
        
        // Show unit conversion examples
        print("\n📏 Unit Conversion Examples:")
        print("   1 inch = \(Measurement.inches(1.0).twips) twips")
        print("   12 points = \(Measurement.points(12.0).twips) twips")
        print("   2.54 cm = \(Measurement.centimeters(2.54).twips) twips")
        print("   25.4 mm = \(Measurement.millimeters(25.4).twips) twips")
        
    } catch {
        print("❌ Error creating document: \(error)")
    }
}

// Run the test
testUserFriendlyStyling() 