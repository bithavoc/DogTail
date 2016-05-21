//
//  Analyzer.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public protocol Analyzer {
    func analyze(error:ErrorType) -> Result
}