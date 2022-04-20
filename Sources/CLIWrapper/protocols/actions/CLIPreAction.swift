//
//  CLIPreAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation

/// Execute the given action
/// - Parameters:
///   - parent: The parent CLICommandGroup object or self if the current group is the root
///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
///   - arguments: An array of all arguments (excluding the executable argument)
///   - environment: The environmental variables to set to the cli sub process if called
///   - currentDirectory: Set the current working directory
///   - standardInput: The standard input to set the cli sub process if called
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPreActionHandler = (_ parent: CLICommandGroup,
                                        _ argumentStartingAt: Int,
                                        _ arguments: inout [String],
                                        _ environment: [String: String]?,
                                        _ currentDirectory: URL?) throws -> Int32

/// Defining a general action that occurs before execution the CLI process
public protocol CLIPreAction: CLIAction {
    
    /// Indicator if execution of CLI should occur if pre action fails
    var continueOnPreActionFailure: Bool { get }
    
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?) throws -> Int32
}

public extension CLIPreAction {
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?) throws -> Int32 {
        var arguments = arguments
        let ret = try self.executePreAction(parent: parent,
                                            argumentStartingAt: argumentStartingAt,
                                            arguments: &arguments,
                                            environment: environment,
                                            currentDirectory: currentDirectory)
        guard ret == 0 || self.continueOnPreActionFailure else {
            return ret
        }
        
        return try parent.cli.executeAndWait(arguments: arguments,
                                             environment: environment,
                                             currentDirectory: currentDirectory,
                                             standardInput: standardInput)
        
    }
}
