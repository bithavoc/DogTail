//
//  JobsConsumer.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

/*
 Consumer of Jobs
 */
public protocol Consumer {
    // fetches the next job if there is one available, otherwise nil
    func next() throws -> Job?
}