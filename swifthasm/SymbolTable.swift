//
//  SymbolTable.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import Foundation

final class SymbolTable {
    private(set) var table: [String: Int16] = [:]
    
    init() {
        (0...15).forEach { table["R\($0!)"] = $0 }
        table["SCREEN"] = 16384
        table["KBD"] = 24576
    }
    
    public func addEntry(symbol: String, address: Int16) {
        table[symbol] = address
    }
    
    public func contains(_ symbol: String) -> Bool {
        if let _ = findAlias(symbol) { return true }
        return table[symbol] != nil
    }
    
    public func getAddress(_ symbol: String) -> Int16 {
        guard let alias = findAlias(symbol) else {
            guard let address = table[symbol] else { fatalError("symbol not found on function getAddress") }
            return address
        }
        return alias
    }
    
    private func findAlias(_ symbol: String) -> Int16? {
        switch symbol {
        case "SP": return table["R0"]
        case "LCL": return table["R1"]
        case "ARG": return table["R2"]
        case "THIS": return table["R3"]
        case "THAT": return table["R4"]
        default: return nil
        }
    }
}
