//
//  SimpleSignal.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/22/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public class SimpleSignal : Signal {
    public var emitted:SignalEmitBlock?
    
    public init() {
        
    }
    
    public func emit() {
        emitted?()
    }
}