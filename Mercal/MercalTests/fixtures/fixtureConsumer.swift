//
//  fixtureConsumer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

protocol fixtureConsumer {
    func jobCompleted(job: fixtureJob)
}