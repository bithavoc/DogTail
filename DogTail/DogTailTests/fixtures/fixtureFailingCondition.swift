//
//  fixtureFailingCondition.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import DogTail

class fixtureFailingCondition: Condition {
    let error: ErrorType
    let name:String
    
    init(error: ErrorType, name:String = "fixtureFailingCondition") {
        self.error = error
        self.name = name
    }
    
    func check(queue: Queue) throws -> Check {
        throw self.error
    }
}