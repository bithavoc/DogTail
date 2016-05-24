//
//  ConsumerProvider.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/23/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public protocol ConsumerProvider : Plugin {
    func createConsumer() -> Consumer
}