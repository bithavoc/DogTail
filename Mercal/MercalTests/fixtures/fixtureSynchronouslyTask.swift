//
//  fixtureSynchronouslyTask.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/22/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

import Mercal

class fixtureSynchronouslyTask : Task {
    let execution: Execution
    
    init(execution: Execution) {
        self.execution = execution
    }
    
    func execute() throws -> Execution {
        return self.execution
    }
}