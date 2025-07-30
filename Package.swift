// swift-tools-version:5.9
// 
// Package.swift
// MarkdownToDocx
//
// A Swift library for converting Markdown documents to DOCX format.
// https://github.com/riyadshauk/markdown-docx-swift
//
import PackageDescription

let package = Package(
    name: "MarkdownToDocx",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MarkdownToDocx", targets: ["MarkdownToDocx"]),
        .executable(name: "debug-docx", targets: ["DebugDocx"]),
        .executable(name: "debug-resume", targets: ["DebugResume"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19")
    ],
    targets: [
        .target(
            name: "MarkdownToDocx",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Sources"
        ),
        .executableTarget(
            name: "DebugDocx",
            dependencies: [
                "MarkdownToDocx",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Debug"
        ),
        .executableTarget(
            name: "DebugResume",
            dependencies: [
                "MarkdownToDocx",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "DebugResume"
        ),
        .testTarget(
            name: "MarkdownToDocxTests",
            dependencies: [
                "MarkdownToDocx",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Tests"
        )
    ]
)
