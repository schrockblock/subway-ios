//
//  WifiAutologin.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/11/21.
//  Copyright © 2021 Thryv. All rights reserved.
//

import Foundation
import Network
import UserNotifications
import LUX
import Prelude
import fuikit
import CoreLocation
import LithoOperators
import SubwayStations

let maxAccuracy: Double = 10000
let maxDistanceToStation: Double = 100
let degreesToMeters: Double = 111000

public class WifiTracker {
    var wifiLocationManager = CLLocationManager()
    var wifiLocationDelegate = FCLLocationManagerDelegate()
    
    let wifiMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
    var lastStation: Station?
    var lastStationTime: Date?
    
    public func trackWifi() {
        wifiLocationDelegate.onDidUpdateLocations = ignoreFirstArg(f: ^\[CLLocation].last >?> fzip(closestStationToLoc, id) >?> ~(wifiMonitor >|||> report(station:for:_:)))
        wifiLocationManager.delegate = wifiLocationDelegate
        wifiLocationManager.requestAlwaysAuthorization()
        wifiLocationManager.startUpdatingLocation()
    }
    
    func report(station: Station?, for location: CLLocation, _ monitor: NWPathMonitor) {
        if let station = station {
            let coord = (location.coordinate.latitude, location.coordinate.longitude)
            let distanceToStationInMeters = station.distance(to: coord, euclideanDistance) * degreesToMeters
            if location.horizontalAccuracy < maxAccuracy && location.timestamp > 2.minutes.ago {
                if lastStation?.name != station.name {
                    lastStation = station
                    lastStationTime = Date()
                    if distanceToStationInMeters < maxDistanceToStation {
                        sendNearbyNotification(station.name)
                        start(monitor: monitor, station.name)
                    }
                }
            }
            if let date = lastStationTime, date < 30.minutes.ago {
                wifiLocationManager.stopUpdatingLocation()
            }
        }
    }
}

func start(monitor: NWPathMonitor, _ stationName: String) {
    if monitor.pathUpdateHandler == nil {
        let queue = DispatchQueue(label: "Monitor")
        monitor.pathUpdateHandler = handlePath
        monitor.start(queue: queue)
        print("started")
    }
}

let isConnected = ^\NWPath.status >>> (NWPath.Status.satisfied >||> (==))
let handlePath: (NWPath) -> Void = fetchNetwork |> (isConnected >|> ({} >|||> ifThen))
