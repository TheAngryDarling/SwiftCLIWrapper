//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation

internal extension Process {

    /// The URL to the executable.
    ///
    /// This will figure out which property to use, either launchPath OR executableURL depending on the Swift version and Platform version
    var _cliWrapperExecutable: URL? {
        get {
            #if !swift(>=4.2)
                guard let p = self.launchPath else { return nil }
                return URL(fileURLWithPath: p)
            #else
                if #available(OSX 10.13, *) {
                    return self.executableURL
                } else {
                    guard let p = self.launchPath else { return nil }
                    return URL(fileURLWithPath: p)
                }
            #endif
        }
        set {
            #if !swift(>=4.2)
                if let v = newValue {
                    self.launchPath = v.standardized.resolvingSymlinksInPath().path
                } else {
                    self.launchPath = nil
                }
            #else
                if #available(OSX 10.13, *) {
                    self.executableURL = newValue
                } else {
                    if let v = newValue {
                        self.launchPath = v.standardized.resolvingSymlinksInPath().path
                    } else {
                        self.launchPath = nil
                    }
                }
            #endif
        }
    }
    
    /// The current directory for the receiver.
    ///
    /// This will figure out which property to use, either currentDirectoryPath OR currentDirectoryURL depending on the Swift version and Platform version
    /// If this property isn’t used, the current directory is inherited from the process that created the receiver. This method raises an NSInvalidArgumentException if the receiver has already been launched.
    /// If currentDirectoryURL returns nil and currentDirectoryPath is unavailable then this property will return the URL for FileManager.default.currentDirectoryPath
    var _cliWrapperCurrentDirectory: URL {
        get {
            
            #if !swift(>=4.2)
                return URL(fileURLWithPath: self.currentDirectoryPath)
            #else
                #if _runtime(_ObjC)
                    if #available(OSX 10.13, *) {
                        #if swift(>=4.2)
                            if let url = self.currentDirectoryURL { return url }
                            else { return URL(fileURLWithPath: self.currentDirectoryPath) }
                        #else
                            return self.currentDirectoryURL
                        #endif
                    } else {
                        return URL(fileURLWithPath: self.currentDirectoryPath)
                    }
                #elseif swift(>=5.2)
                    if let url = self.currentDirectoryURL { return url }
                    else { return URL(fileURLWithPath: FileManager.default.currentDirectoryPath) }
                #else
                    return self.currentDirectoryURL
                #endif
            #endif
        }
        set {
            #if !swift(>=4.2)
                self.currentDirectoryPath = newValue.path
            #else
                #if _runtime(_ObjC)
                    if #available(OSX 10.13, *) {
                        self.currentDirectoryURL = newValue
                    } else {
                        self.currentDirectoryPath = newValue.standardized.resolvingSymlinksInPath().path
                    }
                #elseif swift(>=5.0)
                    self.currentDirectoryURL = newValue
                #else
                    self.currentDirectoryPath = newValue.standardized.resolvingSymlinksInPath().path
                #endif
            #endif
        }
    }
}
