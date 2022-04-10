//
//  CLIAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-25.
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
public typealias CLIActionHandler = (_ parent: CLICommandGroup,
                                     _ argumentStartingAt: Int,
                                     _ arguments: [String],
                                     _ environment: [String: String]?,
                                     _ currentDirectory: URL?,
                                     _ standardInput: Any?) throws -> Int32
/// A General Action to be executed
public protocol CLIAction {
   
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?) throws -> Int32
}
