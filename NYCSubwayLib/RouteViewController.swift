//
//  RouteViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/21/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit
import FlexDataSource
import SubwayStations
import GTFSStations
import fuikit
import LithoOperators
import Prelude

func routeViewController(_ stations: [Station], _ trips: [Trip]) -> RouteViewController {
    let routeVC = RouteViewController.makeFromXIB()
    routeVC.stations = stations
    routeVC.trips = trips
    routeVC.onViewDidLoad = ~>(^\RouteViewController.tableView >?> setupBackgroundColor <> ^\RouteViewController.view >?> setupBackgroundColor)
    return routeVC
}

class RouteViewController: FUITableViewViewController {
    let dataSource = FlexDataSource()
    var stations: [Station]!
    var trips: [Trip]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let routeIds = trips.map { $0.routeId }
        
        if let routeId = routeIds.first as? String, let route = Current.stationManager.routeForRouteId(routeId) {
            let items = stations.map { RouteItem(station: $0, route: route) }
            items.first?.position = .first
            items.last?.position = .last
            
            var routeIdIndex = 0
            for i in 1..<items.count {
                let item = items[i]
                let previous = items[i-1]
                if item.station.stops.map({ $0.objectId! }).sorted() == previous.station.stops.map({ $0.objectId! }).sorted() {
                    routeIdIndex += 1
                    item.isTransfer = true
                }
                if let routeId = routeIds[routeIdIndex], let route = Current.stationManager.routeForRouteId(routeId) {
                    item.route = route
                }
            }
            
            let section = FlexDataSourceSection()
            section.items = items
            dataSource.sections = [section]
        }
        
        dataSource.tableView = tableView
        tableView?.dataSource = dataSource
    }
}

extension StationManager {
    func routeForRouteId(_ routeId: String) -> Route? {
        return routes.filter { $0.objectId == routeId }.first
    }
}
