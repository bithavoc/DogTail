//
//  fixturePredefinedConsumer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixturePredefinedConsumer : Consumer {
    private let job: Job?
    init(job: Job?) {
        self.job = job
    }
    
    func next() throws -> Job? {
        return self.job
    }
}
