//
//  fixturePredefinedAnalyzer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

import Mercal

class fixturePredefinedAnalyzer : Analyzer {
    let result: AnalysisResult
    
    init(result: AnalysisResult) {
        self.result = result
    }
    var analyzeCount = 0
    
    func analyze(error: ErrorType, task: Task) -> AnalysisResult {
        analyzeCount += 1
        return self.result
    }
}