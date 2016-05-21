//
//  Execution.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public typealias AsyncDone = (Result) -> Void

public typealias AsyncExecution = (AsyncDone) -> Void

public enum Execution {
    case Asynchronous(AsyncExecution)
    case Synchronous(Result)
}
