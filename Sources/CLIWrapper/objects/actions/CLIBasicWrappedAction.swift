//
//  CLIBasicWrappedAction.swift
//  
//
//  Created by Tyler Anger on 2022-04-09.
//

import Foundation

public struct CLIBasicWrappedAction<PreAction, PostAction>: CLIWrappedAction
where PreAction: CLIWrappedPreAction,
      PostAction: CLIPostAction,
      PreAction.Storage == PostAction.Storage {
    
    public let preAction: PreAction
    public let postAction: PostAction
    
    public init(preAction: PreAction,
                postAction: PostAction) {
        self.preAction = preAction
        self.postAction = postAction
    }
}
