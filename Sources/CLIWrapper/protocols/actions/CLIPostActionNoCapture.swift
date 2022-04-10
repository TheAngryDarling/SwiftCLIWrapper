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
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPostActionNoCaptureHandler<Storage> = (_ parent: CLICommandGroup,
                                                           _ argumentStartingAt: Int,
                                                           _ arguments: [String],
                                                           _ environment: [String: String]?,
                                                           _ currentDirectory: URL?,
                                                           _ storage: Storage?,
                                                           _ exitStatusCode: Int32) throws -> Int32
/// Execute the given action
/// - Parameters:
///   - parent: The parent CLICommandGroup object or self if the current group is the root
///   - argumentStartingAt: The index in the arguments this commands arguments start at
///   - arguments: An array of all arguments (excluding the executable argument)
///   - environment: The environmental variables to set to the cli sub process if called
///   - currentDirectory: Set the current working directory
///   - captured: The captured response from the CLI output
/// - Returns: Returns the process response code (0 is OK, any other can be an error code)
public typealias CLIPostActionNoCaptureNoStorageHandler = (_ parent: CLICommandGroup,
                                                           _ argumentStartingAt: Int,
                                                           _ arguments: [String],
                                                           _ environment: [String: String]?,
                                                           _ currentDirectory: URL?,
                                                           _ exitStatusCode: Int32) throws -> Int32

internal func cliPostActionNoCapureNoStorageToStorage(_ handler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLIPostActionNoCaptureHandler<Void> {
    return { (parent: CLICommandGroup,
              argumentStartingAt: Int,
              arguments: [String],
              environment: [String: String]?,
              currentDirectory: URL?,
              storage: Void?,
              exitStatusCode: Int32) throws -> Int32 in
        
        return try handler(parent,
                           argumentStartingAt,
                           arguments,
                           environment,
                           currentDirectory,
                           exitStatusCode)
        
    }
}

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
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executePostAction(parent: CLICommandGroup,
                           argumentStartingAt: Int,
                           arguments: [String],
                           environment: [String: String]?,
                           currentDirectory: URL?,
                           storage: Storage?,
                           exitStatusCode: Int32) throws -> Int32
}

public extension CLIPostActionNoCapture {
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?,
                 storage: Storage?) throws -> Int32 {
        
        var storage: Storage? = storage
        
        func eventHandler(event: CLICapturedOutputEvent<DispatchData>) {
            self.outputEventHandler.eventHandler(event, &storage)
        }
        
        let ret = try parent.cli.waitAndCapture(arguments: arguments,
                                                environment: environment,
                                                currentDirectory: currentDirectory,
                                                standardInput: standardInput,
                                                outputOptions: self.outputOptions ,
                                                runningEventHandlerOn: self.outputEventHandler.queue,
                                                eventHandler: eventHandler)
        
        guard ret == 0 || self.continueOnCLIFailure else {
            return ret
        }
        
        return try self.executePostAction(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          storage: storage,
                                          exitStatusCode: ret)
    }
    
    func execute(parent: CLICommandGroup,
                 argumentStartingAt: Int,
                 arguments: [String],
                 environment: [String: String]?,
                 currentDirectory: URL?,
                 standardInput: Any?) throws -> Int32 {
        return try self.execute(parent: parent,
                                argumentStartingAt: argumentStartingAt,
                                arguments: arguments,
                                environment: environment,
                                currentDirectory: currentDirectory,
                                standardInput: standardInput,
                                storage: nil)
    }
}
