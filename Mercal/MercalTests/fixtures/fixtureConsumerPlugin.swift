//
//  fixtureConsumerPlugin.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/23/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation
import Mercal

class fixtureConsumerPlugin : ConsumerProvider {
    var name: String
    private let consumer: Consumer
    
    func createConsumer() -> Consumer {
        return consumer
    }
    
    init(name: String, consumer: Consumer) {
        self.consumer = consumer
        self.name = name
    }
}