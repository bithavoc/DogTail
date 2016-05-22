//
//  DefaultQueue.swift
//  Mercal
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import Foundation

/*
 Default implementation of Queue
 */
public class DefaultQueue : Queue {
    public var signals = [Signal]()
    public var conditions = [Condition]()
    public var analyzers = [Analyzer]()
    
    public var ticked: TickCallback?
    
    private var consumer: Consumer!
    private var dispatcher: Dispatcher!
    private let lockQueue = dispatch_queue_create("Mercal.DefaultQueue", nil)
    
    public init() {
        
    }
    
    public func activate(consumer: Consumer, dispatcher: Dispatcher) {
        self.subscribeToSignals()
        self.consumer = consumer
        self.dispatcher = dispatcher
        subscribeToSignals()
        self.activated = true
        wakeUp()
    }
    
    private var _activated = false
    private var activated:Bool {
        get {
            var value = false
            dispatch_sync(lockQueue) {
                value = self._activated
            }
            return value
        }
        set(value) {
            dispatch_sync(lockQueue) {
               self._activated = value
            }
        }
    }
    
    public func shutdown() {
        self.signals.removeAll()
        self.activated = false
    }
    
    private func subscribeToSignals() {
        for signal in signals {
            signal.on { [weak self] in
                self?.wakeUp()
            }
        }
    }
    
    private func wakeUp() {
        self.dispatcher.addOperationWithBlock { [weak self] in
            self?.tick()
        }
    }
    
    private func tick() {
        if !activated {
            return
        }
        let outcome = createTicketOutcome()
        self.ticked?(outcome: outcome)
    }
    
    private func createTicketOutcome() -> Outcome {
        switch self.checkConditions() {
        case .Await(let condition):
            return Outcome.ConditionAwait(condition: condition)
        case .Error(let condition, let error):
            return Outcome.ConditionError(error: error, condition: condition)
        case .Ready:
            return processNextJob()
        }
    }
    
    private func processNextJob() -> Outcome {
        do {
            let job = try consumer.next()
            return processJob(job)
        } catch let err {
            return .ConsumerIterationError(error: err)
        }
    }
    
    private func processJob(job: Job?) -> Outcome {
        guard let job = job else {
            return .Empty
        }
        let task = job.task
        do {
            let execution = try task.execute()
        } catch(let err) {
            return handleTaskFailure(err, job: job)
        }
        return .Completed(job: job)
    }
    
    private func handleTaskFailure(err: ErrorType, job: Job) -> Outcome {
        for analyzer in self.analyzers {
            let analysis = analyzer.analyze(err, task: job.task)
            switch analysis {
            case .Completed:
                return handleAnalyzerTaskCompleted(job, analyzer: analyzer)
            case .Retry(let after):
                return handleAnalyzerTaskRetry(job, analyzer: analyzer, after: after)
            case .Unknown:
                continue
            }
        }
        return .UnanalyzedTaskFailure(error: err, task: job.task)
    }
    
    private func handleAnalyzerTaskCompleted(job: Job, analyzer: Analyzer) -> Outcome {
        defer {
            self.wakeUp()
        }
        do {
            try job.consume()
            return .AnalyzedTaskCompleted(job: job, analyzer: analyzer)
        } catch(let err) {
            return .ConsumeFailure(error: err, job: job)
        }
    }
    
    private func handleAnalyzerTaskRetry(job: Job, analyzer: Analyzer, after: NSDate) -> Outcome {
        defer {
            self.wakeUp()
        }
        do {
            try job.retryAfter(after)
            return .AnalyzedTaskRetry(job: job, analyzer: analyzer, after: after)
        } catch(let err) {
            return .RetryFailure(error: err, job: job)
        }
    }
    
    private func checkConditions() -> awaitConditionResult {
        for condition in conditions {
            do {
                switch try condition.check(self) {
                case .Await:
                    return .Await(condition: condition)
                case .Continue:
                    continue
                }
            } catch(let err) {
                return .Error(condition: condition, error: err)
            }
        }
        return .Ready
    }
    
    private enum awaitConditionResult {
        case Await(condition: Condition)
        case Error(condition: Condition, error: ErrorType)
        case Ready
    }
}