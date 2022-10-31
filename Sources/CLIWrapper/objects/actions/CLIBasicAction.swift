//
//  CLIBasicAction.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation
import struct CLICapture.CodeStackTrace

/// Helper object used to create a basic CLIActon from just
/// the handler function
public struct CLIBasicAction: CLIAction {
    private let handler: CLIActionHandler
    
    public init(_ handler: @escaping CLIActionHandler) {
        self.handler = handler
    }
    
    public func execute(parent: CLICommandGroup,
                        argumentStartingAt: Int,
                        arguments: [String],
                        environment: [String: String]?,
                        currentDirectory: URL?,
                        standardInput: Any?,
                        userInfo: [String: Any],
                        stackTrace: CodeStackTrace) throws -> Int32 {
        return try self.handler(parent,
                                argumentStartingAt,
                                arguments,
                                environment,
                                currentDirectory,
                                standardInput,
                                userInfo,
                                stackTrace.stacking())
    }
}
