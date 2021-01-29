//
//  Assembler.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import Foundation

final class Assembler {
    private let assembly: String
    private let symbolTable: SymbolTable
    private let parser: Parser
    private var initialROMAddress: Int16 = 0
    private var initialRAMAddress: Int16 = 0
    private var hackCommands: [String] = []
    
    init(_ assembly: String) {
        self.assembly = assembly
        self.symbolTable = SymbolTable()
        self.parser = Parser(assembly: assembly)
    }
    
    public func assemble() -> String {
        assembleLCommand()
        parser.resetCursor()
        assembleCOrACommand()
        return hackCommands.joined(separator: "\n")
    }
    
    private func assembleLCommand() {
        while parser.hasMoreCommands {
            parser.advance()
            
            switch parser.commandPattern {
            case .l:
                symbolTable.addEntry(symbol: parser.symbol, address: initialROMAddress)
            default:
                initialROMAddress += 1
            }
        }
    }
    
    private func assembleCOrACommand() {
        while parser.hasMoreCommands {
            parser.advance()
            
            switch parser.commandPattern {
            case .a:
                if let val = Int16(parser.symbol)?.binaryString {
                    hackCommands.append(val)
                } else if symbolTable.contains(parser.symbol) {
                    if symbolTable.contains(parser.symbol) {
                        let value = symbolTable.getAddress(parser.symbol).binaryString
                        hackCommands.append(value)
                    } else {
                        symbolTable.addEntry(symbol: parser.symbol, address: initialRAMAddress)
                        hackCommands.append(initialRAMAddress.binaryString)
                        initialRAMAddress += 1
                    }
                }
            case .c:
                let compMnemonic = parser.comp
                let destMnemonic = parser.dest
                let jumpMnemonic = parser.jump
                
                let compBin = Code.comp(from: compMnemonic)
                let destBin = Code.dest(from: destMnemonic)
                let jumpBin = Code.jump(from: jumpMnemonic)
                let cInstruction = "111\(compBin)\(destBin)\(jumpBin)"
                hackCommands.append(cInstruction)
            default: fatalError("invalid command pattern")
            }
        }
    }
}

extension FixedWidthInteger {
    var binaryString: String {
        var result: [String] = []
        for i in 0..<(Self.bitWidth / 8) {
            let byte = UInt8(truncatingIfNeeded: self >> (i * 8))
            let byteString = String(byte, radix: 2)
            let padding = String(repeating: "0",
                                 count: 8 - byteString.count)
            result.append(padding + byteString)
        }
        
        return result.reversed().joined(separator: "")
    }
}
