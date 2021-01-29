//
//  PathExtensions.swift
//  Assembler
//
//  Created by Masato TSUTSUMI on 2021/01/29.
//

import ArgumentParser
import SwiftIO

extension Path: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument)
    }
}
