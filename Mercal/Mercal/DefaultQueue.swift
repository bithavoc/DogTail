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
    public private(set) var analyzers = [Analyzer]()
    
    public var ticked: TickCallback?
    
    private var consumer: Consumer!
    private var dispatcher: Dispatcher!
    
    public init() {
        
    }
    
    public func activate(consumer: Consumer, dispatcher: Dispatcher) {
        self.subscribeToSignals()
        self.consumer = consumer
        self.dispatcher = dispatcher
        subscribeToSignals()
        wakeUp()
    }
    
    public func shutdown() {
        
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
            return handleTaskFailure(err, task: task)
        }
        return .Processed(job: job)
    }
    
    private func handleTaskFailure(err: ErrorType, task: Task) -> Outcome {
        return .UnanalyzedTaskFailure(error: err, task: task)
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