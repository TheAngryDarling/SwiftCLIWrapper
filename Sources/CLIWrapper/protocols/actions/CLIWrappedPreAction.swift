//
//  CLIWrappedPreAction.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation
import struct CLICapture.CodeStackTrace

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
public typealias CLIWrappedPreActionHandler<Storage> = (_ parent: CLICommandGroup,
                                                        _ argumentStartingAt: Int,
                                                        _ arguments: inout [String],
                                                        _ environment: [String: String]?,
                                                        _ currentDirectory: URL?,
                                                        _ storage: inout Storage?,
                                                        _ userInfo: [String: Any],
                                                        _ stackTrace: CodeStackTrace) throws -> Int32

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
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePreAction(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: inout [String],
                          environment: [String: String]?,
                          currentDirectory: URL?,
                          storage: inout Storage?,
                          userInfo: [String: Any],
                          stackTrace: CodeStackTrace) throws -> Int32
}

#if swift(>=5.3)
public extension CLIWrappedPreAction {
    
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
                          storage: inout Storage?,
                          userInfo: [String: Any] = [:],
                          filePath: StaticString = #filePath,
                          function: StaticString = #function,
                          line: UInt = #line,
                          threadDetails: CodeStackTrace.ThreadDetails = .init()) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         storage: &storage,
                                         userInfo: userInfo,
                                         stackTrace: .init(filePath: filePath,
                                                           function: function,
                                                           line: line,
                                                           threadDetails: threadDetails))
    }
}
#else
public extension CLIWrappedPreAction {
    
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
                          storage: inout Storage?,
                          userInfo: [String: Any] = [:],
                          filePath: StaticString = #file,
                          function: StaticString = #function,
                          line: UInt = #line,
                          threadDetails: CodeStackTrace.ThreadDetails = .init()) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         storage: &storage,
                                         userInfo: userInfo,
                                         stackTrace: .init(filePath: filePath,
                                                           function: function,
                                                           line: line,
                                                           threadDetails: threadDetails))
    }
}
#endif


public extension CLIWrappedPreAction {
    
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
                          storage: inout Storage?,
                          stackTrace: CodeStackTrace) throws -> Int32 {
        return try self.executePreAction(parent: parent,
                                         argumentStartingAt: argumentStartingAt,
                                         arguments: &arguments,
                                         environment: environment,
                                         currentDirectory: currentDirectory,
                                         storage: &storage,
                                         userInfo: [:],
                                         stackTrace: stackTrace.stacking())
    }
}

