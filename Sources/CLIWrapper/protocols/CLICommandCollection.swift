//
//  CLICommandCollection.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-17.
//

import Foundation
import RegEx
import CLICapture

/// Protocol defining an object that can add sub commands to
public protocol CLICommandCollection {
    /// Add sub command to the given object
    func addCommand(_ command: CLICommand)
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroup(command: String,
                            caseSensitive: Bool,
                            helpAction: CLICommandGroup.HelpAction,
                            defaultAction: CLIAction?) -> CLICommandGroup
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroup(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction,
                            defaultAction: CLIAction?) -> CLICommandGroup
    
}
    
public extension CLICommandCollection {
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    /// - Returns: Returns the newly created command group
    func createCommandGroup(command: String,
                            caseSensitive: Bool = true,
                            helpAction: CLICommandGroup.HelpAction = .passthrough) -> CLICommandGroup {
        return self.createCommandGroup(command: command,
                                       caseSensitive: caseSensitive,
                                       helpAction: helpAction,
                                       defaultAction: nil)
    }
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroup(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction = .passthrough) -> CLICommandGroup {
        return self.createCommandGroup(regEx: regEx,
                                       helpAction: helpAction,
                                       defaultAction: nil)
    }
}

// MARK: Create Basic Command
public extension CLICommandCollection {
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - action: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createCommand(command: String,
                       caseSensitive: Bool = true,
                       action: CLIAction) -> CLICommand {
        let cmd = CLICommand(command: command,
                             caseSensitive: caseSensitive,
                             action: action)
        self.addCommand(cmd)
        return cmd
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - action: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createCommand(regEx: RegEx,
                       action: CLIAction) -> CLICommand {
        let cmd = CLICommand(regEx: regEx,
                             action: action)
        self.addCommand(cmd)
        return cmd
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - actionHandler: The action handler to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createCommand(command: String,
                       caseSensitive: Bool = true,
                       actionHandler: @escaping CLIActionHandler) -> CLICommand {
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: CLIBasicAction(actionHandler))
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - actionHandler: The action handler to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createCommand(regEx: RegEx,
                       actionHandler: @escaping CLIActionHandler) -> CLICommand {
        return self.createCommand(regEx: regEx,
                                  action: CLIBasicAction(actionHandler))
    }
}

// MARK: Create Pre Action Commands
public extension CLICommandCollection {
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPreCLICommand(command: String,
                             caseSensitive: Bool = true,
                             continueOnPreActionFailure: Bool = false,
                             actionHandler: @escaping CLIPreActionHandler) -> CLICommand {
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: CLIBasicPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                           handler: actionHandler))
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPreCLICommand(regEx: RegEx,
                             continueOnPreActionFailure: Bool = false,
                             actionHandler: @escaping CLIPreActionHandler) -> CLICommand {
        return self.createCommand(regEx: regEx,
                                  action: CLIBasicPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                           handler: actionHandler))
    }
    
    
}

