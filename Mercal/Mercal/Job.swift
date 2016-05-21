//
//  Job.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

// A processable job
public protocol Job {
    // Destroys the job from the store
    func consume() throws
    
    // Unlocks the job in the store optionally setting a date to retry after
    func restore(retryAfter: NSDate) throws
    
    // Task attached to this job
    var task: Task { get }
}