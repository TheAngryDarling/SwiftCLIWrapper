//
//  CLIPostActionCaptured.swift
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
public typealias CLIPostActionCapturedHandler<Storage, Captured> = (_ parent: CLICommandGroup,
                                                                    _ argumentStartingAt: Int,
                                                                    _ arguments: [String],
                                                                    _ environment: [String: String]?,
                                                                    _ currentDirectory: URL?,
                                                                    _ storage: Storage?,
                                                                    _ captured: Captured,
                                                                    _ userInfo: [String: Any],
                                                                    _ stackTrace: CLIStackTrace) throws -> Int32
where Captured: CLICapturedResponse

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
public typealias CLIPostActionCapturedNoStorageHandler<Captured> = (_ parent: CLICommandGroup,
                                                                    _ argumentStartingAt: Int,
                                                                    _ arguments: [String],
                                                                    _ environment: [String: String]?,
                                                                    _ currentDirectory: URL?,
                                                                    _ captured: Captured,
                                                                    _ userInfo: [String: Any],
                                                                    _ stackTrace: CLIStackTrace) throws -> Int32
where Captured: CLICapturedResponse

/// Defining a post action that capture responses from the CLI execution
public protocol CLIPostActionCaptured: CLIPostAction, CLIAction {
    associatedtype Captured: CLICapturedResponse
    
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
                           captured: Captured,
                           userInfo: [String: Any],
                           stackTrace: CLIStackTrace) throws -> Int32
}

#if swift(>=5.3)
public extension CLIPostActionCaptured {
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
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           captured: Captured,
                           userInfo: [String: Any] = [:],
                           filePath: StaticString = #filePath,
                           function: StaticString = #function,
                           line: UInt = #line) throws -> Int32 {
        
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          captured: captured,
                                          userInfo: userInfo,
                                          stackTrace: .init(filePath: filePath, function: function, line: line))
        
    }
}
#else
public extension CLIPostActionCaptured {
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
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           captured: Captured,
                           userInfo: [String: Any] = [:],
                           filePath: StaticString = #file,
                           function: StaticString = #function,
                           line: UInt = #line) throws -> Int32 {
        
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          captured: captured,
                                          userInfo: userInfo,
                                          stackTrace: .init(filePath: filePath, function: function, line: line))
        
    }
}
#endif

// MARK: - Protocol Extension without userInfo parameter
public extension CLIPostActionCaptured {
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
                           captured: Captured,
                           stackTrace: CLIStackTrace) throws -> Int32 {
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          captured: captured,
                                          userInfo: [:],
                                          stackTrace: stackTrace.stacking())
    }
}

// MARK: - Execute Implimentations for CLIPostAction and CLIAction
public extension CLIPostActionCaptured {
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The input to pass to the calling process
    ///   - storage: Any storage to maintain the the call
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 storage: Storage?,
                 userInfo: [String: Any],
                 stackTrace: CLIStackTrace) throws -> Int32 {
        
        var storage: Storage? = storage
        
        func eventHandler(event: CLICapturedOutputEvent<DispatchData>) {
            self.outputEventHandler.eventHandler(event, &storage)
        }
        
        let resp = try parent.cli.waitAndCaptureResponse(arguments: arguments,
                                                         environment: environment,
                                                         currentDirectory: currentDirectory,
                                                         standardInput: standardInput,
                                                         outputOptions: self.outputOptions ,
                                                         runningEventHandlerOn: self.outputEventHandler.queue,
                                                         eventHandler: eventHandler,
                                                         withResponseType: Captured.self,
                                                         userInfo: userInfo,
                                                         stackTrace: stackTrace.stacking())
        
        guard resp.exitStatusCode == 0 || self.continueOnCLIFailure else {
            return resp.exitStatusCode
        }
        
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          captured: resp,
                                          userInfo: userInfo,
                                          stackTrace: stackTrace)
    }
    /// Execute the given action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the arguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The input to pass to the calling process
    ///   - userInfo: Any user info to pass through to the create process method
    ///   - stackTrace: The calling stack trace
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 userInfo: [String: Any],
                 stackTrace: CLIStackTrace) throws -> Int32 {
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
