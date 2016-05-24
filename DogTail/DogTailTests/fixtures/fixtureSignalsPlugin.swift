//
//  fixtureSignalsPlugin.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/23/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import DogTail

struct fixtureSignalsPlugin : SignalsProvider {
    var name: String = "fixtureSignalsPlugin"
    
    let signals: [Signal]
}
