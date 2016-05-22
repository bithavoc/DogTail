//
//  fixturePredefinedConsumer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixturePredefinedConsumer<T where T:Job, T:fixtureJob> : Consumer, fixtureConsumer {
    private var job: T?
    init(job: T?) {
        self.job = job
        if var job = job {
            job.consumer = self
        }
    }
    
    func next() throws -> Job? {
        if let after = jobAfter {
            if NSDate().timeIntervalSinceDate(after) < 0 {
                return nil
            }
        }
        return self.job
    }
    
    func jobCompleted(job: Job) {
        self.job = nil
    }
    
    var jobAfter:NSDate?
    func jobRetry(job: Job, after: NSDate) {
        jobAfter = after
    }
}
