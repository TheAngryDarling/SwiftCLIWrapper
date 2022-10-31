//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-19.
//

import Foundation
// Exporting import of CLICapture.Lockable so
// Anyone using CLIWrapper does not need to
// Add dependency for SynchronizeObjects
// Just to reference Lockable for use
// with CLIWrapper and CLICapture
@_exported import protocol CLICapture.Lockable
@_exported import struct CLICapture.CLIStackTrace
@_exported import struct CLICapture.CodeStackTrace

