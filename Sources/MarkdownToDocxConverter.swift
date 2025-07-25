//
//  MarkdownToDocxConverter.swift
//  MarkdownToDocx
//
//  Created by Riyad Shauk on 7/23/25.
//

import Foundation
import Markdown
import ZIPFoundation

public class MarkdownToDocxConverter {
    
    public init() {}
    
    public func convert(markdown: String) throws -> Data {
        let document = Document(parsing: markdown)
        let elements = try parseDocument(document)
        let links = extractLinks(from: elements)
        return try generateDocx(elements: elements, links: links)
    }
    
    public func convert(markdownFile url: URL) throws -> Data {
        let markdown = try String(contentsOf: url)
        return try convert(markdown: markdown)
    }
    
    private func parseDocument(_ document: Document) throws -> [DocxElement] {
        var elements: [DocxElement] = []
        
        for child in document.children {
            if let element = try parseBlock(child) {
                elements.append(element)
            }
        }
        
        return elements
    }
    
    private func extractLinks(from elements: [DocxElement]) -> [String] {
        var links: [String] = []
        
        func extractLinksFromElement(_ element: DocxElement) {
            switch element {
            case let .paragraph(textRuns):
                for textRun in textRuns {
                    if let link = textRun.link, !link.isEmpty {
                        links.append(link)
                    }
                }
            case let .bulletList(items):
                for item in items {
                    for textRun in item {
                        if let link = textRun.link, !link.isEmpty {
                            links.append(link)
                        }
                    }
                }
            case let .numberedList(items):
                for item in items {
                    for textRun in item {
                        if let link = textRun.link, !link.isEmpty {
                            links.append(link)
                        }
                    }
                }
            case let .blockquote(textRuns):
                for textRun in textRuns {
                    if let link = textRun.link, !link.isEmpty {
                        links.append(link)
                    }
                }
            case let .table(rows):
                for row in rows {
                    for cell in row.cells {
                        for element in cell.content {
                            extractLinksFromElement(element)
                        }
                    }
                }
            default:
                break
            }
        }
        
        for element in elements {
            extractLinksFromElement(element)
        }
        
        return links
    }
    
    private func parseBlock(_ block: Markup) throws -> DocxElement? {
        switch block {
        case let heading as Heading:
            return .heading(level: heading.level, text: heading.plainText)
            
        case let paragraph as Paragraph:
            let textRuns = try parseInlineElements(Array(paragraph.children))
            return .paragraph(textRuns: textRuns)
            
        case let list as UnorderedList:
            let items = try list.children.map { listItem in
                try parseListItem(listItem)
            }
            return .bulletList(items: items)
            
        case let list as OrderedList:
            let items = try list.children.map { listItem in
                try parseListItem(listItem)
            }
            return .numberedList(items: items)
            
        case let codeBlock as CodeBlock:
            return .codeBlock(language: codeBlock.language, code: codeBlock.code)
            
        case let blockquote as BlockQuote:
            // Blockquotes can contain multiple paragraphs, so we need to handle them properly
            var allTextRuns: [TextRun] = []
            for child in blockquote.children {
                if let paragraph = child as? Paragraph {
                    let textRuns = try parseInlineElements(Array(paragraph.children))
                    allTextRuns.append(contentsOf: textRuns)
                } else if let text = child as? Text {
                    allTextRuns.append(TextRun(text: text.string))
                }
            }
            return .blockquote(textRuns: allTextRuns)
            
        case let table as Table:
            let rows = try parseTable(table)
            return .table(rows: rows)
            
        case is ThematicBreak:
            return .horizontalRule
            
        case let image as Image:
            return .image(altText: image.plainText, source: image.source ?? "")
            
        default:
            // For any other block elements, try to parse as paragraph
            if let paragraph = block as? Paragraph {
                let textRuns = try parseInlineElements(Array(paragraph.children))
                return .paragraph(textRuns: textRuns)
            }
            return nil
        }
    }
    
    private func parseListItem(_ listItem: Markup) throws -> [TextRun] {
        var textRuns: [TextRun] = []
        
        for child in listItem.children {
            if let paragraph = child as? Paragraph {
                let runs = try parseInlineElements(Array(paragraph.children))
                textRuns.append(contentsOf: runs)
            } else if let text = child as? Text {
                textRuns.append(TextRun(text: text.string))
            } else if let element = try parseInlineElement(child) {
                textRuns.append(element)
            }
        }
        
        return textRuns
    }
    
