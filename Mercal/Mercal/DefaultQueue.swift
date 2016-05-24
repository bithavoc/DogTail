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
    public private(set) var signals = [Signal]()
    public private(set) var conditions = [Condition]()
    public private(set) var analyzers = [Analyzer]()
    
    public var ticked: TickCallback?
    
    public private(set) var consumer: Consumer!
    private var dispatcher: Dispatcher!
    private let lockQueue = dispatch_queue_create("Mercal.SyncQueue", nil)
    
    public init() {
        
    }
    
    public func activate(dispatcher: Dispatcher) {
        if activated {
            fatalError("Unable to activate, queue has been activated already")
        }
        guard let _ = self.consumer else {
            fatalError("Unable to activate, consumer missing")
        }
        self.dispatcher = dispatcher
        self.changeSignalsSubscription(subscribe: true)
        self.activated = true
        wakeUp()
    }
    
    private var _activated = false
    public private(set) var activated:Bool {
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
    
    private var _executing = false
    private var executing:Bool {
        get {
            var value = false
            dispatch_sync(lockQueue) {
                value = self._executing
            }
            return value
        }
        set(value) {
            dispatch_sync(lockQueue) {
                self._executing = value
            }
        }
    }
    
    public func shutdown() {
        self.changeSignalsSubscription(subscribe: false)
        self.activated = false
    }
    
    private func changeSignalsSubscription(subscribe subscribing:Bool) {
        for var signal in signals {
            if subscribing {
                signal.emitted = { [weak self] in
                    self?.wakeUp()
                }
            } else {
                for var signal in signals {
                    signal.emitted = nil
                }
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
        if executing {
            return
        }
        executing = true
        createTicketOutcome() { outcome in
            defer {
                self.executing = false
            }
            self.ticked?(outcome: outcome)
            switch outcome {
            case .Empty: break
            default:
                self.wakeUp()
            }
        }
    }
    
    private typealias outcomeOutputBlock = (outcome: Outcome) -> Void
    
    private func createTicketOutcome(block: outcomeOutputBlock) {
        switch self.checkConditions() {
        case .Await(let condition):
            return block(outcome: Outcome.ConditionAwait(condition: condition))
        case .Error(let condition, let error):
            return block(outcome: Outcome.ConditionError(error: error, condition: condition))
        case .Ready:
            processNextJob(block)
        }
    }
    
    private func processNextJob(block: outcomeOutputBlock) {
        do {
            let job = try consumer.next()
            return processJob(job, block: block)
        } catch let err {
            return block(outcome: .ConsumerIterationError(error: err))
        }
    }
    
    private func processJob(job: Job?, block: outcomeOutputBlock) {
        guard let job = job else {
            return block(outcome: .Empty)
        }
        let task = job.task
        do {
            let execution = try task.execute()
            return handleExecution(execution, job: job, block: block)
        } catch(let err) {
            return block(outcome: handleTaskFailure(err, job: job))
        }
    }
    
    private func handleExecution(execution: Execution, job: Job, block: outcomeOutputBlock) {
        switch execution {
        case .Synchronous(let result):
            return block(outcome: handleTaskResult(result, job: job))
        case .Asynchronous(let execution):
            execution({ result in
                self.dispatcher.addOperationWithBlock {
                    block(outcome: self.handleTaskResult(result, job: job))
                }
            })
        }
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
        do {
            try job.consume()
            return .AnalyzedTaskCompleted(job: job, analyzer: analyzer)
        } catch(let err) {
            return .ConsumeFailure(error: err, job: job)
        }
    }
    
    private func handleAnalyzerTaskRetry(job: Job, analyzer: Analyzer, after: NSDate) -> Outcome {
        do {
            try job.retryAfter(after)
            return .AnalyzedTaskRetry(job: job, analyzer: analyzer, after: after)
        } catch(let err) {
            return .RetryFailure(error: err, job: job)
        }
    }
    
    private func handleTaskResult(result: Result, job:Job) -> Outcome {
        switch result {
        case .Completed:
            return handleTaskCompleted(job)
        case .Retry(let after):
            return handleTaskRetry(job, after: after)
        case .Failed(let error):
            return handleTaskFailure(error, job: job)
        }
    }
    
    private func handleTaskCompleted(job: Job) -> Outcome {
        do {
            try job.consume()
            return .Completed(job: job)
        } catch(let err) {
            return .ConsumeFailure(error: err, job: job)
        }
    }
    
    private func handleTaskRetry(job: Job, after: NSDate) -> Outcome {
        do {
            try job.retryAfter(after)
            return .Retry(job: job, after: after)
        } catch(let err) {
            return .ConsumeFailure(error: err, job: job)
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
    
    public func install(plugin: Plugin) {
        if activated {
            fatalError("Unable to install plugins once the queue has been activated")
        }
        if let provider = plugin as? ConditionsProvider {
            self.conditions.appendContentsOf(provider.conditions)
        }
        if let provider = plugin as? SignalsProvider {
            self.signals.appendContentsOf(provider.signals)
        }
        if let provider = plugin as? AnalyzersProvider {
            self.analyzers.appendContentsOf(provider.analyzers)
        }
        if let provider = plugin as? ConsumerProvider {
            self.consumer = provider.createConsumer()
        }
    }
}