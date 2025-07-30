//
//  DocxElement.swift
//  MarkdownToDocx
//
//  Created by Riyad Shauk on 7/23/25.
//

import Foundation

// MARK: - Styling Configuration

public struct DocxStylingConfig {
    // Document-level settings
    public var pageMargins: PageMargins
    public var defaultFont: FontConfig
    public var lineSpacing: LineSpacing
    
    // Element-specific styling
    public var headings: HeadingStyles
    public var paragraphs: ParagraphStyles
    public var codeBlocks: CodeBlockStyles
    public var blockquotes: BlockquoteStyles
    public var tables: TableStyles
    public var lists: ListStyles
    
    public init(
        pageMargins: PageMargins = PageMargins(),
        defaultFont: FontConfig = FontConfig(),
        lineSpacing: LineSpacing = LineSpacing(),
        headings: HeadingStyles = HeadingStyles(),
        paragraphs: ParagraphStyles = ParagraphStyles(),
        codeBlocks: CodeBlockStyles = CodeBlockStyles(),
        blockquotes: BlockquoteStyles = BlockquoteStyles(),
        tables: TableStyles = TableStyles(),
        lists: ListStyles = ListStyles()
    ) {
        self.pageMargins = pageMargins
        self.defaultFont = defaultFont
        self.lineSpacing = lineSpacing
        self.headings = headings
        self.paragraphs = paragraphs
        self.codeBlocks = codeBlocks
        self.blockquotes = blockquotes
        self.tables = tables
        self.lists = lists
    }
}

public struct PageMargins {
    public var top: Int // in twips (1/20th of a point)
    public var right: Int
    public var bottom: Int
    public var left: Int
    public var header: Int
    public var footer: Int
    public var gutter: Int
    
    public init(
        top: Int = 1440,      // 1 inch
        right: Int = 1440,    // 1 inch
        bottom: Int = 1440,   // 1 inch
        left: Int = 1440,     // 1 inch
        header: Int = 720,    // 0.5 inch
        footer: Int = 720,    // 0.5 inch
        gutter: Int = 0
    ) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.header = header
        self.footer = footer
        self.gutter = gutter
    }
}

public struct FontConfig {
    public var name: String
    public var size: Int // in half-points (e.g., 24 = 12pt)
    public var color: String // hex color without #
    
    public init(
        name: String = "Calibri",
        size: Int = 24, // 12pt
        color: String = "000000" // black
    ) {
        self.name = name
        self.size = size
        self.color = color
    }
}

public struct LineSpacing {
    public var type: LineSpacingType
    public var value: Int? // for "atLeast" and "exactly" types
    
    public init(
        type: LineSpacingType = .auto,
        value: Int? = nil
    ) {
        self.type = type
        self.value = value
    }
}

public enum LineSpacingType {
    case auto
    case atLeast
    case exactly
    case multiple
    
    var xmlValue: String {
        switch self {
        case .auto: return "auto"
        case .atLeast: return "atLeast"
        case .exactly: return "exactly"
        case .multiple: return "multiple"
        }
    }
}

public struct HeadingStyles {
    public var h1: HeadingStyle
    public var h2: HeadingStyle
    public var h3: HeadingStyle
    public var h4: HeadingStyle
    public var h5: HeadingStyle
    public var h6: HeadingStyle
    
    public init(
        h1: HeadingStyle = HeadingStyle(level: 1),
        h2: HeadingStyle = HeadingStyle(level: 2),
        h3: HeadingStyle = HeadingStyle(level: 3),
        h4: HeadingStyle = HeadingStyle(level: 4),
        h5: HeadingStyle = HeadingStyle(level: 5),
        h6: HeadingStyle = HeadingStyle(level: 6)
    ) {
        self.h1 = h1
        self.h2 = h2
        self.h3 = h3
        self.h4 = h4
        self.h5 = h5
        self.h6 = h6
    }
    
    public func style(for level: Int) -> HeadingStyle {
        switch level {
        case 1: return h1
        case 2: return h2
        case 3: return h3
        case 4: return h4
        case 5: return h5
        case 6: return h6
        default: return h1
        }
    }
}

public struct HeadingStyle {
    public var level: Int
    public var font: FontConfig
    public var spacing: Spacing
    public var keepWithNext: Bool
    public var keepLines: Bool
    
    public init(
        level: Int,
        font: FontConfig? = nil,
        spacing: Spacing = Spacing(),
        keepWithNext: Bool = true,
        keepLines: Bool = true
    ) {
        self.level = level
        self.font = font ?? FontConfig(
            name: "Calibri",
            size: max(32 - (level - 1) * 4, 16), // Decreasing size for each level
            color: "000000"
        )
        self.spacing = spacing
        self.keepWithNext = keepWithNext
        self.keepLines = keepLines
    }
}

public struct ParagraphStyles {
    public var normal: ParagraphStyle
    public var spacing: Spacing
    
    public init(
        normal: ParagraphStyle = ParagraphStyle(),
        spacing: Spacing = Spacing()
    ) {
        self.normal = normal
        self.spacing = spacing
    }
}

public struct ParagraphStyle {
    public var font: FontConfig
    public var alignment: TextAlignment
    public var indentation: Indentation
    
    public init(
        font: FontConfig = FontConfig(),
        alignment: TextAlignment = .left,
        indentation: Indentation = Indentation()
    ) {
        self.font = font
        self.alignment = alignment
        self.indentation = indentation
    }
}

