//
//  CLIBasicPreAction.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation

/// Helper object used to create a basic CLIPreAction from just
/// the handler function
public struct CLIBasicPreAction: CLIPreAction {
    
    public let continueOnPreActionFailure: Bool
    private let handler: CLIPreActionHandler
    
    public init(continueOnPreActionFailure: Bool,
                handler: @escaping CLIPreActionHandler) {
        self.continueOnPreActionFailure = continueOnPreActionFailure
        self.handler = handler
    }
    
    public func executePreAction(parent: CLICommandGroup,
                                 argumentStartingAt: Int,
                                 arguments: inout [String],
                                 environment: [String: String]?,
                                 currentDirectory: URL?) throws -> Int32 {
        return try self.handler(parent,
                                argumentStartingAt,
                                &arguments,
                                environment,
                                currentDirectory)
    }
}