    private func parseInlineElements(_ elements: [Markup]) throws -> [TextRun] {
        var textRuns: [TextRun] = []
        
        for element in elements {
            if let textRun = try parseInlineElement(element) {
                textRuns.append(textRun)
            }
        }
        
        return textRuns
    }
    
    private func parseInlineElement(_ element: Markup) throws -> TextRun? {
        switch element {
        case let text as Text:
            return TextRun(text: text.string)
            
        case let emphasis as Emphasis:
            let childText = try parseInlineElements(Array(emphasis.children))
            return childText.first?.withItalic(true)
            
        case let strong as Strong:
            let childText = try parseInlineElements(Array(strong.children))
            return childText.first?.withBold(true)
            
        case let strikethrough as Strikethrough:
            let childText = try parseInlineElements(Array(strikethrough.children))
            return childText.first?.withStrikethrough(true)
            
        case let code as InlineCode:
            return TextRun(text: code.code, isCode: true)
            
        case let link as Link:
            let childText = try parseInlineElements(Array(link.children))
            return childText.first?.withLink(link.destination)
            
        default:
            return nil
        }
    }
    
    private func parseTable(_ table: Table) throws -> [TableRow] {
        var rows: [TableRow] = []
        
        // Add header row - table.head is a single row, not a collection
        var headerCells: [TableCell] = []
        for cell in table.head.cells {
            let textRuns = try parseInlineElements(Array(cell.children))
            let paragraph = DocxElement.paragraph(textRuns: textRuns)
            headerCells.append(TableCell(content: [paragraph]))
        }
        rows.append(TableRow(cells: headerCells))
        
        // Add body rows
        for row in table.body.rows {
            var cells: [TableCell] = []
            
            for cell in row.cells {
                // Parse cell content as inline elements (text, formatting, etc.)
                let textRuns = try parseInlineElements(Array(cell.children))
                let paragraph = DocxElement.paragraph(textRuns: textRuns)
                cells.append(TableCell(content: [paragraph]))
            }
            
            rows.append(TableRow(cells: cells))
        }
        
        return rows
    }
    
    private func generateDocx(elements: [DocxElement], links: [String]) throws -> Data {
        let archive = try Archive(accessMode: .create)
        
        // Add required DOCX files
        try addDocxFiles(archive: archive, elements: elements, links: links)
        
        return archive.data ?? Data()
    }
    
    private func addDocxFiles(archive: Archive, elements: [DocxElement], links: [String]) throws {
        // Add [Content_Types].xml
        let contentTypes = generateContentTypesXml()
        try addFileToArchive(archive: archive, path: "[Content_Types].xml", content: contentTypes)
        
        // Add _rels/.rels
        let rels = generateRelsXml()
        try addFileToArchive(archive: archive, path: "_rels/.rels", content: rels)
        
        // Add word/_rels/document.xml.rels
        let documentRels = generateDocumentRelsXml(links: links)
        try addFileToArchive(archive: archive, path: "word/_rels/document.xml.rels", content: documentRels)
        
        // Add word/document.xml
        let document = generateDocumentXml(elements: elements, links: links)
        try addFileToArchive(archive: archive, path: "word/document.xml", content: document)
        
        // Add word/styles.xml
        let styles = generateStylesXml()
        try addFileToArchive(archive: archive, path: "word/styles.xml", content: styles)
    }
    
    private func addFileToArchive(archive: Archive, path: String, content: String) throws {
        guard let data = content.data(using: .utf8) else {
            throw DocxError.encodingError
        }
        
        try archive.addEntry(with: path, type: .file, uncompressedSize: Int64(data.count), bufferSize: 4) { position, size in
            return data.subdata(in: Data.Index(position)..<Int(position)+size)
        }
    }
    
