//
//  PredictionViewModelTests.swift
//  NYCSubwayLibTests
//
//  Created by Elliot Schrock on 4/24/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import XCTest
@testable import NYCSubwayLib
import SubwayStations

class PredictionViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        Current = testing
        DatabaseLoader.loadDb()
        let expectation = XCTNSNotificationExpectation(name: Notification.Name(rawValue: DatabaseLoader.NYCDatabaseLoadedNotification))
        let _ = XCTWaiter().wait(for: [expectation], timeout: 5)
    }

    func testPredictionsOnly() throws {
        let prediction = Prediction(time: Current.timeProvider())
        prediction.direction = .uptown
        prediction.route = Current.stationManager.routes.filter { $0.objectId == "A" }.first
        
        let predictions = [prediction]
        let visits = [Visit]()
        let estimates = [Estimate]()
        let predVMs = models(from: predictions, visits: visits, estimates: estimates)
        
        XCTAssertEqual(predVMs.count, 1)
    }
}
