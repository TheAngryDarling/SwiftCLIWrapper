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
    
    public enum HelpAction {
        case passthrough
        case custom(CLIHelpAction)
        
        fileprivate var groupHelpAction: CLICommandGroup.HelpAction {
            switch self {
                case .passthrough:
                    return .passthrough
                case .custom(let c):
                    return .custom(c)
            }
        }
    }
    
    public struct STDOutputCapturing {
        
        public var processBuffer: CLICapture.STDOutputBuffer?
        public var helpProcessBuffer: CLICapture.STDOutputBuffer?
        
        private init(processBuffer: CLICapture.STDOutputBuffer?,
                     helpProcessBuffer: CLICapture.STDOutputBuffer?) {
            self.processBuffer = processBuffer
            self.helpProcessBuffer = helpProcessBuffer
        }
        
        public static func capture(using buffer: CLICapture.STDOutputBuffer) -> STDOutputCapturing {
            return .init(processBuffer: buffer,
                         helpProcessBuffer: buffer)
        }
        public static func capture(processBuffer: CLICapture.STDOutputBuffer,
                                     helpProcessBuffer: CLICapture.STDOutputBuffer? = nil) -> STDOutputCapturing {
            return .init(processBuffer: processBuffer,
                         helpProcessBuffer: helpProcessBuffer)
        }
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
    
    
    public class CLIInterface: CLICapture {
        public let help: CLICapture
        
        public init(outputQueue: DispatchQueue,
                    outputCapturing: STDOutputCapturing? = nil,
                    createProcess: @escaping CLICapture.CreateProcess,
                    createHelpProcess: @escaping CLICapture.CreateProcess) {
            self.help = CLICapture(outputQueue: outputQueue,
                                   stdOutBuffer: outputCapturing?.helpProcessBuffer,
                                   stdErrBuffer:  outputCapturing?.helpProcessBuffer,
                                   createProcess: createHelpProcess)
            super.init(outputQueue: outputQueue,
                       stdOutBuffer: outputCapturing?.processBuffer,
                       stdErrBuffer:  outputCapturing?.processBuffer,
                       createProcess: createProcess)
        }
    }
    
    
    private let rootGroup: CLICommandGroup
    public var cli: CLICapture { return self.rootGroup.cli }
    
    
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputQueue: The queue to use to execute output actions in sequential order
    ///   - helpRequestIdentifier: Closure used to identify if help handler should be called
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - createCLIHelpProcess: The closure used to create the cli Help process
    public init(outputQueue: DispatchQueue? = nil,
                helpRequestIdentifier: @escaping HelpArgumentIdentifier = CLIWrapper.defaultHelpRequestIdentifier,
                helpAction: HelpAction = .passthrough,
                outputCapturing: STDOutputCapturing? = nil,
                createCLIProcess: @escaping CreateProcess,
                createCLIHelpProcess: @escaping CreateProcess) {
        
        
        self.rootGroup = CLICommandGroup.init(command: "",
                                         helpAction: helpAction.groupHelpAction,
                                         defaultAction: nil,
                                         cli: CLIInterface(outputQueue: outputQueue ?? DispatchQueue(label: "CLIWrapper.Output.Queue"),
                                                           outputCapturing: outputCapturing,
                                                           createProcess: createCLIProcess,
                                                           createHelpProcess: createCLIHelpProcess),
                                         helpRequestIdentifier: helpRequestIdentifier)
    }
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputQueue: The queue to use to execute output actions in sequential order
    ///   - helpArguments: An array of arguments that can be used to call the help screen
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - createCLIHelpProcess: The closure used to create the cli Help process
    public init(outputQueue: DispatchQueue? = nil,
                helpArguments: [String],
                helpAction: HelpAction = .passthrough,
                outputCapturing: STDOutputCapturing? = nil,
                createCLIProcess: @escaping CreateProcess) {
        precondition(!helpArguments.isEmpty, "Must have atleast one help argument")
        precondition(!helpArguments.contains(where: { return $0.trimmingCharacters(in: .whitespaces).isEmpty }), "Help argumetns can not be empty or whitespace")
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
        
        self.rootGroup = CLICommandGroup(command: "",
                                         helpAction: helpAction.groupHelpAction,
                                         defaultAction: nil,
                                         cli: CLIInterface(outputQueue: outputQueue ?? DispatchQueue(label: "CLIWrapper.Output.Queue"),
                                                           outputCapturing: outputCapturing,
                                                           createProcess: createCLIProcess,
                                                           createHelpProcess: createCLIHelpProcess),
                                         helpRequestIdentifier: helpRequestIdentifier)
    }
    
    
    /// Create a new CLIWrapper
    /// - Parameters:
    ///   - outputQueue: The queue to use to execute output actions in sequential order
    ///   - helpArguments: An array of arguments that can be used to call the help screen
    ///   - helpAction: The help handler to execute
    ///   - outputCapturing: The capturing option to capture data being directed to the output
    ///   - createCLIProcess: The closure used to create the cli process
    ///   - executable: The URL to the executable
    public init(outputQueue: DispatchQueue? = nil,
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
        
        self.rootGroup = CLICommandGroup(command: "",
                                         helpAction: helpAction.groupHelpAction,
                                         defaultAction: nil,
                                         cli: CLIInterface(outputQueue: outputQueue ?? DispatchQueue(label: "CLIWrapper.Output.Queue"),
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
