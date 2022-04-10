//
//  CLIPostActionOutputEventHandler.swift
//  
//
//  Created by Tyler Anger on 2022-03-26.
//

import Foundation
import Dispatch
import CLICapture

public struct CLIPostActionOutputEventHandler<Storage> {
    
    /// Definition of a Output Event Handler
    /// - Parameters:
    ///   - event: The output event that occured
    ///   - error: Any error code that occured while trying to read the output
    ///   - storage: Storage used to keep track of any data
    internal typealias DispatchEventHandler = (_ event: CLICapturedOutputEvent<DispatchData>,
                                               _ storage: inout Storage?) -> Void
    
    internal let queue: DispatchQueue?
    internal let eventHandler: DispatchEventHandler
    public let isNone: Bool
    
    fileprivate init() {
        self.queue = nil
        self.eventHandler = { _, _ in }
        self.isNone = true
    }
    /// Create new Output Event Handler Object
    /// - Parameters:
    ///   - queue: The dispatch queue to execute the event handler on
    ///   - eventHandler: The event handler to execute when data is available
    fileprivate init(queue: DispatchQueue? = nil,
                     eventHandler: @escaping DispatchEventHandler) {
        self.queue = queue
        self.eventHandler = eventHandler
        self.isNone = false
    }
    /// No event output handler
    public static var none: CLIPostActionOutputEventHandler { return .init() }
}

public extension CLIPostActionOutputEventHandler where Storage: CLIWrapperStorage {
    
    
    /// Create new Output Event Handler Object
    /// - Parameters:
    ///   - queue: The dispatch queue to execute the event handler on
    ///   - eventHandler: The event handler to execute when data is available
    ///   - event: The output event that occured
    ///   - error: Any error code that occured while trying to read the output
    static func handler<CaptureData>(queue: DispatchQueue? = nil,
                                     eventHandler: @escaping (_ event: CLICapturedOutputEvent<CaptureData>,
                                                              _ storage: inout Storage?) -> Void) -> CLIPostActionOutputEventHandler<Storage> {
        
        if let f = eventHandler as? DispatchEventHandler {
            return .init(queue: queue,
                         eventHandler: f)
        } else {
            return .init(queue: queue) { dispatchEvent, storage in
                
                //let event = (dispatchEvent as? CLICapturedOutputEvent<CaptureData>) ?? CLICapturedOutputEvent<CaptureData>(dispatchEvent)
                let event = CLICapturedOutputEvent<CaptureData>(dispatchEvent)
                
                eventHandler(event, &storage)
            }
        }
    }
    /// Create new Output Event Handler Object
    /// - Parameters:
    ///   - queue: The dispatch queue to execute the event handler on
    ///   - eventHandler: The event handler to execute when data is available
    ///   - event: The output event that occured
    ///   - error: Any error code that occured while trying to read the output
    static func dataHandler(queue: DispatchQueue? = nil,
                            eventHandler: @escaping (_ event: CLICapturedOutputEvent<Data>,
                                                     _ storage: inout Storage?) -> Void) -> CLIPostActionOutputEventHandler<Storage> {
        return self.handler(queue: queue,
                            eventHandler: eventHandler)
    }
}

public extension CLIPostActionOutputEventHandler where Storage == Void {
    
    /// Create new Output Event Handler Object
    /// - Parameters:
    ///   - queue: The dispatch queue to execute the event handler on
    ///   - eventHandler: The event handler to execute when data is available
    ///   - event: The output event that occured
    ///   - error: Any error code that occured while trying to read the output
    static func handler<CaptureData>(queue: DispatchQueue? = nil,
                                     eventHandler: @escaping (_ event: CLICapturedOutputEvent<CaptureData>) -> Void) -> CLIPostActionOutputEventHandler<Storage> {
        
        return .init(queue: queue) { dispatchEvent, storage in
            //let event = (dispatchEvent as? CLICapturedOutputEvent<CaptureData>) ?? CLICapturedOutputEvent<CaptureData>(dispatchEvent)
            let event = CLICapturedOutputEvent<CaptureData>(dispatchEvent)
            
            eventHandler(event)
        }
    }
    
    /// Create new Output Event Handler Object
    /// - Parameters:
    ///   - queue: The dispatch queue to execute the event handler on
    ///   - eventHandler: The event handler to execute when data is available
    ///   - event: The output event that occured
    ///   - error: Any error code that occured while trying to read the output
    static func dataHandler(queue: DispatchQueue? = nil,
                            eventHandler: @escaping (_ event: CLICapturedOutputEvent<Data>) -> Void) -> CLIPostActionOutputEventHandler<Storage> {
        return self.handler(queue: queue,
                            eventHandler: eventHandler)
    }
}


