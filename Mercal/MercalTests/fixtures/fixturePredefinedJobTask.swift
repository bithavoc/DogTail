//
//  fixturePredefinedJobTask.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixturePredefinedJobTask : Job {
    var task:Task
    init(task:Task) {
        self.task = task
    }
    
    func consume() throws {
        
    }
    
    func restore(retryAfter: NSDate) throws {
        
    }
}