//
//  CLIPostAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation
import CLICapture

/// Defining a general action that occurs AFTER the CLI execution
public protocol CLIPostAction {
    associatedtype Storage
    
    /// Indicator if the action should continue if executing the cli process reutrns a failure
    var continueOnCLIFailure: Bool { get }
    /// Options on what to pass to the console from the cli process and to be captured for the event handler and response
    var outputOptions: CLIOutputOptions { get }
    /// Defining how to capture individual output events
    var outputEventHandler: CLIPostActionOutputEventHandler<Storage> { get }
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    ///   - storage: Any storage to maintain the the call
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 storage: Storage?) throws -> Int32
}
