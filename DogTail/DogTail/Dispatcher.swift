//
//  Dispatcher.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public typealias Tick = () -> Void

public protocol Dispatcher {
    func addOperationWithBlock(tick: Tick)
}

extension NSOperationQueue : Dispatcher {}