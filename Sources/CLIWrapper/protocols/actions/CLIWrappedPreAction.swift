//
//  CLIWrappedPreAction.swift
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
public typealias CLIWrappedPreActionHandler<Storage> = (_ parent: CLICommandGroup,
                                                        _ argumentStartingAt: Int,
                                                        _ arguments: inout [String],
                                                        _ environment: [String: String]?,
                                                        _ currentDirectory: URL?,
                                                        _ storage: inout Storage?) throws -> Int32

/// Defining a general action that occurs before execution the CLI process
/// for use with CLIWrappedAction
public protocol CLIWrappedPreAction {
    associatedtype Storage
    
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
                          currentDirectory: URL?,
                          storage: inout Storage?) throws -> Int32
}
