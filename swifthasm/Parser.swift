//
//  Parser.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import Foundation

final class Parser {
    let commands: [String]
    public var currentCommand: String {
        get { commands[cursor] }
    }
    public var hasMoreCommands: Bool {
        get { cursor + 1 < commands.count }
    }
    public var commandPattern: CommandPattern {
        get { CommandPattern(currentCommand) }
    }
    public var symbol: String {
        precondition(commandPattern != .c)
        
        switch commandPattern {
        case .a:
            guard let atIndex = currentCommand.firstIndex(of: "@") else { fatalError("command pattern symbol failed") }
            return String(currentCommand[currentCommand.index(after: atIndex)...])
        case .l:
            guard let parenthesisStartIndex = currentCommand.firstIndex(of: "(") else { fatalError("command pattern symbol failed") }
            guard let parenthesisEndIndex = currentCommand.firstIndex(of: ")") else { fatalError("command pattern symbol failed") }
            let symbolStartIndex = currentCommand.index(after: parenthesisStartIndex)
            let symbolEndIndex = currentCommand.index(after: parenthesisEndIndex)
            
            return String(currentCommand[symbolStartIndex...symbolEndIndex])
        case .c:
            fatalError("unsupported command")
        }
    }
    public var dest: String {
        precondition(commandPattern == .c)
        
        guard let equalIndex = currentCommand.firstIndex(of: "=") else { return "null"}
        return String(currentCommand[..<equalIndex])
    }
    public var comp: String {
        precondition(commandPattern == .c)
        
        if let equalIndex = currentCommand.firstIndex(of: "=") {
            let compStartIndex = currentCommand.index(after: equalIndex)
            return String(currentCommand[compStartIndex...])
        } else if let semicolonIndex = currentCommand.firstIndex(of: ";") {
            return String(currentCommand[..<semicolonIndex])
        } else {
            fatalError("command pattern comp failed")
        }
    }
    public var jump: String {
        precondition(commandPattern == .c)
        
        guard let semicolonIndex = currentCommand.firstIndex(of: ";") else { return "null"}
        let jumpStartIndex = currentCommand.index(after: semicolonIndex)
        return String(currentCommand[jumpStartIndex...])
    }
    
    private var cursor: Int = 0
    
    init(assembly: String) {
        let formatter = AssemblerFormatter(source: assembly)
        formatter.apply()
        commands = formatter.text.isEmpty ? [] : [""] + formatter.text.components(separatedBy: "\n")
    }
    
    public func resetCursor() {
        cursor = 0
    }
    
    public func advance() {
        precondition(hasMoreCommands)
        cursor += 1
    }
}

public enum CommandPattern {
    case a
    case c
    case l
    
    init(_ command: String) {
        switch command.first {
        case "@": self = .a
        case "(": self = .l
        default: self = .c
        }
    }
}
