//
//  fixturePredefinedConsumer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixturePredefinedConsumer : Consumer, fixtureConsumer {
    init() {
        
    }
    
    convenience init(job: fixtureJob) {
        self.init()
        addJob(job)
    }
    
    private var jobs = [fixtureJob]()
    
    func addJob(newJob: fixtureJob) {
        let job = newJob
        job.consumer = self
        jobs.append(job)
    }
    
    func next() throws -> Job? {
        return jobs.filter { entry in entry.after == nil || NSDate().timeIntervalSinceDate(entry.after!) < 0 }.first
    }
    
    func jobCompleted(job: fixtureJob) {
        guard let index = jobs.indexOf(job) else {
            return
        }
        jobs.removeAtIndex(index)
    }
    
    func clear() {
        jobs.removeAll()
    }
}