public struct CodeBlockStyles {
    public var font: FontConfig
    public var background: String // hex color
    public var border: Border
    public var indentation: Indentation
    public var spacing: Spacing
    
    public init(
        font: FontConfig = FontConfig(name: "Consolas", size: 20, color: "C7254E"),
        background: String = "F5F5F5",
        border: Border = Border(),
        indentation: Indentation = Indentation(left: 720, right: 720),
        spacing: Spacing = Spacing(before: 120, after: 120)
    ) {
        self.font = font
        self.background = background
        self.border = border
        self.indentation = indentation
        self.spacing = spacing
    }
}

public struct BlockquoteStyles {
    public var font: FontConfig
    public var border: Border
    public var indentation: Indentation
    public var spacing: Spacing
    
    public init(
        font: FontConfig = FontConfig(size: 24, color: "000000"),
        border: Border = Border(left: BorderSide(width: 8, color: "CCCCCC")),
        indentation: Indentation = Indentation(left: 720, right: 720),
        spacing: Spacing = Spacing(before: 120, after: 120)
    ) {
        self.font = font
        self.border = border
        self.indentation = indentation
        self.spacing = spacing
    }
}

public struct TableStyles {
    public var border: Border
    public var cellPadding: Int // in twips
    public var headerStyle: FontConfig
    public var bodyStyle: FontConfig
    
    public init(
        border: Border = Border(),
        cellPadding: Int = 120,
        headerStyle: FontConfig = FontConfig(size: 24, color: "000000"),
        bodyStyle: FontConfig = FontConfig(size: 24, color: "000000")
    ) {
        self.border = border
        self.cellPadding = cellPadding
        self.headerStyle = headerStyle
        self.bodyStyle = bodyStyle
    }
}

public struct ListStyles {
    public var bulletFont: FontConfig
    public var numberedFont: FontConfig
    public var indentation: Int // in twips
    
    public init(
        bulletFont: FontConfig = FontConfig(),
        numberedFont: FontConfig = FontConfig(),
        indentation: Int = 720
    ) {
        self.bulletFont = bulletFont
        self.numberedFont = numberedFont
        self.indentation = indentation
    }
}

// MARK: - Supporting Structures

public struct Spacing {
    public var before: Int // in twips
    public var after: Int // in twips
    public var line: Int? // line spacing in twips
    
    public init(
        before: Int = 0,
        after: Int = 0,
        line: Int? = nil
    ) {
        self.before = before
        self.after = after
        self.line = line
    }
}

public struct Indentation {
    public var left: Int // in twips
    public var right: Int // in twips
    public var firstLine: Int? // in twips
    public var hanging: Int? // in twips
    
    public init(
        left: Int = 0,
        right: Int = 0,
        firstLine: Int? = nil,
        hanging: Int? = nil
    ) {
        self.left = left
        self.right = right
        self.firstLine = firstLine
        self.hanging = hanging
    }
}

public struct Border {
    public var top: BorderSide?
    public var right: BorderSide?
    public var bottom: BorderSide?
    public var left: BorderSide?
    
    public init(
        top: BorderSide? = nil,
        right: BorderSide? = nil,
        bottom: BorderSide? = nil,
        left: BorderSide? = nil
    ) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
}

public struct BorderSide {
    public var width: Int // in eighths of a point
    public var color: String // hex color
    public var style: BorderStyle
    
    public init(
        width: Int = 4,
        color: String = "000000",
        style: BorderStyle = .single
    ) {
        self.width = width
        self.color = color
        self.style = style
    }
}

public enum BorderStyle {
    case single
    case double
    case dashed
    case dotted
    
    var xmlValue: String {
        switch self {
        case .single: return "single"
        case .double: return "double"
        case .dashed: return "dashed"
        case .dotted: return "dotted"
        }
    }
}

public enum TextAlignment {
    case left
    case center
    case right
    case justify
    
    var xmlValue: String {
        switch self {
        case .left: return "left"
        case .center: return "center"
        case .right: return "right"
        case .justify: return "both"
        }
    }
}

// MARK: - Existing DocxElement Types

public enum DocxElement {
    case heading(level: Int, text: String)
    case paragraph(textRuns: [TextRun])
    case bulletList(items: [[TextRun]])
    case numberedList(items: [[TextRun]])
    case codeBlock(language: String?, code: String)
    case blockquote(textRuns: [TextRun])
    case table(rows: [TableRow])
    case horizontalRule
    case image(altText: String, source: String)
}

public struct TextRun {
    public let text: String
    public var isBold: Bool = false
    public var isItalic: Bool = false
    public var isUnderlined: Bool = false
    public var isStrikethrough: Bool = false
    public var isCode: Bool = false
    public var link: String? = nil
    
    public init(text: String, isBold: Bool = false, isItalic: Bool = false, isUnderlined: Bool = false, isStrikethrough: Bool = false, isCode: Bool = false, link: String? = nil) {
        self.text = text
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
        self.isStrikethrough = isStrikethrough
        self.isCode = isCode
        self.link = link
    }
}

public struct TableRow {
    public let cells: [TableCell]
    
    public init(cells: [TableCell]) {
        self.cells = cells
    }
}

public struct TableCell {
    public let content: [DocxElement]
    
    public init(content: [DocxElement]) {
        self.content = content
    }
}
