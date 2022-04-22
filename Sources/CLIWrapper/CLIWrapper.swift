//
//  CLIWrapper.swift
//  CLIWrapper
//
//  Created by Tyler Anger on 2022-03-15.
//

import Foundation
import Dispatch
import RegEx
import CLICapture

/// Class representing the CLI Command
open class CLIWrapper: CLICommandCollection {
    /// Action to execute for help actions
    public enum HelpAction {
        /// Pass through to the CLI proces
        case passthrough
        /// Execute a custom action
        case custom(CLIHelpAction)
        /// Converstion from CLIWrapper.HelpAction to CLICommandGroup.HelpAction
        fileprivate var groupHelpAction: CLICommandGroup.HelpAction {
            switch self {
                case .passthrough:
                    return .passthrough
                case .custom(let c):
                    return .custom(c)
            }
        }
    }
    
    /// STD Capturing for the CLICapture
    public struct STDOutputCapturing {
        /// The buffer to use to capture STD Output from the CL Interface
        public var processBuffer: CLICapture.STDOutputBuffer?
        /// The buffer to use to capture the STD Output from the CL Help Interface
        public var helpProcessBuffer: CLICapture.STDOutputBuffer?
        
        private init(processBuffer: CLICapture.STDOutputBuffer?,
                     helpProcessBuffer: CLICapture.STDOutputBuffer?) {
            self.processBuffer = processBuffer
            self.helpProcessBuffer = helpProcessBuffer
        }
        
        /// Capture both process buffer and help buffer to the same buffer
        public static func capture(using buffer: CLICapture.STDOutputBuffer) -> STDOutputCapturing {
            return .init(processBuffer: buffer,
                         helpProcessBuffer: buffer)
        }
        /// Capture process buffer and help buffer seperatley
        public static func capture(processBuffer: CLICapture.STDOutputBuffer,
                                     helpProcessBuffer: CLICapture.STDOutputBuffer) -> STDOutputCapturing {
            return .init(processBuffer: processBuffer,
                         helpProcessBuffer: helpProcessBuffer)
        }
        /// Capture process buffer only
        public static func capture(processBuffer: CLICapture.STDOutputBuffer) -> STDOutputCapturing {
            return .init(processBuffer: processBuffer,
                         helpProcessBuffer: nil)
        }
        /// Capture help buffer only
        public static func capture(helpProcessBuffer: CLICapture.STDOutputBuffer) -> STDOutputCapturing {
            return .init(processBuffer: nil,
                         helpProcessBuffer: helpProcessBuffer)
        }
    }
    
    /// Closure used to create a new CLI Process
    public typealias CreateProcess = (_ arguments: [String],
                                      _ environment: [String: String]?,
                                      _ currentDirectory: URL?,
                                      _ standardInput: Any?) -> Process
    
    /// Closure used to identify if the arguments contain any arguments that would show the help screen
    public typealias HelpArgumentIdentifier = (_ arguments: [String]) -> Bool
    
    /// Interface used to call / capture CLI commands
    public class CLInterface: CLICapture {
        /// Interface used to call / capture CLI help commands
        public let help: CLICapture
        
        
        /// Create new Command Line Interface Object
        /// - Parameters:
        ///   - outputLock: The object used to synchronized output calls
        ///   - outputCapturing: The object used to redirect STD writes from the CLICapture objects
        ///   - createProcess: Closure used to create a new CLI Process
        ///   - createHelpProcess: Closure used to create new CLI Help Process
        public init(outputLock: Lockable,
                    outputCapturing: STDOutputCapturing? = nil,
                    createProcess: @escaping CLICapture.CreateProcess,
                    createHelpProcess: @escaping CLICapture.CreateProcess) {
            self.help = .init(outputLock: outputLock,
                              stdOutBuffer: outputCapturing?.helpProcessBuffer,
                              stdErrBuffer:  outputCapturing?.helpProcessBuffer,
                              createProcess: createHelpProcess)
            super.init(outputLock: outputLock,
                       stdOutBuffer: outputCapturing?.processBuffer,
                       stdErrBuffer:  outputCapturing?.processBuffer,
                       createProcess: createProcess)
        }
    }
    
