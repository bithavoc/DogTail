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
    let checkResult: Check
    
    init(checkResult: Check) {
        self.checkResult = checkResult
    }
    
    func check(queue: Queue) -> Check {
        return self.checkResult
    }
}