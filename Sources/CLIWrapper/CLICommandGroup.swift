//
//  CLICommandGroup.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-15.
//

import Foundation
import Dispatch
import RegEx

/// Class representing a CLI Group Command that has sub commands
public class CLICommandGroup: CLICommand, CLICommandCollection {
    
    /// Action handler for handling help commands
    public enum HelpAction {
        
        case useParentAction
        case passthrough
        case custom(CLIHelpAction)
        /*case preCLIAction(PreCLIAction)
        case postCLIAction(PostCLIAction)*/
        
        fileprivate var isUseParentAction: Bool {
            guard case .useParentAction = self else {
                return false
            }
            return true
        }
        
        public func execute(parent: CLICommandGroup,
                            argumentStartingAt: Int,
                            arguments: [String],
                            environment: [String: String]? = nil,
                            currentDirectory: URL? = nil,
                            withMessage message: String? = nil) throws -> Int32 {
            
            switch self {
                case .useParentAction:
                    return try parent.helpAction.execute(parent: parent.parentGroup,
                                                         argumentStartingAt: argumentStartingAt,
                                                         arguments: arguments,
                                                         environment: environment,
                                                         currentDirectory: currentDirectory,
                                                         withMessage: message)
                case .passthrough:
                    if let msg = message {
                        parent.outputQueue.sync {
                            print(msg)
                        }
                    }
                
                    var ret = try parent.cli.help.executeAndWait(arguments: arguments,
                                                          environment: environment,
                                                          currentDirectory: currentDirectory)
                    if ret == 0 && message != nil { ret = 1 }
                    return ret
                
                case .custom(let cA):
                    return try cA.execute(parent: parent,
                                          argumentStartingAt: argumentStartingAt,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          withMessage: message)
            }
        }
    }
    
    private enum ParentOrRootStorage {
        case parent(CLICommandGroup)
        case root(cli: CLIWrapper.CLIInterface,
                  helpRequestIdentifier: CLIWrapper.HelpArgumentIdentifier)
        
        public var parent: CLICommandGroup? {
            guard case .parent(let ret) = self else {
                return nil
            }
            return ret
        }
        
        public var cli: CLIWrapper.CLIInterface {
            switch self {
                case .parent(let p):
                    return p.storage.cli
            case .root(cli: let ret, helpRequestIdentifier: _):
                    return ret
            }
        }
        
        /// The closure used to identify if the current argument list is trying to request a help screen
        public var helpRequestIdentifier: CLIWrapper.HelpArgumentIdentifier {
            switch self {
                case .parent(let p):
                    return p.helpRequestIdentifier
                case .root(cli: _,
                           helpRequestIdentifier: let ret):
                    return ret
            }
        }
        
    }
   
    /// Storage for root group or reference to parent group
    private let storage: ParentOrRootStorage
   
    
    /// An array of sub commands
    private var commands: [CLICommand] = []
    /// Action for handling help commnds
    private let helpAction: HelpAction
    
    /// The parent group of this group
    public var parentGroup: CLICommandGroup {
        return self.storage.parent ?? self
    }
    /// The root group of all groups
    public var rootGroup: CLICommandGroup {
        return self.storage.parent?.rootGroup ?? self
    }

    /// The DispatchQueue used when outputing anything to the console
    public var outputQueue: DispatchQueue {
        return self.storage.cli.outputQueue
    }
    /// The closure used to create a new CLI Process
    public var cli: CLIWrapper.CLIInterface {
        return self.storage.cli
    }
    
