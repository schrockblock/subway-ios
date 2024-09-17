//
//  SubwayStationsExtensions.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/24/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import SubwayStations

extension Station {
    func stopIdsFilterString() -> String {
        return self.stops.map{ $0.objectId }.joined(separator: ",")
    }
}

extension Prediction {
    func deltaString() -> String? {
        if let arrivalTime = self.timeOfArrival {
            return "\((Int(arrivalTime.timeIntervalSince(Current.timeProvider()))) / 60)m"
        }
        return nil
    }
}
