//
//  fixturePredefinedJobTask.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixturePredefinedJobTask : Job , fixtureJob {
    var task:Task
    init(task:Task) {
        self.task = task
    }
    
    var consumeCount:Int = 0
    
    func consume() throws {
        consumeCount += 1
        consumer?.jobCompleted(self)
    }
    
    var retryCount:Int = 0
    var lastRetryDate:NSDate?
    func retryAfter(after: NSDate) throws {
        retryCount += 1
        lastRetryDate = after
        consumer?.jobRetry(self, after: after)
    }
    var consumer: fixtureConsumer?
}