    /// The closure used to identify if the current argument list is trying to request a help screen
    public var helpRequestIdentifier: CLIWrapper.HelpArgumentIdentifier {
        return self.storage.helpRequestIdentifier
    }
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The action to execute
    ///   - cli: The CLI Interace to call CLI Commands
    ///   - helpRequestIdentifier: Closure used to identify if help handler should be called
    internal init(regEx: RegEx,
                  helpAction: HelpAction = .passthrough,
                  defaultAction: CLIAction?,
                  cli: CLIWrapper.CLIInterface,
                  helpRequestIdentifier: @escaping CLIWrapper.HelpArgumentIdentifier) {
        
        // If we are a root group and the help is use parent then we'll switch to passthrough
        var hA = helpAction
        if hA.isUseParentAction { hA = .passthrough }
        
        self.storage = .root(cli: cli,
                             helpRequestIdentifier: helpRequestIdentifier)
        self.helpAction = hA
        super.init(regEx: regEx, action: defaultAction)
    }
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - action: The action to execute
    ///   - parent: Parent group of this group
    internal init(regEx: RegEx,
                  helpAction: HelpAction = .useParentAction,
                  defaultAction: CLIAction?,
                  parent: CLICommandGroup) {
        self.storage = .parent(parent)
        self.helpAction = helpAction
        super.init(regEx: regEx,
                   action: defaultAction)
    }
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - command: The string value of the command to match
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The action to execute
    ///   - cli: The CLI Interace to call CLI Commands
    ///   - helpRequestIdentifier: Closure used to identify if help handler should be called
    internal init(command: String,
                  caseSensitive: Bool = false,
                  helpAction: HelpAction = .passthrough,
                  defaultAction: CLIAction?,
                  cli: CLIWrapper.CLIInterface,
                  helpRequestIdentifier: @escaping CLIWrapper.HelpArgumentIdentifier) {
        
        // If we are a root group and the help is use parent then we'll switch to passthrough
        var hA = helpAction
        if hA.isUseParentAction { hA = .passthrough }
        
        self.storage = .root(cli: cli,
                             helpRequestIdentifier: helpRequestIdentifier)
        self.helpAction = hA
        super.init(command: command,
                   caseSensitive: caseSensitive,
                   action: defaultAction)
    }
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - command: The string value of the command to match
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The action to execute
    ///   - parent: Parent group of this group
    internal init(command: String,
                  caseSensitive: Bool = false,
                  helpAction: HelpAction = .useParentAction,
                  defaultAction: CLIAction?,
                  parent: CLICommandGroup) {
        self.storage = .parent(parent)
        self.helpAction = helpAction
        super.init(command: command,
                   caseSensitive: caseSensitive,
                   action: defaultAction)
    }
    
    
    
    public func addCommand(_ command: CLICommand) {
        self.commands.append(command)
    }
    
    
    internal override func executeIfWrapped(parent: CLICommandGroup,
                                            argumentStartingAt: Int,
                                            arguments: [String],
                                            environment: [String: String]? = nil,
                                            currentDirectory: URL? = nil,
                                            standardInput: Any? = nil) throws -> Int32? {
        if let command = self.commands.first(where: { return $0.command.matches(arguments[argumentStartingAt]) }) {
            return try command.executeIfWrapped(parent: self,
                                                argumentStartingAt: argumentStartingAt + 1,
                                                arguments: arguments,
                                                environment: environment,
                                                currentDirectory: currentDirectory,
                                                standardInput: standardInput)
        } else if self.rootGroup.helpRequestIdentifier(arguments) {
            return try self.helpAction.execute(parent: self,
                                               argumentStartingAt: argumentStartingAt,
                                               arguments: arguments,
                                               environment: environment,
                                               currentDirectory: currentDirectory)
        } else {
            // do default processing
            return try super.executeIfWrapped(parent: parent,
                                              argumentStartingAt: argumentStartingAt,
                                              arguments: arguments,
                                              environment: environment,
                                              currentDirectory: currentDirectory,
                                              standardInput: standardInput)
        }
    }
    
