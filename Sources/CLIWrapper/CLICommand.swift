//
//  CLICommand.swift
//  CLIWrapper
//
//
//  Created by Tyler Anger on 2022-02-23.
//

import Foundation
import Dispatch
import RegEx

//import SwiftPatches
//import HelpfulProtocols


/// Class representing a basic CLI Command
public class CLICommand {
    
    /// Pattern used to match commands
    public enum CommandPattern {
        case literal(String, caseSensitive: Bool)
        case regex(RegEx)
        
        public func matches(_ value: String) -> Bool {
            switch self {
            case .literal(let literal, caseSensitive: let cS):
                if cS { return literal == value }
                else { return  literal.lowercased() == value.lowercased() }
            case .regex(let regEx):
                return !value.match(pattern: regEx).isEmpty
                
            }
        }
    }
    
    /// The CLI command being handled
    public let command: CommandPattern
    /// The action to execute
    public let action: CLIAction?
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - regEx: The regular expression to match the command argument to
    ///   - action: The action to execute
    internal init(regEx: RegEx,
                  action: CLIAction?) {
        self.command = .regex(regEx)
        self.action = action
    }
    
    /// Create new CLI Command
    /// - Parameters:
    ///   - command: The string value of the command to match
    ///   - caseSensitive: Indicator if command is case sensative
    ///   - action: The action to execute
    internal init(command: String,
                  caseSensitive: Bool/* = true*/,
                  action: CLIAction?) {
        self.command = .literal(command, caseSensitive: caseSensitive)
        self.action = action
    }
    
    /// Method used to execute the command action if not passthrough
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    internal func executeIfWrapped(parent: CLICommandGroup,
                                   argumentStartingAt: Int,
                                   arguments: [String],
                                   environment: [String: String]? = nil,
                                   currentDirectory: URL? = nil,
                                   standardInput: Any? = nil) throws -> Int32? {
        return try self.action?.execute(parent: parent,
                                        argumentStartingAt: argumentStartingAt,
                                        arguments: arguments,
                                        environment: environment,
                                        currentDirectory: currentDirectory,
                                        standardInput: standardInput)
    }
    
    /// Method used to execute the command action
    /// - Parameters:
    ///   - parent: The parent CLICommandGroup object or self if the current group is the root
    ///   - argumentStartingAt: The index in the fullArguments this commands arguments start at
    ///   - arguments: An array of all arguments (excluding the executable argument)
    ///   - environment: The environmental variables to set to the cli sub process if called
    ///   - currentDirectory: Set the current working directory
    ///   - standardInput: The standard input to set the cli sub process if called
    /// - Returns: Returns the process response code (0 is OK, any other can be an error code)
    internal func execute(parent: CLICommandGroup,
                          argumentStartingAt: Int,
                          arguments: [String],
                          environment: [String: String]? = nil,
                          currentDirectory: URL? = nil,
                          standardInput: Any? = nil) throws -> Int32 {
        guard let ret = try self.executeIfWrapped(parent: parent,
                                                  argumentStartingAt: argumentStartingAt,
                                                  arguments: arguments,
                                                  environment: environment,
                                                  currentDirectory: currentDirectory,
                                                  standardInput: standardInput) else {
            return try parent.cli.executeAndWait(arguments: arguments,
                                                 environment: environment,
                                                 currentDirectory: currentDirectory,
                                                 standardInput: standardInput)
        }
        return ret
    }
}
