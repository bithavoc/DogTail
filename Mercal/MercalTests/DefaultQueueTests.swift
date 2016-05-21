//
//  MercalTests.swift
//  MercalTests
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import XCTest
import Mercal

class DefaultQueueTests: XCTestCase {
    func testConditionAwait() {
        let expectation = expectationWithDescription("await by intented condition")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer(job: nil)
        
        let backgroundQueue = NSOperationQueue()
        
        queue.conditions.append(fixturePredefinedCondition(checkResult: Check.Continue))
        queue.conditions.append(fixturePredefinedCondition(checkResult: Check.Continue))
        
        let expectedCondition = fixturePredefinedCondition(checkResult: Check.Await)
        queue.conditions.append(expectedCondition)
        
        queue.ticked = { outcome in
            switch outcome {
            case .ConditionAwait(let condition):
                guard let fixture = condition as? fixturePredefinedCondition else {
                    return
                }
                if fixture === expectedCondition {
                    expectation.fulfill()
                }
                
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(5) { err in
            
        }
    }
    
    func testConditionError() {
        let expectation = expectationWithDescription("error found on intended condition")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer(job: nil)
        
        let backgroundQueue = NSOperationQueue()
        
        queue.conditions.append(fixturePredefinedCondition(checkResult: Check.Continue))
        queue.conditions.append(fixturePredefinedCondition(checkResult: Check.Continue))
        
        let expectedError = NSError(domain: "testConditionErrorTest.error", code: 42, userInfo: nil)
        let expectedCondition = fixtureFailingCondition(error: expectedError)
        queue.conditions.append(expectedCondition)
        
        queue.ticked = { outcome in
            switch outcome {
            case .ConditionError(let err, let condition):
                guard let fixture = condition as? fixtureFailingCondition else {
                    print("unexpected \(condition) as condition")
                    return
                }
                let error = err as NSError
                if error != expectedError {
                    print("unexpected \(err), expecting \(expectedError)")
                    return
                }
                if fixture === expectedCondition {
                    expectation.fulfill()
                }
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testConsumerEmpty() {
        let expectation = expectationWithDescription("consumer is empty")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer(job: nil)
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .Empty:
                expectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testSynchronousUnanalyzedTaskFailure() {
        let expectation = expectationWithDescription("synchronous task failure")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTaskError = NSError(domain: "testSynchronousUnanalyzedTaskFailure.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let consumer = fixturePredefinedConsumer(job: fixturePredefinedJobTask(task: expectedTask))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .UnanalyzedTaskFailure(let error, let task):
                guard let fixtureTask = task as? fixtureFailingSynchronouslyTask else {
                    print("unexpected task \(task)")
                    return
                }
                if fixtureTask !== expectedTask {
                    print("unexpected task \(fixtureTask) is not \(expectedTask)")
                    return
                }
                let fixtureError = error as NSError
                if fixtureError != expectedTaskError {
                    print("unexpected error \(fixtureError) is not \(expectedTaskError)")
                    return
                }
                expectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
}