    /// The root group of the commands
    private let rootGroup: CLICommandGroup
    /// Access to the Command Line Interface Object
    public var cli: CLICapture { return self.rootGroup.cli }
    
    
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputLock: The object used to synchronized output calls
    ///   - supportPreCommandArguments: Indicator if unidentified arguments are allowed before commands for matching purposes
    ///   - helpRequestIdentifier: Closure used to identify if help handler should be called
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - createCLIHelpProcess: The closure used to create the cli Help process
    public init(outputLock: Lockable = NSLock(),
                supportPreCommandArguments: Bool = false,
                helpRequestIdentifier: @escaping HelpArgumentIdentifier = CLIWrapper.defaultHelpRequestIdentifier,
                helpAction: HelpAction = .passthrough,
                outputCapturing: STDOutputCapturing? = nil,
                createCLIProcess: @escaping CreateProcess,
                createCLIHelpProcess: @escaping CreateProcess) {
        
        
        self.rootGroup = .init(command: "",
                               supportPreCommandArguments: supportPreCommandArguments,
                               helpAction: helpAction.groupHelpAction,
                               defaultAction: nil,
                               cli: .init(outputLock: outputLock,
                                          outputCapturing: outputCapturing,
                                          createProcess: createCLIProcess,
                                          createHelpProcess: createCLIHelpProcess),
                               helpRequestIdentifier: helpRequestIdentifier)
    }
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputLock: The object used to synchronized output calls
    ///   - supportPreCommandArguments: Indicator if unidentified arguments are allowed before commands for matching purposes
    ///   - helpArguments: An array of arguments that can be used to call the help screen
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - createCLIHelpProcess: The closure used to create the cli Help process
    public init(outputLock: Lockable = NSLock(),
                supportPreCommandArguments: Bool = false,
                helpArguments: [String],
                helpAction: HelpAction = .passthrough,
                outputCapturing: STDOutputCapturing? = nil,
                createCLIProcess: @escaping CreateProcess) {
        precondition(!helpArguments.isEmpty, "Must have atleast one help argument")
        precondition(!helpArguments.contains(where: { return $0.trimmingCharacters(in: .whitespaces).isEmpty }), "Help arguments can not be empty or whitespace")
        precondition(!helpArguments.contains(where: { return $0.contains(" ") }), "Help argumetns can not contain white spaces")
                     
        func helpRequestIdentifier(_ args: [String]) -> Bool {
            return args.contains {
                return helpArguments.contains($0)
            }
        }
        func createCLIHelpProcess(_ arguments: [String],
                                  _ environment: [String: String]?,
                                  _ currentDirectory: URL?,
                                  _ standardInput: Any?) -> Process {
            var args = arguments
            if !helpRequestIdentifier(args) {
                args.append(helpArguments.first!)
            }
            return createCLIProcess(args,
                                    environment,
                                    currentDirectory,
                                    standardInput)
        }
        
        self.rootGroup = .init(command: "",
                               supportPreCommandArguments: supportPreCommandArguments,
                               helpAction: helpAction.groupHelpAction,
                               defaultAction: nil,
                               cli: .init(outputLock: outputLock,
                                          outputCapturing: outputCapturing,
                                          createProcess: createCLIProcess,
                                          createHelpProcess: createCLIHelpProcess),
                               helpRequestIdentifier: helpRequestIdentifier)
    }
    
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputLock: The object used to synchronized output calls
    ///   - supportPreCommandArguments: Indicator if unidentified arguments are allowed before commands for matching purposes
    ///   - helpArguments: An array of arguments that can be used to call the help screen
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - executable: The URL to the executable
    public init(outputLock: Lockable = NSLock(),
                supportPreCommandArguments: Bool = false,
                helpArguments: [String],
                helpAction: HelpAction = .passthrough,
                outputCapturing: STDOutputCapturing? = nil,
                executable: URL) {
        precondition(!helpArguments.isEmpty, "Must have atleast one help argument")
        precondition(!helpArguments.contains(where: { return $0.trimmingCharacters(in: .whitespaces).isEmpty }), "Help argumetns can not be empty or whitespace")
        precondition(!helpArguments.contains(where: { return $0.contains(" ") }), "Help argumetns can not contain white spaces")
                     
        func helpRequestIdentifier(_ args: [String]) -> Bool {
            return args.contains {
                return helpArguments.contains($0)
            }
        }
        
        func createCLIProcess(_ arguments: [String],
                                  _ environment: [String: String]?,
                                  _ currentDirectory: URL?,
                                  _ standardInput: Any?) -> Process {
            let rtn = Process()
            
            rtn._cliWrapperExecutable = executable
            rtn.arguments = arguments
            if let ev = environment {
                rtn.environment = ev
            }
            if let cd = currentDirectory {
                rtn._cliWrapperCurrentDirectory = cd
            }
            if let si = standardInput {
                rtn.standardInput = si
            }
            
            return rtn
        }
        
        func createCLIHelpProcess(_ arguments: [String],
                                  _ environment: [String: String]?,
                                  _ currentDirectory: URL?,
                                  _ standardInput: Any?) -> Process {
            var args = arguments
            if !helpRequestIdentifier(args) {
                args.append(helpArguments.first!)
            }
            return createCLIProcess(args,
                                    environment,
                                    currentDirectory,
                                    standardInput)
        }
        
        self.rootGroup = .init(command: "",
                               supportPreCommandArguments: supportPreCommandArguments,
                               helpAction: helpAction.groupHelpAction,
                               defaultAction: nil,
                               cli: .init(outputLock: outputLock,
                                          outputCapturing: outputCapturing,
                                          createProcess: createCLIProcess,
                                          createHelpProcess: createCLIHelpProcess),
                               helpRequestIdentifier: helpRequestIdentifier)
    }
    
