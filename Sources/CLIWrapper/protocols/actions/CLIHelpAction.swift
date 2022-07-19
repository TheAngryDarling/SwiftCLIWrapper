//
//  CLIHelpAction.swift
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
///   - message: Custom error message to display with the help message
///   - userInfo: Any user info to pass through to the create process method
///   - stackTrace: The calling stack trace
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIHelpActionHandler = (_ parent: CLICommandGroup,
                                         _ argumentStartingAt: Int,
                                         _ arguments: [String],
                                         _ environment: [String: String]?,
                                         _ currentDirectory: URL?,
                                         _ message: String?,
                                         _ userInfo: [String: Any],
                                         _ stackTrace: CLIStackTrace) throws -> Int32
/// A Help Action to be executed
public protocol CLIHelpAction {
   
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: Custom error message to display with the help message
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 withMessage message: String?,
                 userInfo: [String: Any],
                 stackTrace: CLIStackTrace) throws -> Int32
}

#if swift(>=5.3)
public extension CLIHelpAction {
   
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: Custom error message to display with the help message
    ///   - userInfo: Any user info to pass through to the create process method
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 withMessage message: String?,
                 userInfo: [String: Any] = [:],
                 filePath: StaticString = #filePath,
                 function: StaticString = #function,
                 line: UInt = #line) throws -> Int32 {
        return try self.execute(parent: parent,
                                argumentStartingAt: argumentStartingAt,
                                arguments: arguments,
                                environment: environment,
                                currentDirectory: currentDirectory,
                                withMessage: message,
                                userInfo: userInfo,
                                stackTrace: .init(filePath: filePath, function: function, line: line))
    }
}
#else
public extension CLIHelpAction {
   
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: Custom error message to display with the help message
    ///   - userInfo: Any user info to pass through to the create process method
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 withMessage message: String?,
                 userInfo: [String: Any] = [:],
                 filePath: StaticString = #file,
                 function: StaticString = #function,
                 line: UInt = #line) throws -> Int32 {
        return try self.execute(parent: parent,
                                argumentStartingAt: argumentStartingAt,
                                arguments: arguments,
                                environment: environment,
                                currentDirectory: currentDirectory,
                                withMessage: message,
                                userInfo: userInfo,
                                stackTrace: .init(filePath: filePath, function: function, line: line))
    }
}
#endif

public extension CLIHelpAction {
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: Custom error message to display with the help message
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 withMessage message: String?,
                 stackTrace: CLIStackTrace) throws -> Int32 {
        return try self.execute(parent: parent,
                                argumentStartingAt: argumentStartingAt,
                                arguments: arguments,
                                environment: environment,
                                currentDirectory: currentDirectory,
                                withMessage: message,
                                userInfo: [:],
                                stackTrace: stackTrace.stacking())
    }
}
