//
//  Queue.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public protocol Queue {
    // signals to wake up the queue
    var signals: [Signal] { get set }
    
    // conditions to loop
    var conditions: [Condition] { get set }
    
    // analyzers to check conditions on errors
    var analyzers: [Analyzer] { get set }
    
    // executed when a tick occurs
    var ticked: TickCallback? { get set }
    
    // consumer of jobs
    var consumer: Consumer! {  get }
    
    // activates the queue using the given jobs consumer
    mutating func activate(consumer: Consumer, dispatcher: Dispatcher)
    
    // install a pluging that configures the pipeline
    mutating func install(plugin: Plugin)
    
    // shutsdown the processing of jobs
    mutating func shutdown()
}