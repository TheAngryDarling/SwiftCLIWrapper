//
//  CLIPassthroughAction.swift
//  
//
//  Created by Tyler Anger on 2023-04-11.
//

import Foundation
import struct CLICapture.CodeStackTrace

/// Helper object which can be used as the default action
/// of a command group to just pass back to the core cli application
public class CLIPassthroughAction: CLIAction {
    
    // Single shared instanced due to the fact that
    // there are no stored states, just passthrough
    public static let shared: CLIPassthroughAction = .init()
    
    private init() {}
    
    public func execute(parent: CLICommandGroup,
                        argumentStartingAt: Int,
                        arguments: [String],
                        environment: [String: String]?,
                        currentDirectory: URL?,
                        standardInput: Any?,
                        userInfo: [String: Any],
                        stackTrace: CodeStackTrace) throws -> Int32 {
        return try parent.cli.executeAndWait(arguments: arguments,
                                             environment: environment,
                                             currentDirectory: currentDirectory,
                                             standardInput: standardInput,
                                             userInfo: userInfo,
                                             stackTrace: stackTrace.stacking())
    }
}
