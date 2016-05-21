//
//  Signal.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public typealias SignalCallback = () -> Void

public protocol Signal {
    func on(callback: SignalCallback)
}