    private func generateContentTypesXml() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
            <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
            <Default Extension="xml" ContentType="application/xml"/>
            <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
            <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
        </Types>
        """
    }
    
    private func generateRelsXml() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
        </Relationships>
        """
    }
    
    private func generateDocumentRelsXml(links: [String]) -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
        </Relationships>
        """
    }
    
    private func generateDocumentXml(elements: [DocxElement], links: [String]) -> String {
        var bodyContent = ""
        
        for element in elements {
            bodyContent += generateElementXml(element, links: links)
        }
        
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:body>
                \(bodyContent)
            </w:body>
        </w:document>
        """
    }
    
    private func generateElementXml(_ element: DocxElement, links: [String]) -> String {
        switch element {
        case let .heading(level, text):
            return """
            <w:p>
                <w:pPr>
                    <w:pStyle w:val="Heading\(level)"/>
                </w:pPr>
                <w:r>
                    <w:t>\(escapeXml(text))</w:t>
                </w:r>
            </w:p>
            """
            
        case let .paragraph(textRuns):
            var runs = ""
            for textRun in textRuns {
                runs += generateTextRunXml(textRun, links: links)
            }
            return """
            <w:p>
                \(runs)
            </w:p>
            """
            
        case let .bulletList(items):
            var listContent = ""
            for item in items {
                var runs = ""
                for textRun in item {
                    runs += generateTextRunXml(textRun, links: links)
                }
                listContent += """
                <w:p>
                    <w:pPr>
                        <w:numPr>
                            <w:ilvl w:val="0"/>
                            <w:numId w:val="1"/>
                        </w:numPr>
                    </w:pPr>
                    \(runs)
                </w:p>
                """
            }
            return listContent
            
        case let .numberedList(items):
            var listContent = ""
            for item in items {
                var runs = ""
                for textRun in item {
                    runs += generateTextRunXml(textRun, links: links)
                }
                listContent += """
                <w:p>
                    <w:pPr>
                        <w:numPr>
                            <w:ilvl w:val="0"/>
                            <w:numId w:val="2"/>
                        </w:numPr>
                    </w:pPr>
                    \(runs)
                </w:p>
                """
            }
            return listContent
            
        case let .codeBlock(_, code):
            return """
            <w:p>
                <w:pPr>
                    <w:pStyle w:val="CodeBlock"/>
                </w:pPr>
                <w:r>
                    <w:rPr>
                        <w:rStyle w:val="Code"/>
                    </w:rPr>
                    <w:t>\(escapeXml(code))</w:t>
                </w:r>
            </w:p>
            """
            
        case let .blockquote(textRuns):
            var runs = ""
            for textRun in textRuns {
                runs += generateTextRunXml(textRun, links: links)
            }
            return """
            <w:p>
                <w:pPr>
                    <w:pStyle w:val="Quote"/>
                </w:pPr>
                \(runs)
            </w:p>
            """
            
        case let .table(rows):
            var tableContent = ""
            for row in rows {
                tableContent += "<w:tr>"
                for cell in row.cells {
                    var cellContent = ""
                    for element in cell.content {
                        cellContent += generateElementXml(element, links: links)
                    }
                    tableContent += """
                    <w:tc>
                        <w:tcPr>
                            <w:tcW w:w="2000" w:type="dxa"/>
                        </w:tcPr>
                        \(cellContent)
                    </w:tc>
                    """
                }
                tableContent += "</w:tr>"
            }
            return """
            <w:tbl>
                <w:tblPr>
                    <w:tblStyle w:val="TableGrid"/>
                    <w:tblW w:w="0" w:type="auto"/>
                </w:tblPr>
                <w:tblGrid>
                    <w:gridCol w:w="2000"/>
                </w:tblGrid>
                \(tableContent)
            </w:tbl>
            """
            
        case .horizontalRule:
            return """
            <w:p>
                <w:pPr>
                    <w:pBdr>
                        <w:bottom w:val="single" w:sz="6" w:space="1" w:color="auto"/>
                    </w:pBdr>
                </w:pPr>
            </w:p>
            """
            
        case let .image(altText, _):
            return """
            <w:p>
                <w:r>
                    <w:drawing>
                        <wp:inline xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
                            <wp:extent cx="5486400" cy="3086400"/>
                            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                                <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                                    <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                                        <pic:nvPicPr>
                                            <pic:cNvPr id="0" name="\(escapeXml(altText))"/>
                                            <pic:cNvPicPr/>
                                        </pic:nvPicPr>
                                        <pic:blipFill>
                                            <a:blip r:embed="rId1"/>
                                        </pic:blipFill>
                                        <pic:spPr>
                                            <a:xfrm>
                                                <a:off x="0" y="0"/>
                                                <a:ext cx="5486400" cy="3086400"/>
                                            </a:xfrm>
                                        </pic:spPr>
                                    </pic:pic>
                                </a:graphicData>
                            </a:graphic>
                        </wp:inline>
                    </w:drawing>
                </w:r>
            </w:p>
            """
        }
    }
    
    private func generateTextRunXml(_ textRun: TextRun, links: [String]) -> String {
        var runProps = ""
        
        if textRun.isBold {
            runProps += "<w:b/>"
        }
        if textRun.isItalic {
            runProps += "<w:i/>"
        }
        if textRun.isUnderlined {
            runProps += "<w:u w:val=\"single\"/>"
        }
        if textRun.isStrikethrough {
            runProps += "<w:strike/>"
        }
        if textRun.isCode {
            runProps += "<w:rStyle w:val=\"Code\"/>"
        }
        
        let props = runProps.isEmpty ? "" : "<w:rPr>\(runProps)</w:rPr>"
        
        // Handle links - temporarily generate as plain text to avoid corruption
        if let link = textRun.link, !link.isEmpty {
            // For now, just generate the text with link styling but no actual hyperlink
            var linkRunProps = "<w:color w:val=\"0000FF\"/><w:u w:val=\"single\"/>"
            if textRun.isBold {
                linkRunProps += "<w:b/>"
            }
            if textRun.isItalic {
                linkRunProps += "<w:i/>"
            }
            if textRun.isStrikethrough {
                linkRunProps += "<w:strike/>"
            }
            if textRun.isCode {
                linkRunProps += "<w:rStyle w:val=\"Code\"/>"
            }
            
            return """
            <w:r>
                <w:rPr>\(linkRunProps)</w:rPr>
                <w:t>\(escapeXml(textRun.text)) (\(escapeXml(link)))</w:t>
            </w:r>
            """
        }
        
        return """
        <w:r>
            \(props)
            <w:t>\(escapeXml(textRun.text))</w:t>
        </w:r>
        """
    }
    
    private func generateStylesXml() -> String {
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
            <w:docDefaults>
                <w:rPrDefault>
                    <w:rPr>
                        <w:rFonts w:ascii="Calibri" w:eastAsia="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
                        <w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/>
                    </w:rPr>
                </w:rPrDefault>
            </w:docDefaults>
            <w:latentStyles w:defLockedState="0" w:defUIPriority="99" w:defSemiHidden="0" w:defUnhideWhenUsed="0" w:defQFormat="0" w:count="371">
                <w:lsdException w:name="Normal" w:locked="0"/>
                <w:lsdException w:name="heading 1" w:semiHidden="0" w:uiPriority="9" w:unhideWhenUsed="0" w:qFormat="1"/>
                <w:lsdException w:name="heading 2" w:semiHidden="0" w:uiPriority="9" w:unhideWhenUsed="0" w:qFormat="1"/>
                <w:lsdException w:name="heading 3" w:semiHidden="0" w:uiPriority="9" w:unhideWhenUsed="0" w:qFormat="1"/>
            </w:latentStyles>
            <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
                <w:name w:val="Normal"/>
                <w:qFormat/>
            </w:style>
            <w:style w:type="paragraph" w:styleId="Heading1">
                <w:name w:val="heading 1"/>
                <w:basedOn w:val="Normal"/>
                <w:next w:val="Normal"/>
                <w:link w:val="Heading1Char"/>
                <w:uiPriority w:val="9"/>
                <w:qFormat/>
                <w:rsid w:val="00C847FE"/>
                <w:pPr>
                    <w:keepNext/>
                    <w:keepLines/>
                    <w:spacing w:before="240" w:after="0"/>
                    <w:outlineLvl w:val="0"/>
                </w:pPr>
                <w:rPr>
                    <w:b/>
                    <w:bCs/>
                    <w:kern w:val="32"/>
                    <w:sz w:val="32"/>
                    <w:szCs w:val="32"/>
                </w:rPr>
            </w:style>
            <w:style w:type="paragraph" w:styleId="Heading2">
                <w:name w:val="heading 2"/>
                <w:basedOn w:val="Normal"/>
                <w:next w:val="Normal"/>
                <w:link w:val="Heading2Char"/>
                <w:uiPriority w:val="9"/>
                <w:qFormat/>
                <w:rsid w:val="00C847FE"/>
                <w:pPr>
                    <w:keepNext/>
                    <w:keepLines/>
                    <w:spacing w:before="240" w:after="0"/>
                    <w:outlineLvl w:val="1"/>
                </w:pPr>
                <w:rPr>
                    <w:b/>
                    <w:bCs/>
                    <w:kern w:val="32"/>
                    <w:sz w:val="28"/>
                    <w:szCs w:val="28"/>
                </w:rPr>
            </w:style>
            <w:style w:type="paragraph" w:styleId="Heading3">
                <w:name w:val="heading 3"/>
                <w:basedOn w:val="Normal"/>
                <w:next w:val="Normal"/>
                <w:link w:val="Heading3Char"/>
                <w:uiPriority w:val="9"/>
                <w:qFormat/>
                <w:rsid w:val="00C847FE"/>
                <w:pPr>
                    <w:keepNext/>
                    <w:keepLines/>
                    <w:spacing w:before="240" w:after="0"/>
                    <w:outlineLvl w:val="2"/>
                </w:pPr>
                <w:rPr>
                    <w:b/>
                    <w:bCs/>
                    <w:kern w:val="32"/>
                    <w:sz w:val="24"/>
                    <w:szCs w:val="24"/>
                </w:rPr>
            </w:style>
            <w:style w:type="paragraph" w:styleId="CodeBlock">
                <w:name w:val="Code Block"/>
                <w:basedOn w:val="Normal"/>
                <w:rsid w:val="00C847FE"/>
                <w:pPr>
                    <w:spacing w:before="120" w:after="120"/>
                    <w:ind w:left="720" w:right="720"/>
                    <w:pBdr>
                        <w:top w:val="single" w:sz="4" w:space="1" w:color="CCCCCC"/>
                        <w:left w:val="single" w:sz="4" w:space="1" w:color="CCCCCC"/>
                        <w:bottom w:val="single" w:sz="4" w:space="1" w:color="CCCCCC"/>
                        <w:right w:val="single" w:sz="4" w:space="1" w:color="CCCCCC"/>
                    </w:pBdr>
                    <w:shd w:val="clear" w:color="auto" w:fill="F5F5F5"/>
                </w:pPr>
            </w:style>
            <w:style w:type="paragraph" w:styleId="Quote">
                <w:name w:val="Quote"/>
                <w:basedOn w:val="Normal"/>
                <w:rsid w:val="00C847FE"/>
                <w:pPr>
                    <w:spacing w:before="120" w:after="120"/>
                    <w:ind w:left="720" w:right="720"/>
                    <w:pBdr>
                        <w:left w:val="single" w:sz="8" w:space="4" w:color="CCCCCC"/>
                    </w:pBdr>
                </w:pPr>
                <w:rPr>
                    <w:i/>
                    <w:iCs/>
                </w:rPr>
            </w:style>
            <w:style w:type="character" w:styleId="Code">
                <w:name w:val="Code"/>
                <w:rsid w:val="00C847FE"/>
                <w:rPr>
                    <w:rFonts w:ascii="Consolas" w:eastAsia="Consolas" w:hAnsi="Consolas" w:cs="Consolas"/>
                    <w:color w:val="C7254E"/>
                    <w:shd w:val="clear" w:color="auto" w:fill="F9F2F4"/>
                </w:rPr>
            </w:style>
        </w:styles>
        """
    }
    
    private func escapeXml(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

// MARK: - Extensions

extension TextRun {
    func withBold(_ bold: Bool) -> TextRun {
        return TextRun(text: text, isBold: bold, isItalic: isItalic, isUnderlined: isUnderlined, isStrikethrough: isStrikethrough, isCode: isCode, link: link)
    }
    
    func withItalic(_ italic: Bool) -> TextRun {
        return TextRun(text: text, isBold: isBold, isItalic: italic, isUnderlined: isUnderlined, isStrikethrough: isStrikethrough, isCode: isCode, link: link)
    }
    
    func withStrikethrough(_ strikethrough: Bool) -> TextRun {
        return TextRun(text: text, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined, isStrikethrough: strikethrough, isCode: isCode, link: link)
    }
    
    func withLink(_ link: String?) -> TextRun {
        return TextRun(text: text, isBold: isBold, isItalic: isItalic, isUnderlined: isUnderlined, isStrikethrough: isStrikethrough, isCode: isCode, link: link)
    }
}

// MARK: - Errors

public enum DocxError: Error {
    case encodingError
    case archiveError
} 