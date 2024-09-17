//
//  TimeProvider.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/21/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import Foundation

public func currentTime() -> Date {
    return Calendar.current.date(byAdding: .minute, value: 0, to: Date())!
}

public func mockTime() -> Date {
    return DateFormatter.iso8601Full.date(from: "2020-04-21T08:21:00.000Z")!
}

extension Date {
    func adjustForTimeZone() -> Date {
        return self.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    }
}
