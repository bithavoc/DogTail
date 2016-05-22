//
//  TickOutcome.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

public enum Outcome {
    // condition wants to await
    case ConditionAwait(condition: Condition)
    
    // condition returned an error
    case ConditionError(error: ErrorType, condition: Condition)
    
    // Consumer failed to retrieve next job
    case ConsumerIterationError(error: ErrorType)
    
    // no jobs to be processed
    case Empty
    
    // task failure handled without analyzer
    case UnanalyzedTaskFailure(error: ErrorType, task: Task)
    
    // failure found while consuming job
    case ConsumeFailure(error: ErrorType, job: Job)
    
    // failure found retrying job
    case RetryFailure(error: ErrorType, job: Job)
    
    // task completed successfully
    case Completed(job: Job)
    
    // task was completed by an analyzer
    case AnalyzedTaskCompleted(job: Job, analyzer: Analyzer)
    
    // task was retried by an analyzer
    case AnalyzedTaskRetry(job: Job, analyzer: Analyzer, after: NSDate)
}