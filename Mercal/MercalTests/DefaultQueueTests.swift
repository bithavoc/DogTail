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
        let consumer = fixturePredefinedConsumer<fixturePredefinedJobTask>(job: nil)
        
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
        let consumer = fixturePredefinedConsumer<fixturePredefinedJobTask>(job: nil)
        
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
        let consumer = fixturePredefinedConsumer<fixturePredefinedJobTask>(job: nil)
        
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
    
    func testSynchronouslyAnalyzedTaskCompletion() {
        let expectation = expectationWithDescription("synchronous task result")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedAnalyzer = fixturePredefinedAnalyzer(result: .Completed)
        queue.analyzers.append(expectedAnalyzer)
        let expectedTaskError = NSError(domain: "testSynchronouslyAnalyzedTaskCompletion.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let expectedJob = fixturePredefinedJobTask(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .AnalyzedTaskCompleted(let job, let analyzer):
                guard let fixtureJob = job as? fixturePredefinedJobTask else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                guard let fixtureAnalyzer = analyzer as? fixturePredefinedAnalyzer else {
                    print("unexpected analyzer \(analyzer)")
                    return
                }
                if fixtureAnalyzer !== expectedAnalyzer {
                    print("unexpected analyzer \(fixtureAnalyzer)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 1)
    }
    
    func testSynchronouslyAnalyzedTaskUnkownAndRetry() {
        let expectation = expectationWithDescription("synchronous task result")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        queue.analyzers.append(fixturePredefinedAnalyzer(result: .Unknown))
        
        let expectedRetryDate = NSDate().dateByAddingTimeInterval(100)
        let expectedAnalyzer = fixturePredefinedAnalyzer(result: .Retry(after:expectedRetryDate))
        queue.analyzers.append(expectedAnalyzer)
        let expectedTaskError = NSError(domain: "testSynchronouslyAnalyzedTaskRetry.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let expectedJob = fixturePredefinedJobTask(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .AnalyzedTaskRetry(let job, let analyzer, _):
                guard let fixtureJob = job as? fixturePredefinedJobTask else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                guard let fixtureAnalyzer = analyzer as? fixturePredefinedAnalyzer else {
                    print("unexpected analyzer \(analyzer)")
                    return
                }
                if fixtureAnalyzer !== expectedAnalyzer {
                    print("unexpected analyzer \(fixtureAnalyzer)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(consumer, dispatcher: backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 0)
        XCTAssertEqual(expectedJob.retryCount, 1)
        XCTAssertEqual(expectedJob.lastRetryDate, expectedRetryDate)
    }
}