// MARK: Create Post Action Commands (No Capture)
public extension CLICommandCollection {
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Storage>(command: String,
                              caseSensitive: Bool = true,
                              continueOnCLIFailure: Bool = false,
                              outputOptions: CLIOutputOptions = .all,
                              outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                              actionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        let action = CLIBasicPostActionNoCapture(continueOnCLIFailure: continueOnCLIFailure,
                                                outputOptions: outputOptions,
                                                outputEventHandler: outputEventHandler,
                                                handler: actionHandler)
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: action)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand(command: String,
                              caseSensitive: Bool = true,
                              continueOnCLIFailure: Bool = false,
                              passthroughOptions: CLIPassthroughOptions,
                              actionHandler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLICommand {
        
        let action = CLIBasicPostActionNoCapture<Void>.init(continueOnCLIFailure: continueOnCLIFailure,
                                               passthroughOptions: passthroughOptions,
                                               handler: actionHandler)
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: action)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Storage>(regEx: RegEx,
                                       continueOnCLIFailure: Bool = false,
                                       outputOptions: CLIOutputOptions = .all,
                                       outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                       actionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        let action = CLIBasicPostActionNoCapture<Storage>(continueOnCLIFailure: continueOnCLIFailure,
                                                outputOptions: outputOptions,
                                                outputEventHandler: outputEventHandler,
                                                handler: actionHandler)
        return self.createCommand(regEx: regEx,
                                  action: action)
    }
    
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand(regEx: RegEx,
                              continueOnCLIFailure: Bool = false,
                              passthroughOptions: CLIPassthroughOptions,
                              actionHandler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLICommand {
        let action = CLIBasicPostActionNoCapture<Void>.init(continueOnCLIFailure: continueOnCLIFailure,
                                                            passthroughOptions: passthroughOptions,
                                                           handler: actionHandler)
        return self.createCommand(regEx: regEx,
                                  action: action)
    }
    
}

// MARK: Create Post Action Commands (Captured)
public extension CLICommandCollection {
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Storage, Captured>(command: String,
                                                 caseSensitive: Bool = true,
                                                 continueOnCLIFailure: Bool = false,
                                                 outputOptions: CLIOutputOptions = .all,
                                                 outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                                 actionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        let action = CLIBasicPostActionCaptured(continueOnCLIFailure: continueOnCLIFailure,
                                                outputOptions: outputOptions,
                                                outputEventHandler: outputEventHandler,
                                                handler: actionHandler)
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: action)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Captured>(command: String,
                                        caseSensitive: Bool = true,
                                        continueOnCLIFailure: Bool = false,
                                        passthroughOptions: CLIPassthroughOptions,
                                        actionHandler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        
        let action = CLIBasicPostActionCaptured<Void, Captured>.init(continueOnCLIFailure: continueOnCLIFailure,
                                                           passthroughOptions: passthroughOptions,
                                                           handler: actionHandler)
        
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: action)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Storage, Captured>(regEx: RegEx,
                                                 continueOnCLIFailure: Bool = false,
                                                 outputOptions: CLIOutputOptions = .all,
                                                 outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                                 actionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        let action = CLIBasicPostActionCaptured(continueOnCLIFailure: continueOnCLIFailure,
                                                outputOptions: outputOptions,
                                                outputEventHandler: outputEventHandler,
                                                handler: actionHandler)
        return self.createCommand(regEx: regEx,
                                  action: action)
    }
    
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - actionHandler: The action to execute for this command
    /// - Returns: Returns the newly created command
    @discardableResult
    func createPostCLICommand<Captured>(regEx: RegEx,
                                        continueOnCLIFailure: Bool = false,
                                        passthroughOptions: CLIPassthroughOptions,
                                        actionHandler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        let action = CLIBasicPostActionCaptured<Void, Captured>.init(continueOnCLIFailure: continueOnCLIFailure,
                                                                     passthroughOptions: passthroughOptions,
                                                                     handler: actionHandler)
        return self.createCommand(regEx: regEx,
                                 action: action)
    }
    
}


// MARK: Create Wrapped Action Commands
public extension CLICommandCollection {
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - preAction: The action to execute prior to excuting the cli process
    ///   - postAction: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<PreAction, PostAction>(command: String,
                                                     caseSensitive: Bool = true,
                                                     preAction: PreAction,
                                                     postAction: PostAction) -> CLICommand
    where PreAction: CLIWrappedPreAction,
          PostAction: CLIPostAction,
          PreAction.Storage == PostAction.Storage {
              return self.createCommand(command: command,
                                        caseSensitive: caseSensitive,
                                        action: CLIBasicWrappedAction(preAction: preAction,
                                                                     postAction: postAction))
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - preAction: The action to execute prior to excuting the cli process
    ///   - postAction: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<PreAction, PostAction>(regEx: RegEx,
                                                     preAction: PreAction,
                                                     postAction: PostAction) -> CLICommand
    where PreAction: CLIWrappedPreAction,
          PostAction: CLIPostAction,
          PreAction.Storage == PostAction.Storage {
              return self.createCommand(regEx: regEx,
                                        action: CLIBasicWrappedAction(preAction: preAction,
                                                                     postAction: postAction))
    }
}

// MARK: Create Wrapped Action Commands (No Capture)
public extension CLICommandCollection {
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage>(command: String,
                                       caseSensitive: Bool = true,
                                       continueOnPreActionFailure: Bool = false,
                                       continueOnCLIFailure: Bool = false,
                                       outputOptions: CLIOutputOptions = .all,
                                       outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                       preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                       postActionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        
        let preAction = CLIBasicWrappedPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                handler: preActionHandler)
        let postAction = CLIBasicPostActionNoCapture(continueOnCLIFailure: continueOnCLIFailure,
                                                    outputOptions: outputOptions,
                                                    outputEventHandler: outputEventHandler,
                                                    handler: postActionHandler)
        
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: CLIBasicWrappedAction(preAction: preAction,
                                                               postAction: postAction))
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage>(command: String,
                                       caseSensitive: Bool = true,
                                       continueOnPreActionFailure: Bool = false,
                                       continueOnCLIFailure: Bool = false,
                                       passthroughOptions: CLIPassthroughOptions,
                                       preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                       postActionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        
        return self.createWrappedCommand(command: command,
                                         caseSensitive: caseSensitive,
                                         continueOnPreActionFailure: continueOnPreActionFailure,
                                         continueOnCLIFailure: continueOnCLIFailure,
                                         outputOptions: CLIOutputOptions.none + passthroughOptions,
                                         outputEventHandler: CLIPostActionOutputEventHandler<Storage>.none,
                                         preActionHandler: preActionHandler,
                                         postActionHandler: postActionHandler)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage>(regEx: RegEx,
                                       continueOnPreActionFailure: Bool = false,
                                       continueOnCLIFailure: Bool = false,
                                       outputOptions: CLIOutputOptions = .all,
                                       outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                       preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                       postActionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        let preAction = CLIBasicWrappedPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                handler: preActionHandler)
        let postAction = CLIBasicPostActionNoCapture(continueOnCLIFailure: continueOnCLIFailure,
                                                    outputOptions: outputOptions,
                                                    outputEventHandler: outputEventHandler,
                                                    handler: postActionHandler)
        
        return self.createCommand(regEx: regEx,
                                  action: CLIBasicWrappedAction(preAction: preAction,
                                                               postAction: postAction))
    }
    
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process   
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage>(regEx: RegEx,
                                       continueOnPreActionFailure: Bool = false,
                                       continueOnCLIFailure: Bool = false,
                                       passthroughOptions: CLIPassthroughOptions,
                                       preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                       postActionHandler: @escaping CLIPostActionNoCaptureHandler<Storage>) -> CLICommand {
        return self.createWrappedCommand(regEx: regEx,
                                         continueOnPreActionFailure: continueOnPreActionFailure,
                                         continueOnCLIFailure: continueOnCLIFailure,
                                         outputOptions: CLIOutputOptions.none + passthroughOptions,
                                         outputEventHandler: CLIPostActionOutputEventHandler<Storage>.none,
                                         preActionHandler: preActionHandler,
                                         postActionHandler: postActionHandler)
    }
}

