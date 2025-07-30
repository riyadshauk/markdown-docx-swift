#!/usr/bin/env swift

import Foundation
import MarkdownToDocx
import ZIPFoundation

// Test the resume markdown conversion with the full resume content
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

do {
    let converter = MarkdownToDocxConverter()
    let docxData = try converter.convert(markdown: markdown)
    
    print("DOCX Data size: \(docxData.count) bytes")
    
    // Save to Desktop for easy access
    let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let outputURL = desktopPath.appendingPathComponent("Riyad_Shauk_Resume.docx")
    
    try docxData.write(to: outputURL)
    print("✅ DOCX file saved to Desktop: \(outputURL.path)")
    print("📄 You can now open this file in Word, Pages, or any DOCX viewer!")
    
    // Also save to Documents as backup
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let backupURL = documentsPath.appendingPathComponent("Riyad_Shauk_Resume_Backup.docx")
    try docxData.write(to: backupURL)
    print("📁 Backup saved to Documents: \(backupURL.path)")
    
    // Try to extract and examine the content
    if let archive = try? Archive(url: outputURL, accessMode: .read) {
        print("✅ Successfully opened as ZIP archive")
        
        // Try to extract document.xml
        if let documentEntry = archive["word/document.xml"] {
            print("✅ Found document.xml")
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("resume_document.xml")
            try archive.extract(documentEntry, to: tempURL)
            
            let documentContent = try String(contentsOf: tempURL, encoding: .utf8)
            
            // Check for specific elements
            print("\n=== ANALYSIS ===")
            print("Contains <w:b/> (bold): \(documentContent.contains("<w:b/>"))")
            print("Contains <w:i/> (italic): \(documentContent.contains("<w:i/>"))")
            print("Contains 'AI Coach': \(documentContent.contains("AI Coach"))")
            print("Contains 'Developer': \(documentContent.contains("Developer"))")
            print("Contains 'Consultant': \(documentContent.contains("Consultant"))")
            print("Contains '2024 – Present': \(documentContent.contains("2024 – Present"))")
            print("Contains 'Languages:': \(documentContent.contains("Languages:"))")
            print("Contains 'Frameworks:': \(documentContent.contains("Frameworks:"))")
            print("Contains 'Data Systems:': \(documentContent.contains("Data Systems:"))")
            print("Contains 'December 2017': \(documentContent.contains("December 2017"))")
            print("Contains 'Triplebyte Certified': \(documentContent.contains("Triplebyte Certified"))")
            print("Contains 'Oracle Cloud Infrastructure': \(documentContent.contains("Oracle Cloud Infrastructure"))")
            
            // Count paragraphs
            let paragraphCount = documentContent.components(separatedBy: "<w:p>").count - 1
            print("Paragraph count: \(paragraphCount)")
            
            // Count headings
            let h1Count = documentContent.components(separatedBy: "<w:pStyle w:val=\"Heading1\"/>").count - 1
            let h2Count = documentContent.components(separatedBy: "<w:pStyle w:val=\"Heading2\"/>").count - 1
            print("H1 headings: \(h1Count)")
            print("H2 headings: \(h2Count)")
            
            // Count bullet points
            let bulletCount = documentContent.components(separatedBy: "<w:numPr>").count - 1
            print("Bullet points: \(bulletCount)")
            
            // Show a sample of the XML structure
            print("\n=== SAMPLE XML STRUCTURE ===")
            let lines = documentContent.components(separatedBy: "\n")
            let sampleLines = Array(lines.prefix(50)) // First 50 lines
            for (index, line) in sampleLines.enumerated() {
                print("\(index + 1): \(line)")
            }
            
            // Clean up
            try? FileManager.default.removeItem(at: tempURL)
        } else {
            print("❌ Could not find document.xml in archive")
        }
    } else {
        print("❌ Could not open as ZIP archive")
    }
    
    print("\n🎉 Resume DOCX generation complete!")
    print("📂 Check your Desktop for 'Riyad_Shauk_Resume.docx'")
    
} catch {
    print("❌ Error: \(error)")
} 