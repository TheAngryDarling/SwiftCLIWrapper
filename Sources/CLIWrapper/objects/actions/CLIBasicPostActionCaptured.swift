//
//  CLIBasicPostActionCaptured.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation
import CLICapture

public struct CLIBasicPostActionCaptured<Storage, Captured>: CLIPostActionCaptured
    where Captured: CLICapturedResponse {
    
    /// Indicator if the action should continue if executing the cli process reutrns a failure
    public let continueOnCLIFailure: Bool
    /// Options on what to pass to the console from the cli process and to be captured for the event handler and response
    public let outputOptions: CLIOutputOptions
    /// Defining how to capture individual output events
    public let outputEventHandler: CLIPostActionOutputEventHandler<Storage>
    
    private let handler: CLIPostActionCapturedHandler<Storage, Captured>
    
    public init(continueOnCLIFailure: Bool,
                outputOptions: CLIOutputOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) {
        
        self.continueOnCLIFailure = continueOnCLIFailure
        self.outputOptions = outputOptions
        self.outputEventHandler = outputEventHandler
        self.handler = handler
        
    }
    
    public init(continueOnCLIFailure: Bool,
                passthroughOptions: CLIPassthroughOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) {
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + passthroughOptions,
                  outputEventHandler: outputEventHandler,
                  handler: handler)
    }
    
    public init(continueOnCLIFailure: Bool,
                captureOptions: CLICaptureOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) {
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + captureOptions,
                  outputEventHandler: outputEventHandler,
                  handler: handler)
    }
    
    public func executePostAction(parent: CLICommandGroup,
                                  argumentStartingAt: Int,
                                  arguments: [String],
                                  environment: [String: String]?,
                                  currentDirectory: URL?,
                                  storage: Storage?,
                                  captured: Captured,
                                  userInfo: [String: Any],
                                  stackTrace: CodeStackTrace) throws -> Int32 {
        return try self.handler(parent,
                                argumentStartingAt,
                                arguments,
                                environment,
                                currentDirectory,
                                storage,
                                captured,
                                userInfo,
                                stackTrace.stacking())
    }
}

extension CLIBasicPostActionCaptured where Storage == Void {
    
    
    private static func noStorageToStorageHandler(_ handler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) -> CLIPostActionCapturedHandler<Storage, Captured> {
        return { (parent: CLICommandGroup,
                  argumentStartingAt: Int,
                  arguments: [String],
                  environment: [String: String]?,
                  currentDirectory: URL?,
                  storage: Storage?,
                  captured: Captured,
                  userInfo: [String: Any],
                  stackTrace: CodeStackTrace) throws -> Int32 in
            
            return try handler(parent,
                               argumentStartingAt,
                               arguments,
                               environment,
                               currentDirectory,
                               captured,
                               userInfo,
                               stackTrace.stacking())
            
        }
    }
    
    public init(continueOnCLIFailure: Bool,
                outputOptions: CLIOutputOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Void> = .none,
                handler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) {
        
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: outputOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionCaptured.noStorageToStorageHandler(handler))
        
    }
    
    public init(continueOnCLIFailure: Bool,
                passthroughOptions: CLIPassthroughOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Void> = .none,
                handler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) {
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + passthroughOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionCaptured.noStorageToStorageHandler(handler))
    }
    
    public init(continueOnCLIFailure: Bool,
                captureOptions: CLICaptureOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Void> = .none,
                handler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) {
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + captureOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionCaptured.noStorageToStorageHandler(handler))
    }
}