// MARK: Create Wrapped Action Commands (Captured)
public extension CLICommandCollection {
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage, Captured>(command: String,
                                                 caseSensitive: Bool = true,
                                                 continueOnPreActionFailure: Bool = false,
                                                 continueOnCLIFailure: Bool = false,
                                                 outputOptions: CLIOutputOptions = .all,
                                                 outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                                 preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                                 postActionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        
        let preAction = CLIBasicWrappedPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                handler: preActionHandler)
        let postAction = CLIBasicPostActionCaptured(continueOnCLIFailure: continueOnCLIFailure,
                                                  outputOptions: outputOptions,
                                                  outputEventHandler: outputEventHandler,
                                                  handler: postActionHandler)
        
        return self.createCommand(command: command,
                                  caseSensitive: caseSensitive,
                                  action: CLIBasicWrappedAction(preAction: preAction,
                                                               postAction: postAction))
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensitive: Indicator if the command is case sensitive
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage, Captured>(command: String,
                                                 caseSensitive: Bool = true,
                                                 continueOnPreActionFailure: Bool = false,
                                                 continueOnCLIFailure: Bool = false,
                                                 passthroughOptions: CLIPassthroughOptions,
                                                 preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                                 postActionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        
        return self.createWrappedCommand(command: command,
                                         caseSensitive: caseSensitive,
                                         continueOnPreActionFailure: continueOnPreActionFailure,
                                         continueOnCLIFailure: continueOnCLIFailure,
                                         outputOptions: CLIOutputOptions.none + passthroughOptions,
                                         outputEventHandler: CLIPostActionOutputEventHandler<Storage>.none,
                                         preActionHandler: preActionHandler,
                                         postActionHandler: postActionHandler)
    }
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - outputOptions: Options on what to pass to the console from the cli process and to be captured for the event handler and response
    ///   - outputEventHandler: Defining how to capture individual output events
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage, Captured>(regEx: RegEx,
                                                 continueOnPreActionFailure: Bool = false,
                                                 continueOnCLIFailure: Bool = false,
                                                 outputOptions: CLIOutputOptions = .all,
                                                 outputEventHandler: CLIPostActionOutputEventHandler<Storage>,
                                                 preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                                 postActionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        let preAction = CLIBasicWrappedPreAction(continueOnPreActionFailure: continueOnPreActionFailure,
                                                handler: preActionHandler)
        let postAction = CLIBasicPostActionCaptured(continueOnCLIFailure: continueOnCLIFailure,
                                                  outputOptions: outputOptions,
                                                  outputEventHandler: outputEventHandler,
                                                  handler: postActionHandler)
        
        return self.createCommand(regEx: regEx,
                                  action: CLIBasicWrappedAction(preAction: preAction,
                                                               postAction: postAction))
    }
    
    
    /// Create a new command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - continueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - continueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - passthroughOptions: Options on what to pass to the console from the cli process
    ///   - preActionHandler: The action to execute prior to excuting the cli process
    ///   - postActionHandler: The action to execute after executing the cli process
    /// - Returns: Returns the newly created command
    @discardableResult
    func createWrappedCommand<Storage, Captured>(regEx: RegEx,
                                                 continueOnPreActionFailure: Bool = false,
                                                 continueOnCLIFailure: Bool = false,
                                                 passthroughOptions: CLIPassthroughOptions,
                                                 preActionHandler: @escaping CLIWrappedPreActionHandler<Storage>,
                                                 postActionHandler: @escaping CLIPostActionCapturedHandler<Storage, Captured>) -> CLICommand
    where Captured: CLICapturedResponse {
        return self.createWrappedCommand(regEx: regEx,
                                         continueOnPreActionFailure: continueOnPreActionFailure,
                                         continueOnCLIFailure: continueOnCLIFailure,
                                         outputOptions: CLIOutputOptions.none + passthroughOptions,
                                         outputEventHandler: CLIPostActionOutputEventHandler<Storage>.none,
                                         preActionHandler: preActionHandler,
                                         postActionHandler: postActionHandler)
    }
}

