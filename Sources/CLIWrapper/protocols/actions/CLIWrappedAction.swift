//
//  CLIWrappedAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation

/// Defining actions that occur both before and after the execution of the CLI process
public protocol CLIWrappedAction: CLIAction where PreAction.Storage == PostAction.Storage {
    associatedtype PreAction: CLIWrappedPreAction
    associatedtype PostAction: CLIPostAction
    /// The action to execute prior to the CLI execution
    var preAction: PreAction { get }
    /// The action to execute after the execution of the CLI process
    var postAction: PostAction { get }
}

public extension CLIWrappedAction {
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 userInfo: [String: Any],
                 stackTrace: CodeStackTrace) throws -> Int32 {
        
        var arguments = arguments
        var storage: PreAction.Storage? = nil
        let ret = try self.preAction.executePreAction(parent: parent,
                                                      argumentStartingAt: argumentStartingAt,
                                                      arguments: &arguments,
                                                      environment: environment,
                                                      currentDirectory: currentDirectory,
                                                      storage: &storage,
                                                      userInfo: userInfo,
                                                      stackTrace: stackTrace.stacking())
        
        guard ret == 0 || self.preAction.continueOnPreActionFailure else {
            return ret
        }
        
        return try self.postAction.execute(parent: parent,
                                           argumentStartingAt: argumentStartingAt,
                                           arguments: arguments,
                                           environment: environment,
                                           currentDirectory: currentDirectory,
                                           standardInput: standardInput,
                                           storage: storage,
                                           userInfo: userInfo,
                                           stackTrace: stackTrace.stacking())
        
    }
}
