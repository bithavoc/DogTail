//
//  Result.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public enum Result {
    case Completed
    case Retry(after: NSDate)
    case Failed(error: ErrorType)
}