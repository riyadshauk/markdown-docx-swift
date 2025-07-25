//
//  DocxElement.swift
//  MarkdownToDocx
//
//  Created by Riyad Shauk on 7/23/25.
//

import Foundation

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
