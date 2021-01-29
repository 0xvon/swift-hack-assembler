//
//  AssemblerFormatter.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import Foundation

final class AssemblerFormatter {
    private var lines: [String]
    public var text: String {
        get { lines.joined(separator: "\n") }
    }
    
    init(source: String) {
        lines = source.components(separatedBy: "\n")
    }
    
    public func apply() {
        removeComments()
        removeWhiteSpaces()
        removeEmptyLines()
    }
    
    private func removeComments() {
        lines = lines.compactMap { line in
            guard line.contains("//") else { return line }
            let firstSlashIndex = line.firstIndex(of: "/")!
            return String(line[line.startIndex..<firstSlashIndex])
        }
    }
    
    private func removeWhiteSpaces() {
        lines = lines.compactMap { $0.replacingOccurrences(of: " ", with: "") }
    }
    
    private func removeEmptyLines() {
        lines = lines.compactMap { line in
            line.isEmpty ? nil : line
        }
    }
}
