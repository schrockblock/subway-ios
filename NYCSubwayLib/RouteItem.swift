//
//  RouteItem.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/25/19.
//  Copyright © 2019 Thryv. All rights reserved.
//

import SubwayStations
import FlexDataSource
import Prelude
import LithoOperators

enum ItemPosition {
    case first
    case middle
    case last
}

class RouteItem: ConcreteFlexDataSourceItem<RouteTableViewCell> {
    var station: Station
    var route: Route
    var position: ItemPosition
    var isTransfer = false
    
    init(identifier: String = "routeCell", station: Station, route: Route, position: ItemPosition = .middle) {
        self.station = station
        self.route = route
        self.position = position
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let cell = cell as? RouteTableViewCell {
            configureCell(cell)
        }
    }
    
    func configureCell(_ cell: RouteTableViewCell) {
        cell |> (configureStation <> configureLines <> configureCircle <> configureRoute <> configureColors)
    }
}

extension RouteItem {
    func isFirst() -> Bool {
        return position == .first
    }
    
    func isLast() -> Bool {
        return position == .last
    }
}

extension RouteItem {
    func configureStation(_ cell: RouteTableViewCell) {
        cell.stationLabel.text = isTransfer ? "Transfer @ \(station.name ?? "")" : station.name
    }
    
    func configureCircle(_ cell: RouteTableViewCell) {
        if !(isFirst() || isLast() || isTransfer) {
            cell.circleView.isHidden = true
        } else {
            cell.circleView.isHidden = false
        }
    }
    
    func configureRoute(_ cell: RouteTableViewCell) {
        if isFirst() || isTransfer {
            cell.routeLabel.text = route.objectId
            cell.routeLabel.isHidden = false
        } else {
            cell.routeLabel.isHidden = true
        }
    }
    
    func configureLines(_ cell: RouteTableViewCell) {
        cell.topLineView.isHidden = isFirst()
        cell.bottomLineView.isHidden = isLast()
    }
    
    func configureColors(_ cell: RouteTableViewCell) {
        cell.topLineView.backgroundColor = Current.colorManager.colorForRouteId(route.objectId)
        cell.bottomLineView.backgroundColor = Current.colorManager.colorForRouteId(route.objectId)
        cell.circleView.backgroundColor = Current.colorManager.colorForRouteId(route.objectId)
    }
}
