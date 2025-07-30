import XCTest
import ZIPFoundation
@testable import MarkdownToDocx

final class ResumeMarkdownTests: XCTestCase {
    
    // Helper function to extract document.xml from DOCX data
    private func extractDocumentXml(from docxData: Data) throws -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("temp.docx")
        try docxData.write(to: tempURL)
        
        let archive = try Archive(url: tempURL, accessMode: .read)
        guard let documentEntry = archive["word/document.xml"] else {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find document.xml"])
        }
        
        let extractURL = tempDir.appendingPathComponent("document.xml")
        try archive.extract(documentEntry, to: extractURL)
        let documentData = try Data(contentsOf: extractURL)
        let documentString = String(data: documentData, encoding: .utf8) ?? ""
        
        // Clean up
        try FileManager.default.removeItem(at: tempURL)
        try FileManager.default.removeItem(at: extractURL)
        
        return documentString
    }
    
    func testResumeMarkdownConversion() throws {
        let markdown = """
        # Riyad Shauk | [riyadshauk.com](https://riyadshauk.com/consulting)
        [e] riyad.shauk@gmail.com | Los Angeles, CA, USA | U.S. Citizen | [c] 310-866-6284 | [GitHub: riyadshauk](https://github.com/riyadshauk) | [LinkedIn: riyadshauk](https://www.linkedin.com/in/riyadshauk)

        ## Professional Summary
        Backend & Full-Stack SWE with 5 years of experience. Skilled in TypeScript (Node.js), Next.js, React.js, and utilizing cloud services to solve business problems. Strong collaborator passionate about building robust, impactful and innovative software solutions.

        ## Work Experience
        **AI Coach & Developer**  
        **Consultant** – Los Angeles, CA  
        *2024 – Present*  
        Tech Stack: Go, TypeScript, JavaScript, React, Swift UI, OpenAI API, Python, and others

        - Working on AI-powered game development with students from Crossroads
        - Developing a full-stack iOS app for resume tailoring (Swift + Go + React / TypeScript) - MVP is complete and operational

        **Senior Software Engineer**  
        **A-Mark Precious Metals** – El Segundo, CA  
        *2023 – 2024*  
        Tech Stack: C# .NET Framework, Pub/Sub architecture via Azure ServiceBus, Windows Services, Azure DevOps

        - Upgraded on-prem data transfer layer of .NET Framework web app to Azure ServiceBus, enhancing maintainability.
        - Introduced functional tests for Azure ServiceBus, improving system robustness and coverage.
        - Integrated changes into Windows services and front-end portal, ensuring seamless functionality across C# codebase.
        - Verified and debugged front-end application to ensure a smooth user experience post-upgrade.
        - Created deployment scripts and instructions & developed a comprehensive production cut-over timeline as a Gantt chart.

        **Backend Software Engineer II**  
        **Dr. Squatch** – Marina del Rey, CA  
        *2021 – 2023*  
        Tech Stack: TypeScript (Node.js) + AWS / Serverless

        - Built and owned back-end microservices and APIs for various business use cases within post-order processing.
        - Connected custom delivery data with Klaviyo to support personalized email campaigns.
        - Conducted dynamic order insert retention experiments to improve customer retention.
        - Developed a Slack-integrated observability service, reducing errors from 100s/day to ~3/week in production order processing.
        - Utilized Shopify GraphQL APIs, Recharge Subscriptions REST API, SQL, and Serverless Framework in TypeScript.
        - Executed tasks using serverless infrastructure: AWS Lambda, SQS Queue, EventBridge, SES, DynamoDB.
        - Scripted through hundreds of thousands of orders to automate and fix issues, saving significant manual effort.
        - Collaborated cross-functionally with Fulfillment and CX teams to ensure smooth project execution.

        **Software Engineer I**  
        **Principle Development Group Consulting (PDGC)** – Los Angeles, CA  
        *2020 – 2021*  
        Tech Stack: Go, Java Spring Boot, MySQL/Hibernate, Kafka, Couchbase

        - Collaborated on a team of 7 engineers to migrate DirecTV systems from Java + REST + SQL to Go + streaming + NoSQL.
        - Used Kafka to scale ingestion of 3M guide listings, 200K programs, and 200K celebrity records for data mapping and delivery.
        - Developed extensive unit testing suites for both Golang and Java Spring Boot services (including mocking).
        - Upgraded and deployed Go/Java microservices in production.
        - Created a Go microservice for XML/JSON set-top-box features supporting remote booking.
             

        **Cloud Full Stack Developer**  
        **Oracle** – Santa Monica, CA  
        *2018 – 2020*  
        Tech Stack: TypeScript (Node.js), Python, React  

        - Built POC applications showcasing Oracle Cloud capabilities, integrating services using TypeScript, Python, and React.

        **Video Genome Project** – Santa Monica, CA  
        **Node.js Software Developer Intern**  
        *Summer 2015, Summer 2016*

        - Developed and deployed code for web scraping and ETL, optimizing data pipelines for a B2B movie analytics platform.

        ## Skills
        - **Languages:** TypeScript, JavaScript/Node.js, Go, [Python](https://github.com/riyadshauk/workout-sync) & Django, C#, Java, BASH (CLI tools), PowerShell, [some Rust](https://github.com/riyadshauk/leetcode_rust)  
        - **Frameworks:** React.js (HTML, CSS) + Next.js, [Redux](https://github.com/riyadshauk/oracle-digital-assistant-flow-builder), Jest, Prisma, Nest.js, Express, Shadcn/Tailwind CSS  
        - **Data Systems:** SQL, NoSQL, Kafka, SQS Queues, DynamoDB, AWS Lambda, MongoDB, PostgreSQL, Redis, Supabase  
        - **Concepts:** OOP, SOLID, Caching, System Design, Gen AI (RAG, Prompt Engineering, Vector Databases)

        ## Education
        University of Illinois at Urbana-Champaign  
        Bachelor of Science in Math and Computer Science *(December 2017)*

        ## Certificates
        - Triplebyte Certified SWE Generalist 
        - Oracle Cloud Infrastructure 2018 Certified Architect Associate
        """
        
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        // Verify the DOCX file is not empty
        XCTAssertGreaterThan(docxData.count, 0, "DOCX data should not be empty")
        
        let documentXml = try extractDocumentXml(from: docxData)
        
        // Test main heading (H1)
        XCTAssertTrue(documentXml.contains("<w:pStyle w:val=\"Heading1\"/>"), "Should contain H1 heading style")
        XCTAssertTrue(documentXml.contains("Riyad Shauk"), "Should contain the main heading text")
        
        // Test subheadings (H2)
        XCTAssertTrue(documentXml.contains("<w:pStyle w:val=\"Heading2\"/>"), "Should contain H2 heading style")
        XCTAssertTrue(documentXml.contains("Professional Summary"), "Should contain Professional Summary heading")
        XCTAssertTrue(documentXml.contains("Work Experience"), "Should contain Work Experience heading")
        XCTAssertTrue(documentXml.contains("Skills"), "Should contain Skills heading")
        XCTAssertTrue(documentXml.contains("Education"), "Should contain Education heading")
        XCTAssertTrue(documentXml.contains("Certificates"), "Should contain Certificates heading")
        
        // Test bold text
        XCTAssertTrue(documentXml.contains("<w:b/>"), "Should contain bold formatting")
        XCTAssertTrue(documentXml.contains("AI Coach"), "Should contain bold job title part")
        XCTAssertTrue(documentXml.contains("Developer"), "Should contain bold job title part")
        XCTAssertTrue(documentXml.contains("Consultant"), "Should contain bold job title")
        XCTAssertTrue(documentXml.contains("Languages:"), "Should contain bold skill categories")
        XCTAssertTrue(documentXml.contains("Frameworks:"), "Should contain bold skill categories")
        XCTAssertTrue(documentXml.contains("Data Systems:"), "Should contain bold skill categories")
        XCTAssertTrue(documentXml.contains("Concepts:"), "Should contain bold skill categories")
        
        // Test italic text
        XCTAssertTrue(documentXml.contains("<w:i/>"), "Should contain italic formatting")
        XCTAssertTrue(documentXml.contains("2024 – Present"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("2023 – 2024"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("2021 – 2023"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("2020 – 2021"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("2018 – 2020"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("Summer 2015, Summer 2016"), "Should contain italic dates")
        XCTAssertTrue(documentXml.contains("December 2017"), "Should contain italic graduation date")
        
        // Test bullet points (unordered lists)
        XCTAssertTrue(documentXml.contains("<w:numPr>"), "Should contain numbered list properties")
        XCTAssertTrue(documentXml.contains("<w:ilvl w:val=\"0\"/>"), "Should contain list level indicators")
        XCTAssertTrue(documentXml.contains("Working on AI-powered game development"), "Should contain bullet point content")
        XCTAssertTrue(documentXml.contains("Developing a full-stack iOS app"), "Should contain bullet point content")
        XCTAssertTrue(documentXml.contains("Upgraded on-prem data transfer layer"), "Should contain bullet point content")
        XCTAssertTrue(documentXml.contains("Built and owned back-end microservices"), "Should contain bullet point content")
        XCTAssertTrue(documentXml.contains("Triplebyte Certified SWE Generalist"), "Should contain bullet point content")
        
        // Test links (should appear as plain text)
        XCTAssertFalse(documentXml.contains("<w:hyperlink"), "Should not contain hyperlink elements")
        XCTAssertTrue(documentXml.contains("riyadshauk.com"), "Should contain link text")
        XCTAssertTrue(documentXml.contains("GitHub: riyadshauk"), "Should contain link text")
        XCTAssertTrue(documentXml.contains("LinkedIn: riyadshauk"), "Should contain link text")
        XCTAssertTrue(documentXml.contains("Python"), "Should contain link text")
        XCTAssertTrue(documentXml.contains("some Rust"), "Should contain link text")
        XCTAssertTrue(documentXml.contains("Redux"), "Should contain link text")
        
        // Test contact information
        XCTAssertTrue(documentXml.contains("riyad.shauk@gmail.com"), "Should contain email")
        XCTAssertTrue(documentXml.contains("Los Angeles, CA, USA"), "Should contain location")
        XCTAssertTrue(documentXml.contains("U.S. Citizen"), "Should contain citizenship")
        XCTAssertTrue(documentXml.contains("310-866-6284"), "Should contain phone number")
        
        // Test job titles and companies (from the simplified test markdown)
        XCTAssertTrue(documentXml.contains("Consultant"), "Should contain job title")
        XCTAssertTrue(documentXml.contains("Los Angeles, CA"), "Should contain job location")
        
        // Test education
        XCTAssertTrue(documentXml.contains("University of Illinois at Urbana-Champaign"), "Should contain university name")
        XCTAssertTrue(documentXml.contains("Bachelor of Science in Math and Computer Science"), "Should contain degree")
        
        // Test skills section (from the simplified test markdown)
        XCTAssertTrue(documentXml.contains("TypeScript"), "Should contain programming language")
        XCTAssertTrue(documentXml.contains("JavaScript/Node.js"), "Should contain programming language")
        XCTAssertTrue(documentXml.contains("Go"), "Should contain programming language")
        XCTAssertTrue(documentXml.contains("React.js"), "Should contain framework")
        XCTAssertTrue(documentXml.contains("Next.js"), "Should contain framework")
        XCTAssertTrue(documentXml.contains("SQL"), "Should contain data system")
        XCTAssertTrue(documentXml.contains("NoSQL"), "Should contain data system")
        XCTAssertTrue(documentXml.contains("AWS Lambda"), "Should contain cloud service")
        
        // Test certificates (from the simplified test markdown)
        XCTAssertTrue(documentXml.contains("Triplebyte Certified SWE Generalist"), "Should contain certificate")
        
        // Test time periods (from the simplified test markdown)
        XCTAssertTrue(documentXml.contains("2024 – Present"), "Should contain current time period")
    }
    
    func testResumeMarkdownStructure() throws {
        let markdown = """
        # Riyad Shauk | [riyadshauk.com](https://riyadshauk.com/consulting)
        [e] riyad.shauk@gmail.com | Los Angeles, CA, USA | U.S. Citizen | [c] 310-866-6284 | [GitHub: riyadshauk](https://github.com/riyadshauk) | [LinkedIn: riyadshauk](https://www.linkedin.com/in/riyadshauk)

        ## Professional Summary
        Backend & Full-Stack SWE with 5 years of experience.

        ## Work Experience
        **AI Coach & Developer**  
        **Consultant** – Los Angeles, CA  
        *2024 – Present*

        - Working on AI-powered game development
        - Developing a full-stack iOS app

        ## Skills
        - **Languages:** TypeScript, JavaScript/Node.js, Go
        - **Frameworks:** React.js, Next.js
        - **Data Systems:** SQL, NoSQL, AWS Lambda

        ## Education
        University of Illinois at Urbana-Champaign  
        Bachelor of Science in Math and Computer Science *(December 2017)*

        ## Certificates
        - Triplebyte Certified SWE Generalist
        """
        
        let converter = MarkdownToDocxConverter()
        let docxData = try converter.convert(markdown: markdown)
        
        let documentXml = try extractDocumentXml(from: docxData)
        
        // Test document structure - should have proper paragraph breaks
        let paragraphs = documentXml.components(separatedBy: "<w:p>")
        XCTAssertGreaterThan(paragraphs.count, 15, "Should have multiple paragraphs")
        
        // Test that headings are properly separated from content
        XCTAssertTrue(documentXml.contains("</w:p>"), "Should have proper paragraph closing tags")
        
        // Test that lists are properly formatted
        XCTAssertTrue(documentXml.contains("<w:numPr>"), "Should have numbered list properties")
        XCTAssertTrue(documentXml.contains("<w:ilvl w:val=\"0\"/>"), "Should have list level indicators")
        
        // Test that bold and italic formatting is applied correctly
        XCTAssertTrue(documentXml.contains("<w:b/>"), "Should have bold formatting")
        XCTAssertTrue(documentXml.contains("<w:i/>"), "Should have italic formatting")
        
        // Test that links are handled as plain text
        XCTAssertFalse(documentXml.contains("<w:hyperlink"), "Should not have hyperlink elements")
        XCTAssertTrue(documentXml.contains("riyadshauk.com"), "Should contain link text")
    }
    
    func testResumeMarkdownPerformance() throws {
        let markdown = """
        # Riyad Shauk | [riyadshauk.com](https://riyadshauk.com/consulting)
        [e] riyad.shauk@gmail.com | Los Angeles, CA, USA | U.S. Citizen | [c] 310-866-6284 | [GitHub: riyadshauk](https://github.com/riyadshauk) | [LinkedIn: riyadshauk](https://www.linkedin.com/in/riyadshauk)

        ## Professional Summary
        Backend & Full-Stack SWE with 5 years of experience. Skilled in TypeScript (Node.js), Next.js, React.js, and utilizing cloud services to solve business problems. Strong collaborator passionate about building robust, impactful and innovative software solutions.

        ## Work Experience
        **AI Coach & Developer**  
        **Consultant** – Los Angeles, CA  
        *2024 – Present*  
        Tech Stack: Go, TypeScript, JavaScript, React, Swift UI, OpenAI API, Python, and others

        - Working on AI-powered game development with students from Crossroads
        - Developing a full-stack iOS app for resume tailoring (Swift + Go + React / TypeScript) - MVP is complete and operational

        ## Skills
        - **Languages:** TypeScript, JavaScript/Node.js, Go, [Python](https://github.com/riyadshauk/workout-sync) & Django, C#, Java, BASH (CLI tools), PowerShell, [some Rust](https://github.com/riyadshauk/leetcode_rust)  
        - **Frameworks:** React.js (HTML, CSS) + Next.js, [Redux](https://github.com/riyadshauk/oracle-digital-assistant-flow-builder), Jest, Prisma, Nest.js, Express, Shadcn/Tailwind CSS  
        - **Data Systems:** SQL, NoSQL, Kafka, SQS Queues, DynamoDB, AWS Lambda, MongoDB, PostgreSQL, Redis, Supabase  
        - **Concepts:** OOP, SOLID, Caching, System Design, Gen AI (RAG, Prompt Engineering, Vector Databases)

        ## Education
        University of Illinois at Urbana-Champaign  
        Bachelor of Science in Math and Computer Science *(December 2017)*

        ## Certificates
        - Triplebyte Certified SWE Generalist 
        - Oracle Cloud Infrastructure 2018 Certified Architect Associate
        """
        
        let converter = MarkdownToDocxConverter()
        
        // Measure performance
        let startTime = CFAbsoluteTimeGetCurrent()
        let docxData = try converter.convert(markdown: markdown)
        let endTime = CFAbsoluteTimeGetCurrent()
        
        let conversionTime = endTime - startTime
        
        // Verify the conversion completed successfully
        XCTAssertGreaterThan(docxData.count, 0, "DOCX data should not be empty")
        
        // Performance assertion - should complete within reasonable time (adjust threshold as needed)
        XCTAssertLessThan(conversionTime, 5.0, "Conversion should complete within 5 seconds")
        
        print("Resume markdown conversion completed in \(conversionTime) seconds")
        print("Generated DOCX size: \(docxData.count) bytes")
    }
} 