//
//  DogTailTests.swift
//  DogTailTests
//
//  Created by Johan Hernandez on 5/21/16.
//  Copyright © 2016 Bithavoc. All rights reserved.
//

import XCTest
import DogTail

class DefaultQueueTests: XCTestCase {
    func testConditionAwait() {
        let expectation = expectationWithDescription("await by intented condition")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer()
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        let expectedCondition = fixturePredefinedCondition(checkResult: Check.Await)
        
        queue.install(fixtureConditionsPlugin(name: "test conditions plugin", conditions: [
            fixturePredefinedCondition(checkResult: Check.Continue),
            fixturePredefinedCondition(checkResult: Check.Continue),
            expectedCondition]))
        
        queue.ticked = { outcome in
            queue.ticked = nil
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(5) { err in
            
        }
    }
    
    func testConditionError() {
        let expectation = expectationWithDescription("error found on intended condition")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer()
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        let expectedError = NSError(domain: "testConditionErrorTest.error", code: 42, userInfo: nil)
        let expectedCondition = fixtureFailingCondition(error: expectedError)
        
        queue.install(fixtureConditionsPlugin(name: "test conditions plugin", conditions: [
            fixturePredefinedCondition(checkResult: Check.Continue),
            fixturePredefinedCondition(checkResult: Check.Continue),
            expectedCondition]))
        
        queue.ticked = { outcome in
            queue.ticked = nil
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testConsumerEmpty() {
        let expectation = expectationWithDescription("consumer is empty")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let consumer = fixturePredefinedConsumer()
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .Empty:
                expectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testSynchronousUnanalyzedTaskThrownFailure() {
        let expectation = expectationWithDescription("synchronous unanalyed task failure")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTaskError = NSError(domain: "testSynchronousUnanalyzedTaskFailure.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let consumer = fixturePredefinedConsumer(job: fixtureJob(task: expectedTask))
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
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
                consumer.clear()
                expectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testSynchronouslyAnalyzedTaskCompletion() {
        let expectation = expectationWithDescription("synchronous analyzed task result")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedAnalyzer = fixturePredefinedAnalyzer(name: "alwaysComplete", result: .Completed)
        queue.install(fixtureAnalyzersPlugin(name: "analyzer", analyzers: [expectedAnalyzer]))
        let expectedTaskError = NSError(domain: "testSynchronouslyAnalyzedTaskCompletion.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .AnalyzedTaskCompleted(let job, let analyzer):
                guard let fixtureJob = job as? fixtureJob else {
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 1)
    }
    
    func testSynchronouslyAnalyzedTaskUnkownAndRetry() {
        let expectation = expectationWithDescription("synchronous analyzed task unknown and retry")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        queue.install(fixtureAnalyzersPlugin(name: "analyzer always known", analyzers: [fixturePredefinedAnalyzer(name: "Always Unknown", result: .Unknown)]))
        let expectedRetryDate = NSDate().dateByAddingTimeInterval(100)
        let expectedAnalyzer = fixturePredefinedAnalyzer(name: "retryOnExpectedDate",result: .Retry(after:expectedRetryDate))
        queue.install(fixtureAnalyzersPlugin(name: "analyzer always known", analyzers: [expectedAnalyzer]))
        let expectedTaskError = NSError(domain: "testSynchronouslyAnalyzedTaskRetry.error", code: 42, userInfo: nil)
        let expectedTask = fixtureFailingSynchronouslyTask(error: expectedTaskError)
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .AnalyzedTaskRetry(let job, let analyzer, _):
                guard let fixtureJob = job as? fixtureJob else {
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
                consumer.clear()
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 0)
        XCTAssertEqual(expectedJob.retryCount, 1)
        XCTAssertEqual(expectedJob.after, expectedRetryDate)
    }
    
    func testSynchronouslyTaskCompletion() {
        let expectation = expectationWithDescription("synchronous task completion")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTask = fixtureSynchronouslyTask(execution: .Synchronous(.Completed))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .Completed(let job):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 1)
    }
    
    func testSynchronousTaskRetry() {
        let expectation = expectationWithDescription("synchronous task retry")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedRetryDate = NSDate().dateByAddingTimeInterval(100)
        let expectedTask = fixtureSynchronouslyTask(execution: .Synchronous(.Retry(after: expectedRetryDate)))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .Retry(let job, _):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 0)
        XCTAssertEqual(expectedJob.retryCount, 1)
        XCTAssertEqual(expectedJob.after, expectedRetryDate)
    }
    
    func testSynchronousTaskFailure() {
        let expectation = expectationWithDescription("synchronous task failure")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTaskError = NSError(domain: "testSynchronousTaskFailure.error", code: 42, userInfo: nil)
        let expectedTask = fixtureSynchronouslyTask(execution: .Synchronous(.Failed(error: expectedTaskError)))
        let consumer = fixturePredefinedConsumer(job: fixtureJob(task: expectedTask))
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .UnanalyzedTaskFailure(let error, let task):
                guard let fixtureTask = task as? fixtureSynchronouslyTask else {
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testAsynchronouslyAnalyzedTaskCompletion() {
        let expectation = expectationWithDescription("asynchronous analyzed task result")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedAnalyzer = fixturePredefinedAnalyzer(name: "always completed", result: .Completed)
        queue.install(fixtureAnalyzersPlugin(name: "analyzer", analyzers: [expectedAnalyzer]))
        let expectedTaskError = NSError(domain: "testAsynchronouslyAnalyzedTaskCompletion.error", code: 42, userInfo: nil)
        let expectedTask = fixtureSynchronouslyTask(execution: .Asynchronous({ done in
            done(.Failed(error: expectedTaskError))
        }))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            switch outcome {
            case .AnalyzedTaskCompleted(let job, let analyzer):
                guard let fixtureJob = job as? fixtureJob else {
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 1)
    }

    func testAsynchronouslyAnalyzedTaskUnkownAndRetry() {
        let expectation = expectationWithDescription("asynchronous analyzed task unknown and retry")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        queue.install(fixtureAnalyzersPlugin(name: "analyzer always unknown", analyzers: [fixturePredefinedAnalyzer(name: "always unknown", result: .Unknown)]))
        let expectedRetryDate = NSDate().dateByAddingTimeInterval(100)
        let expectedAnalyzer = fixturePredefinedAnalyzer(name: "always retry on expected date", result: .Retry(after:expectedRetryDate))
        queue.install(fixtureAnalyzersPlugin(name: "analyzer always unknown", analyzers: [expectedAnalyzer]))
        let expectedTaskError = NSError(domain: "testAsynchronouslyAnalyzedTaskRetry.error", code: 42, userInfo: nil)
        let expectedTask = fixtureSynchronouslyTask(execution: .Asynchronous({ done in
            done(.Failed(error: expectedTaskError))
        }))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .AnalyzedTaskRetry(let job, let analyzer, _):
                guard let fixtureJob = job as? fixtureJob else {
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 0)
        XCTAssertEqual(expectedJob.retryCount, 1)
        XCTAssertEqual(expectedJob.after, expectedRetryDate)
    }
    
    func testAsynchronouslyTaskCompletion() {
        let expectation = expectationWithDescription("asynchronous task completion")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTask = fixtureSynchronouslyTask(execution: .Asynchronous({ done in
            done(.Completed)
        }))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .Completed(let job):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 1)
    }
    
    func testAsynchronousTaskFailure() {
        let expectation = expectationWithDescription("asynchronous task failure")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedTaskError = NSError(domain: "testAsynchronousTaskFailure.error", code: 42, userInfo: nil)
        let expectedTask = fixtureSynchronouslyTask(execution: .Asynchronous({ done in
            done(.Failed(error: expectedTaskError))
        }))
        let consumer = fixturePredefinedConsumer(job: fixtureJob(task: expectedTask))
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .UnanalyzedTaskFailure(let error, let task):
                guard let fixtureTask = task as? fixtureSynchronouslyTask else {
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
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testAsynchronousTaskRetry() {
        let expectation = expectationWithDescription("synchronous task retry")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let expectedRetryDate = NSDate().dateByAddingTimeInterval(100)
        let expectedTask = fixtureSynchronouslyTask(execution: .Asynchronous({ done in
            done(.Retry(after: expectedRetryDate))
        }))
        let expectedJob = fixtureJob(task: expectedTask)
        let consumer = fixturePredefinedConsumer(job: expectedJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        
        let backgroundQueue = NSOperationQueue()
        
        queue.ticked = { outcome in
            consumer.clear()
            queue.ticked = nil
            switch outcome {
            case .Retry(let job, _):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob !== expectedJob {
                    print("unexpected job \(job)")
                    return
                }
                expectation.fulfill()
            case .Empty:
                print("expected test outcome \(outcome)")
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        XCTAssertEqual(expectedJob.consumeCount, 0)
        XCTAssertEqual(expectedJob.retryCount, 1)
        XCTAssertEqual(expectedJob.after, expectedRetryDate)
    }

    func testSignals() {
        let firstJobExpectation = expectationWithDescription("first job completed")
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let signal = SimpleSignal(name: "boom")
        queue.install(fixtureSignalsPlugin(name: "boom", signals: [signal]))
        
        let firstJob = fixtureJob(task: fixtureSynchronouslyTask(execution: Execution.Synchronous(.Completed)))
        
        let consumer = fixturePredefinedConsumer(job: firstJob)
        queue.install(fixtureConsumerPlugin(name: "consumer", consumer: consumer))
        queue.ticked = { outcome in
            queue.ticked = nil
            switch outcome {
            case .Completed(let job):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob != firstJob {
                    print("unexpected job instance \(job)")
                    return
                }
                consumer.clear()
                firstJobExpectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        let backgroundQueue = NSOperationQueue()
        
        queue.activate(backgroundQueue)
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
        
        backgroundQueue.waitUntilAllOperationsAreFinished()
        
        let secondJobExpectation = expectationWithDescription("second job completed (upon signal)")
        
        let secondJob = fixtureJob(task: fixtureSynchronouslyTask(execution: Execution.Synchronous(.Completed)))
        
        consumer.addJob(secondJob)
        
        queue.ticked = { outcome in
            queue.ticked = nil
            switch outcome {
            case .Completed(let job):
                guard let fixtureJob = job as? fixtureJob else {
                    print("unexpected job \(job)")
                    return
                }
                if fixtureJob != secondJob {
                    print("unexpected job instance \(job)")
                    return
                }
                secondJobExpectation.fulfill()
            default:
                print("unexpected test outcome \(outcome)")
            }
        }
        
        signal.emit()
        
        waitForExpectationsWithTimeout(10) { err in
            
        }
    }
    
    func testConditionProviderPlugin() {
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let condition = fixturePredefinedCondition(checkResult: Check.Await)
        let conditionsPlugin = fixtureConditionsPlugin(name: "testConditions", conditions: [condition])
        queue.install(conditionsPlugin)
        XCTAssertTrue(queue.conditions.filter{$0.name == condition.name}.count == 1)
    }
    
    func testSignalsProviderPlugin() {
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let signal = SimpleSignal(name: "bang!")
        let conditionsPlugin = fixtureSignalsPlugin(name: "testSignals", signals: [signal])
        queue.install(conditionsPlugin)
        XCTAssertTrue(queue.signals.filter{$0.name == signal.name}.count == 1)
    }
    
    func testAnalyzersProviderPlugin() {
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        let analyzer = fixturePredefinedAnalyzer(name: "analyzer", result: .Completed)
        let conditionsPlugin = fixtureAnalyzersPlugin(name: "testAnalyzers", analyzers: [analyzer])
        queue.install(conditionsPlugin)
        XCTAssertTrue(queue.analyzers.filter{$0.name == analyzer.name}.count == 1)
    }
    
    func testConsumerProviderPlugin() {
        let queue = DefaultQueue()
        defer {
            queue.shutdown()
        }
        
        let consumer = fixturePredefinedConsumer()
        let conditionsPlugin = fixtureConsumerPlugin(name: "testConsumer", consumer: consumer)
        queue.install(conditionsPlugin)
        XCTAssertTrue(queue.consumer is fixturePredefinedConsumer)
    }
}
