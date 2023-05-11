//
//  TrimarkTests.swift
//  TrimarkTests
//
//  Created by Carlos Martins on 11/05/2023.
//

import XCTest
@testable import Trimark

final class HomeViewModelTests: XCTestCase {
    
    var sut: Home.ViewModel!
    var delegate: HomeViewModelDelegateMock!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        delegate = HomeViewModelDelegateMock()
        sut = Home.ViewModel()
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        sut = nil
        delegate = nil
        
        try super.tearDownWithError()
    }

    func test_UpdateProgressIsCalled_GivenTimeAttributes_WhenDurationExists() throws {
        let expectedProgressUpdateCall = expectation(description: "update progress should be called")
        
        let expectedPauseCallNotCalled = expectation(description: "pause should not be called")
        expectedPauseCallNotCalled.isInverted = true
        
        delegate.updateProgressCalled = { progress in
            expectedProgressUpdateCall.fulfill()
            
            XCTAssertEqual(progress, 0.5)
        }
        
        // Trigger a current time update at second 1, with a duration of 2 seconds.
        sut.videoDidUpdateCurrentTime(time: 1, duration: 2, limitedDuration: 2)
        
        wait(for: [expectedProgressUpdateCall, expectedPauseCallNotCalled], timeout: 0.1)
    }

    func test_UpdateProgressIsCalled_GivenTimeAttributesThatTriggerPause_WhenDurationExists() throws {
        let expectedProgressUpdateCall = expectation(description: "update progress should be called")
        let expectedPauseCall = expectation(description: "pause should be called")
        let expectedRestartCall = expectation(description: "restart should be called")
        
        delegate.updateProgressCalled = { progress in
            expectedProgressUpdateCall.fulfill()
        }
        
        delegate.pausedCalled = {
            expectedPauseCall.fulfill()
        }
        
        delegate.restartCalled = {
            expectedRestartCall.fulfill()
        }
        
        // Trigger a current time update at second 1, with a duration of 2 seconds.
        sut.videoDidUpdateCurrentTime(time: 1, duration: 2, limitedDuration: 1)
        
        // Wait for the expectations to be fulfilled in order.
        wait(for: [expectedProgressUpdateCall, expectedPauseCall, expectedRestartCall], timeout: 0.1, enforceOrder: true)
    }
}
