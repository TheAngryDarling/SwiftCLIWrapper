//
//  CLIPreAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation
import struct CLICapture.CLIStackTrace

/// Execute the given action
/// - Parameters:
///   - parent: The parent CLICommandGroup object or self if the current group is the root
///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
///   - arguments: An array of all arguments (excluding the executable argument)
///   - environment: The environmental variables to set to the cli sub process if called
///   - currentDirectory: Set the current working directory
///   - standardInput: The standard input to set the cli sub process if called
///   - userInfo: Any user info to pass through to the create process method
///   - stackTrace: The calling stack trace
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPreActionHandler = (_ parent: CLICommandGroup,
                                        _ argumentStartingAt: Int,
                                        _ arguments: inout [String],
                                        _ environment: [String: String]?,
                                        _ currentDirectory: URL?,
                                        _ userInfo: [String: Any],
                                        _ stackTrace: CLIStackTrace) throws -> Int32

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
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?,
                          userInfo: [String: Any],
                          stackTrace: CLIStackTrace) throws -> Int32
}

#if swift(>=5.3)
public extension CLIPreAction {
    
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    ///   - userInfo: Any user info to pass through to the create process method
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?,
                          userInfo: [String: Any] = [:],
                          filePath: StaticString = #filePath,
                          function: StaticString = #function,
                          line: UInt = #line) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         userInfo: userInfo,
                                         stackTrace: .init(filePath: filePath, function: function, line: line))
    }
}
#else
public extension CLIPreAction {
    
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    ///   - userInfo: Any user info to pass through to the create process method
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?,
                          userInfo: [String: Any] = [:],
                          filePath: StaticString = #file,
                          function: StaticString = #function,
                          line: UInt = #line) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         userInfo: userInfo,
                                         stackTrace: .init(filePath: filePath, function: function, line: line))
    }
}
#endif

// MARK: - Protocol Extension without userInfo parameter
public extension CLIPreAction {
    
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?,
                          stackTrace: CLIStackTrace) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         userInfo: [:],
                                         stackTrace: stackTrace.stacking())
    }
}

// MARK: - Execute Implimentations for CLIAction
public extension CLIPreAction {
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 userInfo: [String: Any],
                 stackTrace: CLIStackTrace) throws -> Int32 {
        var arguments = arguments
        let ret = try self.executePreAction(parent: parent,
                                            argumentStartingAt: argumentStartingAt,
                                            arguments: &arguments,
                                            environment: environment,
                                            currentDirectory: currentDirectory,
                                            userInfo: userInfo,
                                            stackTrace: stackTrace.stacking())
        guard ret == 0 || self.continueOnPreActionFailure else {
            return ret
        }
        
        return try parent.cli.executeAndWait(arguments: arguments,
                                             environment: environment,
                                             currentDirectory: currentDirectory,
                                             standardInput: standardInput,
                                             userInfo: userInfo,
                                             stackTrace: stackTrace.stacking())
        
    }
}
