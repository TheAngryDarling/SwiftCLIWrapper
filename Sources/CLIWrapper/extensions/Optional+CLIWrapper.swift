//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-20.
//

import Foundation
import CLICapture

public extension Optional where Wrapped == CLIWrapper.STDOutputCapturing {
    /// Capture both process buffer and help buffer to the same buffer
    static func capture(using buffer: CLICapture.STDOutputBuffer) -> CLIWrapper.STDOutputCapturing {
        return CLIWrapper.STDOutputCapturing.capture(using: buffer)
    }
    /// Capture process buffer and help buffer separately
    static func capture(processBuffer: CLICapture.STDOutputBuffer,
                        helpProcessBuffer: CLICapture.STDOutputBuffer) -> CLIWrapper.STDOutputCapturing {
        return CLIWrapper.STDOutputCapturing.capture(processBuffer: processBuffer,
                                                     helpProcessBuffer: helpProcessBuffer)
    }
    /// Capture process buffer only
    static func capture(processBuffer: CLICapture.STDOutputBuffer) -> CLIWrapper.STDOutputCapturing {
        return CLIWrapper.STDOutputCapturing.capture(processBuffer: processBuffer)
    }
    /// Capture help buffer only
    static func capture(helpProcessBuffer: CLICapture.STDOutputBuffer) -> CLIWrapper.STDOutputCapturing {
        return CLIWrapper.STDOutputCapturing.capture(helpProcessBuffer: helpProcessBuffer)
    }
}
