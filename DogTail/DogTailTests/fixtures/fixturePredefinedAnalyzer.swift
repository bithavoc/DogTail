//
//  fixturePredefinedAnalyzer.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

import DogTail

class fixturePredefinedAnalyzer : Analyzer {
    let result: AnalysisResult
    let name: String
    var analyzeCount = 0
    
    init(name: String, result: AnalysisResult) {
        self.result = result
        self.name = name
    }
    
    func analyze(error: ErrorType, task: Task) -> AnalysisResult {
        analyzeCount += 1
        return self.result
    }
}