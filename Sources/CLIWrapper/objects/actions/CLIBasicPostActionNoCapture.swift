//
//  CLIBasicPostActionNoCapture.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation
import CLICapture

public struct CLIBasicPostActionNoCapture<Storage>: CLIPostActionNoCapture {
    
    /// Indicator if the action should continue if executing the cli process reutrns a failure
    public let continueOnCLIFailure: Bool
    /// Options on what to pass to the console from the cli process and to be captured for the event handler and response
    public let outputOptions: CLIOutputOptions
    /// Defining how to capture individual output events
    public let outputEventHandler: CLIPostActionOutputEventHandler<Storage>
    
    private let handler: CLIPostActionNoCaptureHandler<Storage>
    
    public init(continueOnCLIFailure: Bool,
                outputOptions: CLIOutputOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionNoCaptureHandler<Storage>) {
        
        self.continueOnCLIFailure = continueOnCLIFailure
        self.outputOptions = outputOptions
        self.outputEventHandler = outputEventHandler
        self.handler = handler
        
    }
    
    public init(continueOnCLIFailure: Bool,
                passthroughOptions: CLIPassthroughOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionNoCaptureHandler<Storage>) {
        
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + passthroughOptions,
                  outputEventHandler: outputEventHandler,
                  handler: handler)
        
    }
    
    public init(continueOnCLIFailure: Bool,
                captureOptions: CLICaptureOptions,
                outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
                handler: @escaping CLIPostActionNoCaptureHandler<Storage>) {
        
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
                                  userInfo: [String: Any],
                                  stackTrace: CodeStackTrace,
                                  exitStatusCode: Int32) throws -> Int32 {
        return try self.handler(parent,
                                argumentStartingAt,
                                arguments,
                                environment,
                                currentDirectory,
                                storage,
                                userInfo,
                                stackTrace.stacking(),
                                exitStatusCode)
    }
}

public extension CLIBasicPostActionNoCapture where Storage == Void {
    
    
    
    private static func noStorageToStorageHandler(_ handler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLIPostActionNoCaptureHandler<Void>{
        return { (parent: CLICommandGroup,
                  argumentStartingAt: Int,
                  arguments: [String],
                  environment: [String: String]?,
                  currentDirectory: URL?,
                  storage: Storage?,
                  userInfo: [String: Any],
                  stackTrace: CodeStackTrace,
                  exitStatusCode: Int32) throws -> Int32 in
            
            return try handler(parent,
                               argumentStartingAt,
                               arguments,
                               environment,
                               currentDirectory,
                               userInfo,
                               stackTrace.stacking(),
                               exitStatusCode)
            
        }
    }
    init(continueOnCLIFailure: Bool,
         outputOptions: CLIOutputOptions,
         outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
         handler: @escaping CLIPostActionNoCaptureNoStorageHandler) {
        
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: outputOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionNoCapture.noStorageToStorageHandler(handler))
        
    }
    
    init(continueOnCLIFailure: Bool,
         passthroughOptions: CLIPassthroughOptions,
         outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
         handler: @escaping CLIPostActionNoCaptureNoStorageHandler) {
        
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + passthroughOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionNoCapture.noStorageToStorageHandler(handler))
        
    }
    
    init(continueOnCLIFailure: Bool,
         captureOptions: CLICaptureOptions,
         outputEventHandler: CLIPostActionOutputEventHandler<Storage> = .none,
         handler: @escaping CLIPostActionNoCaptureNoStorageHandler) {
        
        self.init(continueOnCLIFailure: continueOnCLIFailure,
                  outputOptions: CLIOutputOptions.none + captureOptions,
                  outputEventHandler: outputEventHandler,
                  handler: CLIBasicPostActionNoCapture.noStorageToStorageHandler(handler))
        
    }
}
