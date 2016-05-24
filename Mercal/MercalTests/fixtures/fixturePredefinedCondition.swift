//
//  fixturePredefinedCondition.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

import Mercal

class fixturePredefinedCondition: Condition {
    var name: String
    let checkResult: Check
    
    init(checkResult: Check, name: String = "fixturePredefinedCondition") {
        self.checkResult = checkResult
        self.name = name
    }
    
    func check(queue: Queue) -> Check {
        return self.checkResult
    }
}