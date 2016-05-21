//
//  fixtureFailingSynchronouslyTask.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

import Mercal

class fixtureFailingSynchronouslyTask : Task {
    let error: ErrorType
    
    init(error: ErrorType) {
        self.error = error
    }
    
    func execute() throws -> Execution {
        throw error
    }
}