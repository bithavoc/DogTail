//
//  Analyzer.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public protocol Analyzer {
    var name: String { get }
    func analyze(error:ErrorType, task: Task) -> AnalysisResult
}