// MARK: Create Command group with Custom Default Action
public extension CLICommandCollection {
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithCustomAction(command: String,
                                            caseSensitive: Bool = true,
                                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                                            defaultHandler: @escaping CLIActionHandler) -> CLICommandGroup {
        let action = CLIBasicAction(defaultHandler)
        return self.createCommandGroup(command: command,
                                       caseSensitive: caseSensitive,
                                       helpAction: helpAction,
                                       defaultAction: action)
        
    }
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithCustomAction(regEx: RegEx,
                                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                                            defaultHandler: @escaping CLIActionHandler) -> CLICommandGroup {
        
        let action = CLIBasicAction(defaultHandler)
        return self.createCommandGroup(regEx: regEx,
                                       helpAction: helpAction,
                                       defaultAction: action)
    }
}

// MARK: Create Command group with Pre CLI Default Action
public extension CLICommandCollection {
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPreCLIAction(command: String,
                            caseSensitive: Bool = true,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnPreActionFailure: Bool = false,
                                            defaultHandler: @escaping CLIPreActionHandler) -> CLICommandGroup {
        let action = CLIBasicPreAction(continueOnPreActionFailure:
                                        defaultContinueOnPreActionFailure,
                                       handler: defaultHandler)
        return self.createCommandGroup(command: command,
                                       caseSensitive: caseSensitive,
                                       helpAction: helpAction,
                                       defaultAction: action)
        
    }
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnPreActionFailure: Indicator if execution of cli should occur if pre action returns failure code
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPreCLIAction(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnPreActionFailure: Bool = false,
                                            defaultHandler: @escaping CLIPreActionHandler) -> CLICommandGroup {
        
        let action = CLIBasicPreAction(continueOnPreActionFailure:
                                        defaultContinueOnPreActionFailure,
                                       handler: defaultHandler)
        return self.createCommandGroup(regEx: regEx,
                                       helpAction: helpAction,
                                       defaultAction: action)
    }
}
    
