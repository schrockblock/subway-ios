//
//  File.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/23/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import Foundation

struct Estimate: Codable {
    var stationId: String?
    var routeId: String?
    var directionId: Int?
    var time: String?
}

struct EstimatesResponse: Codable {
    var estimates: [Estimate]?
}

extension Estimate {
    func timeDate() -> Date {
        return DateFormatter.iso8601Full.date(from: time!)!.addingTimeInterval(TimeInterval(-TimeZone.current.secondsFromGMT()))
    }
    
    func timeSeconds() -> Int {
        return Int((timeDate().timeIntervalSince1970 - Current.timeProvider().timeIntervalSince1970) / 60)
    }
}