    public static func defaultHelpRequestIdentifier(_ args: [String]) -> Bool {
        return args.contains {
            return ["--help", "-h"].contains($0.lowercased())
        }
    }
    
    public func addCommand(_ command: CLICommand) {
        self.rootGroup.addCommand(command)
    }
    
    /// Method used to execute the command action
    /// - Parameters:
    ///  - arguments: The arguments for the specific command
    ///  - environment: The enviromental variables to set
    ///  - currentDirectory: The current working directory to set
    ///  - standardInput: The standard input to set the core process
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    @discardableResult
    public func execute(_ arguments: [String],
                        environment: [String: String]? = nil,
                        currentDirectory: URL? = nil,
                        standardInput: Any? = nil) throws -> Int32 {
        
        return try self.rootGroup.execute(arguments,
                                          environment: environment,
                                          currentDirectory: currentDirectory,
                                          standardInput: standardInput)
    }
    
    /// Method used to execute the command action if not passthrough
    /// - Parameters:
    ///  - arguments: The arguments for the specific command
    ///  - environment: The enviromental variables to set
    ///  - currentDirectory: The current working directory to set
    ///  - standardInput: The standard input to set the core process
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    public func executeIfWrapped(_ arguments: [String],
                                 environment: [String: String]? = nil,
                                 currentDirectory: URL? = nil,
                                 standardInput: Any? = nil) throws -> Int32? {
        
        return try self.rootGroup.executeIfWrapped(arguments,
                                                   environment: environment,
                                                   currentDirectory: currentDirectory,
                                                   standardInput: standardInput)
    }
}

// MARK: Create Command Groups
public extension CLIWrapper {
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
        return self.rootGroup.createCommandGroup(command: command,
                                                 caseSensitive: caseSensitive,
                                                 helpAction: helpAction,
                                                 defaultAction: defaultAction)
        
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
        return self.rootGroup.createCommandGroup(regEx: regEx,
                                                 helpAction: helpAction,
                                                 defaultAction: defaultAction)
    }
}


public extension CLIWrapper {
    /// Executes the help command
    /// - Parameters:
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - message: A custom message to display with the help message.
    ///   If the action is passthrough then the message will be displayed before the real help message
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    @discardableResult
    func displayUsage(arguments: [String] = [],
                      environment: [String: String]? = nil,
                      currentDirectory: URL? = nil,
                      withMessage message: String? = nil) throws -> Int32 {
        return try self.rootGroup.executeHelp(argumentStartingAt: 0,
                                              arguments: arguments,
                                              environment: environment,
                                              currentDirectory: currentDirectory,
                                              withMessage: message)
    }
}


