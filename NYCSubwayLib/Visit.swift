//
//  Visit.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/17/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

public class Visit: Codable {
    var id: Int?
    var stationId: String?
    var routeId: String?
    var directionId: Int? = 2
    var latitude: Double?
    var longitude: Double?
    var isAuto: Bool? = false
    var platform: String? = "ios"
    var time: String? = DateFormatter.iso8601Seconds.string(from: Current.timeProvider().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT())))
    var identifier: String? = Current.uuidProvider()
    var stopsAway: Int64? = -1
}

extension Visit {
    func timeAgoDate() -> Date {
        return DateFormatter.iso8601Full.date(from: time!)!.addingTimeInterval(TimeInterval(-TimeZone.current.secondsFromGMT()))
    }
    
    func timeAgoSeconds() -> Int {
        return Int((Current.timeProvider().timeIntervalSince1970 - timeAgoDate().timeIntervalSince1970) / 60)
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    static let iso8601Seconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
