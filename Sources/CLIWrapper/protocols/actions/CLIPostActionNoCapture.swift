//
//  CLIPostActionNoCapture.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-27.
//

import Foundation
import Dispatch
import CLICapture

/// Execute the given action
/// - Parameters:
///   - parent: The parent CLICommandGroup object or self if the current group is the root
///   - argumentStartingAt: The index in the arguments this commands arguments start at
///   - arguments: An array of all arguments (excluding the executable argument)
///   - environment: The environmental variables to set to the cli sub process if called
///   - currentDirectory: Set the current working directory
///   - storage: Any storage to maintain the the call
///   - captured: The captured response from the CLI output
///   - userInfo: Any user info to pass through to the create process method
///   - stackTrace: The calling stack trace
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPostActionNoCaptureHandler<Storage> = (_ parent: CLICommandGroup,
                                                           _ argumentStartingAt: Int,
                                                           _ arguments: [String],
                                                           _ environment: [String: String]?,
                                                           _ currentDirectory: URL?,
                                                           _ storage: Storage?,
                                                           _ userInfo: [String: Any],
                                                           _ stackTrace: CodeStackTrace,
                                                           _ exitStatusCode: Int32) throws -> Int32
/// Execute the given action
/// - Parameters:
///   - parent: The parent CLICommandGroup object or self if the current group is the root
///   - argumentStartingAt: The index in the arguments this commands arguments start at
///   - arguments: An array of all arguments (excluding the executable argument)
///   - environment: The environmental variables to set to the cli sub process if called
///   - currentDirectory: Set the current working directory
///   - captured: The captured response from the CLI output
///   - userInfo: Any user info to pass through to the create process method
///   - stackTrace: The calling stack trace   
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPostActionNoCaptureNoStorageHandler = (_ parent: CLICommandGroup,
                                                           _ argumentStartingAt: Int,
                                                           _ arguments: [String],
                                                           _ environment: [String: String]?,
                                                           _ currentDirectory: URL?,
                                                           _ userInfo: [String: Any],
                                                           _ stackTrace: CodeStackTrace,
                                                           _ exitStatusCode: Int32) throws -> Int32

/// Defining a post action that does not capture  CLI outputs
public protocol CLIPostActionNoCapture: CLIPostAction, CLIAction {
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - storage: Any storage to maintain the the call
    ///   - captured: The captured response from the CLI output
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           userInfo: [String: Any],
                           stackTrace: CodeStackTrace,
                           exitStatusCode: Int32) throws -> Int32
}

#if swift(>=5.3)
public extension CLIPostActionNoCapture {
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - storage: Any storage to maintain the the call
    ///   - captured: The captured response from the CLI output
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           userInfo: [String: Any],
                           filePath: StaticString = #filePath,
                           function: StaticString = #function,
                           line: UInt = #line,
                           threadDetails: CodeStackTrace.ThreadDetails = .init(),
                           exitStatusCode: Int32) throws -> Int32 {
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          userInfo: userInfo,
                                          stackTrace: .init(filePath: filePath,
                                                            function: function,
                                                            line: line,
                                                            threadDetails: threadDetails),
                                          exitStatusCode: exitStatusCode)
    }
}
#else
public extension CLIPostActionNoCapture {
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - storage: Any storage to maintain the the call
    ///   - captured: The captured response from the CLI output
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           userInfo: [String: Any],
                           filePath: StaticString = #file,
                           function: StaticString = #function,
                           line: UInt = #line,
                           threadDetails: CodeStackTrace.ThreadDetails = .init(),
                           exitStatusCode: Int32) throws -> Int32 {
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          userInfo: userInfo,
                                          stackTrace: .init(filePath: filePath,
                                                            function: function,
                                                            line: line,
                                                            threadDetails: threadDetails),
                                          exitStatusCode: exitStatusCode)
    }
}
#endif

// MARK: - Protocol Extension without userInfo parameter
public extension CLIPostActionNoCapture {
    
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - storage: Any storage to maintain the the call
    ///   - captured: The captured response from the CLI output
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           stackTrace: CodeStackTrace,
                           exitStatusCode: Int32) throws -> Int32 {
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          userInfo: [:],
                                          stackTrace: stackTrace.stacking(),
                                          exitStatusCode: exitStatusCode)
    }
}

// MARK: - Execute Implimentations for CLIPostAction and CLIAction
public extension CLIPostActionNoCapture {
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 storage: Storage?,
                 userInfo: [String: Any],
                 stackTrace: CodeStackTrace) throws -> Int32 {
        
        var storage: Storage? = storage
        
        func eventHandler(event: CLICapturedOutputEvent<DispatchData>) {
            self.outputEventHandler.eventHandler(event, &storage)
        }
        
        let ret = try parent.cli.waitAndCapture(arguments: arguments,
                                                environment: environment,
                                                currentDirectory: currentDirectory,
                                                standardInput: standardInput,
                                                outputOptions: self.outputOptions,
                                                runningEventHandlerOn: self.outputEventHandler.queue,
                                                eventHandler: eventHandler,
                                                userInfo: userInfo,
                                                stackTrace: stackTrace.stacking())
        
        guard ret == 0 || self.continueOnCLIFailure else {
            return ret
        }
        
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          userInfo: userInfo,
                                          stackTrace: stackTrace.stacking(),
                                          exitStatusCode: ret)
    }
    
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 userInfo: [String: Any],
                 stackTrace: CodeStackTrace) throws -> Int32 {
        return try self.execute(parent: parent,
                                argumentStartingAt: argumentStartingAt,
                                arguments: arguments,
                                environment: environment,
                                currentDirectory: currentDirectory,
                                standardInput: standardInput,
                                storage: nil,
                                userInfo: userInfo,
                                stackTrace: stackTrace.stacking())
    }
}
