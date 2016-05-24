//
//  AnalysisResult.swift
//  DogTail
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public enum AnalysisResult {
    case Completed
    case Retry(after: NSDate)
    case Unknown
}