//
//  main.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import Foundation
import ArgumentParser
import SwiftIO

struct SwiftHackAssembler: ParsableCommand {
    @Argument(help: "the assembly file path like xxx.asm")
    var paths: [Path]
    
    // Now just support for non-binary assembling
    @Flag(name: .shortAndLong, help: "Output binary files with a .bhack extension.")
    var isBinary: Bool
    
    static var configuration = CommandConfiguration(
        commandName: "Assembler",
        abstract: "Output hack assembled code",
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )
    
    func validate() throws {
        if paths.isEmpty { throw ValidationError("At least one path must be specified") }
        try paths.forEach { path in
            guard path.extension == "asm" else { throw ValidationError("Hack assemble files must use the extension '.asm'.") }
        }
    }
    
    func handleWriteError(_ error: POSIXError) {
        errorPrint("warning: Write failed:", error)
    }
    
    func run() throws {
        try paths.forEach { path in
            print("Let's assemble \(path.rawValue)")
            
            var destination = path
            destination.extension = isBinary ? "bhack" : "hack"
            
            try FileHandle.open(path) { file in
                file.writeErrorHandler = handleWriteError
                let assembly: String = try {
                    var assems: [String] = []
                    while let line = try file.readLine(strippingNewline: true) { assems.append(line) }
                    return assems.joined(separator: "\n")
                }()
                
                let assembler = Assembler(assembly)
                let hackCodes = assembler.assemble().split(separator: "\n")
                
                try FileHandle.open(destination, mode: .truncate, isBinary: isBinary) { destination in
                    destination.writeErrorHandler = handleWriteError
                    
                    hackCodes.forEach { hackCode in
                        if isBinary {
//                            try withUnsafeBytes(of: &hackCode, destination.write)
                        } else {
                            print(hackCode, to: &destination)
                        }
                    }
                }
                print("✅ exported file to \(destination.rawValue)")
            }
        }
    }
}

SwiftHackAssembler.main()
