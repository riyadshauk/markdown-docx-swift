import Foundation
import MarkdownToDocx

// Example of how to use the new styling configuration
func testStylingConfiguration() {
    // Create a custom styling configuration
    let customConfig = DocxStylingConfig(
        // Page margins (in twips - 1 inch = 1440 twips)
        pageMargins: PageMargins(
            top: 1440,      // 1 inch
            right: 1080,    // 0.75 inch
            bottom: 1440,   // 1 inch
            left: 1080,     // 0.75 inch
            header: 720,    // 0.5 inch
            footer: 720     // 0.5 inch
        ),
        
        // Default font settings
        defaultFont: FontConfig(
            name: "Times New Roman",
            size: 24,       // 12pt
            color: "000000" // black
        ),
        
        // Line spacing
        lineSpacing: LineSpacing(
            type: .atLeast,
            value: 360      // 18pt minimum line spacing
        ),
        
        // Heading styles
        headings: HeadingStyles(
            h1: HeadingStyle(
                level: 1,
                font: FontConfig(name: "Arial", size: 36, color: "2E5984"), // 18pt, dark blue
                spacing: Spacing(before: 360, after: 120), // 18pt before, 6pt after
                keepWithNext: true,
                keepLines: true
            ),
            h2: HeadingStyle(
                level: 2,
                font: FontConfig(name: "Arial", size: 32, color: "2E5984"), // 16pt, dark blue
                spacing: Spacing(before: 300, after: 120), // 15pt before, 6pt after
                keepWithNext: true,
                keepLines: true
            ),
            h3: HeadingStyle(
                level: 3,
                font: FontConfig(name: "Arial", size: 28, color: "2E5984"), // 14pt, dark blue
                spacing: Spacing(before: 240, after: 120), // 12pt before, 6pt after
                keepWithNext: true,
                keepLines: true
            )
        ),
        
        // Paragraph styles
        paragraphs: ParagraphStyles(
            normal: ParagraphStyle(
                font: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
                alignment: .justify,
                indentation: Indentation(firstLine: 720) // 0.5 inch first line indent
            ),
            spacing: Spacing(before: 0, after: 120) // 6pt after paragraphs
        ),
        
        // Code block styles
        codeBlocks: CodeBlockStyles(
            font: FontConfig(name: "Courier New", size: 20, color: "C7254E"), // 10pt, red
            background: "F8F9FA", // light gray background
            border: Border(
                top: BorderSide(width: 4, color: "DEE2E6", style: .single),
                right: BorderSide(width: 4, color: "DEE2E6", style: .single),
                bottom: BorderSide(width: 4, color: "DEE2E6", style: .single),
                left: BorderSide(width: 4, color: "DEE2E6", style: .single)
            ),
            indentation: Indentation(left: 720, right: 720), // 0.5 inch left/right margins
            spacing: Spacing(before: 120, after: 120) // 6pt before/after
        ),
        
        // Blockquote styles
        blockquotes: BlockquoteStyles(
            font: FontConfig(name: "Times New Roman", size: 24, color: "6C757D"), // gray text
            border: Border(
                left: BorderSide(width: 8, color: "6C757D", style: .single) // left border only
            ),
            indentation: Indentation(left: 720, right: 720), // 0.5 inch left/right margins
            spacing: Spacing(before: 120, after: 120) // 6pt before/after
        ),
        
        // Table styles
        tables: TableStyles(
            border: Border(
                top: BorderSide(width: 4, color: "000000", style: .single),
                right: BorderSide(width: 4, color: "000000", style: .single),
                bottom: BorderSide(width: 4, color: "000000", style: .single),
                left: BorderSide(width: 4, color: "000000", style: .single)
            ),
            cellPadding: 120, // 6pt cell padding
            headerStyle: FontConfig(name: "Arial", size: 24, color: "000000"),
            bodyStyle: FontConfig(name: "Times New Roman", size: 24, color: "000000")
        ),
        
        // List styles
        lists: ListStyles(
            bulletFont: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
            numberedFont: FontConfig(name: "Times New Roman", size: 24, color: "000000"),
            indentation: 720 // 0.5 inch list indentation
        )
    )
    
    // Create converter with custom styling
    let converter = MarkdownToDocxConverter(stylingConfig: customConfig)
    
    // Example markdown content
    let markdown = """
    # Document Title
    
    This is a paragraph with **bold text** and *italic text*. It demonstrates the custom styling configuration.
    
    ## Section Heading
    
    Here's a code block:
    
    ```swift
    func hello() {
        print("Hello, World!")
    }
    ```
    
    > This is a blockquote that demonstrates the custom styling for quotes.
    
    ### Subsection
    
    - Bullet point 1
    - Bullet point 2
    - Bullet point 3
    
    1. Numbered item 1
    2. Numbered item 2
    3. Numbered item 3
    
    | Column 1 | Column 2 | Column 3 |
    |----------|----------|----------|
    | Data 1   | Data 2   | Data 3   |
    | Data 4   | Data 5   | Data 6   |
    """
    
    do {
        let docxData = try converter.convert(markdown: markdown)
        
        // Save to file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("styled_document.docx")
        try docxData.write(to: outputURL)
        
        print("✅ Document created successfully with custom styling!")
        print("📁 Saved to: \(outputURL.path)")
        
    } catch {
        print("❌ Error creating document: \(error)")
    }
}

// Run the test
testStylingConfiguration() 