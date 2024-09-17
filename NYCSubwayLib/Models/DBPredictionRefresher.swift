//
//  DBPredictionRefresher.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/23/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import Combine
import SubwayStations
import Slippers

class DBPredictionRefresher: Refreshable {
    @Published var predictions: [Prediction]?
    let station: Station
    
    init(_ station: Station) {
        self.station = station
    }
    
    func refresh() {
        predictions = Current.stationManager.predictions(station, time: Current.timeProvider())
    }
}