// MARK: Create Command group with Post CLI Capture Action
public extension CLICommandCollection {
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - defaultOutputOptions: Options on what to pass to the console from the cli process
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPostCLICaptured<Captured>(command: String,
                            caseSensitive: Bool = true,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnCLIFailure: Bool = false,
                            defaultOutputOptions: CLIOutputOptions,
                                                defaultHandler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) -> CLICommandGroup
    where Captured: CLICapturedResponse {
        
        let action = CLIBasicPostActionCaptured<Void, Captured>(continueOnCLIFailure: defaultContinueOnCLIFailure,
                                                 outputOptions: defaultOutputOptions,
                                                 handler: defaultHandler)
        return self.createCommandGroup(command: command,
                                       caseSensitive: caseSensitive,
                                       helpAction: helpAction,
                                       defaultAction: action)
        
    }
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - defaultOutputOptions: Options on what to pass to the console from the cli process
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPostCLICaptured<Captured>(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnCLIFailure: Bool = false,
                                               defaultOutputOptions: CLIOutputOptions,
                                                defaultHandler: @escaping CLIPostActionCapturedNoStorageHandler<Captured>) -> CLICommandGroup
    where Captured: CLICapturedResponse {
        
        let action = CLIBasicPostActionCaptured<Void, Captured>(continueOnCLIFailure: defaultContinueOnCLIFailure,
                                                 outputOptions: defaultOutputOptions,
                                                 handler: defaultHandler)
        
        return self.createCommandGroup(regEx: regEx,
                                       helpAction: helpAction,
                                       defaultAction: action)
    }
    
}

// MARK: Create Command group with Post CLI Action
public extension CLICommandCollection {
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - defaultPassthroughOptions: Options on what to pass to the console from the cli process
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPostCLI(command: String,
                            caseSensitive: Bool = true,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnCLIFailure: Bool = false,
                            defaultPassthroughOptions: CLIPassthroughOptions,
                                                defaultHandler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLICommandGroup {
        
        let action = CLIBasicPostActionNoCapture<Void>(continueOnCLIFailure: defaultContinueOnCLIFailure,
                                                 passthroughOptions: defaultPassthroughOptions,
                                                 handler: defaultHandler)
        return self.createCommandGroup(command: command,
                                       caseSensitive: caseSensitive,
                                       helpAction: helpAction,
                                       defaultAction: action)
        
    }
    
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultContinueOnCLIFailure: Indicator if the action should continue if executing the cli process reutrns a failure
    ///   - defaultPassthroughOptions: Options on what to pass to the console from the cli process
    ///   - defaultHandler: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroupWithPostCLI(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultContinueOnCLIFailure: Bool = false,
                            defaultPassthroughOptions: CLIPassthroughOptions,
                                                defaultHandler: @escaping CLIPostActionNoCaptureNoStorageHandler) -> CLICommandGroup {
        
        let action = CLIBasicPostActionNoCapture<Void>(continueOnCLIFailure: defaultContinueOnCLIFailure,
                                                 passthroughOptions: defaultPassthroughOptions,
                                                 handler: defaultHandler)
        
        return self.createCommandGroup(regEx: regEx,
                                       helpAction: helpAction,
                                       defaultAction: action)
    }
    
}
