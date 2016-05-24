//
//  fixtureAnalyzersPlugin.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/23/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

struct fixtureAnalyzersPlugin : AnalyzersProvider {
    var name: String = "fixtureAnalyzersPlugin"
    
    let analyzers: [Analyzer]
}
