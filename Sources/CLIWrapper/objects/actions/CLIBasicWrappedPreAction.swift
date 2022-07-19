//
//  CLIBasicWrappedPreAction.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation

public struct CLIBasicWrappedPreAction<Storage>: CLIWrappedPreAction {
    
    public let continueOnPreActionFailure: Bool
    private let handler: CLIWrappedPreActionHandler<Storage>
    
    public init(continueOnPreActionFailure: Bool,
                handler: @escaping CLIWrappedPreActionHandler<Storage>) {
        self.continueOnPreActionFailure = continueOnPreActionFailure
        self.handler = handler
    }
    
    public func executePreAction(parent: CLICommandGroup,
                                 argumentStartingAt: Int,
                                 arguments: inout [String],
                                 environment: [String: String]?,
                                 currentDirectory: URL?,
                                 storage: inout Storage?,
                                 userInfo: [String: Any],
                                 stackTrace: CLIStackTrace) throws -> Int32 {
        return try self.handler(parent,
                                argumentStartingAt,
                                &arguments,
                                environment,
                                currentDirectory,
                                &storage,
                                userInfo,
                                stackTrace.stacking())
    }
}