    internal override func execute(parent: CLICommandGroup,
                                   argumentStartingAt: Int,
                                   arguments: [String],
                                   environment: [String: String]? = nil,
                                   currentDirectory: URL? = nil,
                                   standardInput: Any? = nil) throws -> Int32 {
        
        if let command = self.commands.first(where: { return $0.command.matches(arguments[argumentStartingAt]) }) {
            return try command.execute(parent: self,
                                       argumentStartingAt: argumentStartingAt + 1,
                                       arguments: arguments,
                                       environment: environment,
                                       currentDirectory: currentDirectory,
                                       standardInput: standardInput)
        } else if self.rootGroup.helpRequestIdentifier(arguments) {
            return try self.helpAction.execute(parent: self,
                                               argumentStartingAt: argumentStartingAt,
                                               arguments: arguments,
                                               environment: environment,
                                               currentDirectory: currentDirectory)
        } else {
            // do default processing
            return try super.execute(parent: parent,
                                     argumentStartingAt: argumentStartingAt,
                                     arguments: arguments,
                                     environment: environment,
                                     currentDirectory: currentDirectory,
                                     standardInput: standardInput)
        }
    }
    
    
    
    /// Executes the help command
    /// - Parameters:
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: A custom message to display with the help message.
    ///   If the action is passthrough then the message will be displayed before the real help message
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    @discardableResult
    public func executeHelp(argumentStartingAt: Int = 0,
                            arguments: [String],
                            environment: [String: String]? = nil,
                            currentDirectory: URL? = nil,
                            withMessage message: String? = nil) throws -> Int32 {
        
        return try self.helpAction.execute(parent: self,
                                           argumentStartingAt: argumentStartingAt,
                                           arguments: arguments,
                                           environment: environment,
                                           currentDirectory: currentDirectory,
                                           withMessage: message)
    }
}

public extension CLICommandGroup {
    /// Method used to execute the command action if not passthrough
    /// - Parameters:
    ///  - arguments: The arguments for the specific command
    ///  - environment: The enviromental variables to set
    ///  - currentDirectory: The current working directory to set
    ///  - standardInput: The standard input to set the core process
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    func executeIfWrapped(_ arguments: [String],
                          environment: [String: String]? = nil,
                          currentDirectory: URL? = nil,
                          standardInput: Any? = nil) throws -> Int32? {
        return try self.rootGroup.executeIfWrapped(parent: self.rootGroup,
                                                   argumentStartingAt: 0,
                                                   arguments: arguments,
                                                   environment: environment,
                                                   currentDirectory: currentDirectory,
                                                   standardInput: standardInput)
    }
    
    /// Method used to execute the command action
    /// - Parameters:
    ///  - arguments: The arguments for the specific command
    ///  - environment: The enviromental variables to set
    ///  - currentDirectory: The current working directory to set
    ///  - standardInput: The standard input to set the core process
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    @discardableResult
    func execute(_ arguments: [String],
                 environment: [String: String]? = nil,
                 currentDirectory: URL? = nil,
                 standardInput: Any? = nil) throws -> Int32 {
        
        return try self.rootGroup.execute(parent: self.rootGroup,
                                          argumentStartingAt: 0,
                                          arguments: arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          standardInput: standardInput)
        
    }
}

public extension CLICommandGroup {
    /// Create a new Group Command
    /// - Parameters:
    ///   - command: The command to handle
    ///   - caseSensative: Indicator if the command is case sensative
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroup(command: String,
                            caseSensitive: Bool = true,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultAction: CLIAction? = nil) -> CLICommandGroup {
        let cmd = CLICommandGroup(command: command,
                                  caseSensitive: caseSensitive,
                                  helpAction: helpAction,
                                  defaultAction: defaultAction,
                                  parent: self)
        self.addCommand(cmd)
        return cmd
    }
    
    /// Create a new Group Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - helpAction: Handler to handle help parameters
    ///   - defaultAction: The default action to execute if no sub command is found
    /// - Returns: Returns the newly created command group
    func createCommandGroup(regEx: RegEx,
                            helpAction: CLICommandGroup.HelpAction = .passthrough,
                            defaultAction: CLIAction? = nil) -> CLICommandGroup {
        let cmd = CLICommandGroup(regEx: regEx,
                                  helpAction: helpAction,
                                  defaultAction: defaultAction,
                                  parent: self)
        self.addCommand(cmd)
        return cmd
    }
}
