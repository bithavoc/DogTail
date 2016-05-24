//
//  GCDDispatcher.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public struct GCDDispatcher : Dispatcher {
    let queue: dispatch_queue_t
    
    public func addOperationWithBlock(tick: Tick) {
        dispatch_async(queue, tick)
    }
}