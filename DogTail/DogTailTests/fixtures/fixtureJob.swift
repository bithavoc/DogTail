//
//  fixtureJob.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import DogTail

class fixtureJob : NSObject, Job {
    var consumer: fixtureConsumer?
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
    var after:NSDate?
    func retryAfter(after: NSDate) throws {
        retryCount += 1
        self.after = after
    }
}