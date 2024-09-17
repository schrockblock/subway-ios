//
//  VisitItem.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/30/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import FlexDataSource
import SubwayStations
import LithoOperators
import LUX

class VisitItem: SwipableItem<VisitTableViewCell> {
    let visit: Visit
    
    init(_ visit: Visit, _ onSwipe: @escaping () -> Void) {
        self.visit = visit
        super.init(identifier: "visitCell", visit >|> configureVisitCell(_:_:), {}, onSwipe)
    }
}

func configureVisitCell(_ visit: Visit, _ cell: UITableViewCell) {
    if let cell = cell as? VisitTableViewCell {
        configureVisit(visit, cell)
    }
}

func configureVisit(_ visit: Visit, _ cell: VisitTableViewCell) {
    if false == visit.isAuto {
        configureManual(visit, cell)
    } else {
        configureAuto(visit, cell)
    }
}

func configureAuto(_ visit: Visit, _ cell: VisitTableViewCell) {}

func configureManual(_ visit: Visit, _ cell: VisitTableViewCell) {
    cell.routeLabel.layer.cornerRadius = 18
    cell.routeLabel.clipsToBounds = true
    if let routeId = visit.routeId {
        cell.routeLabel.text = routeId
        cell.routeLabel.backgroundColor = Current.colorManager.colorForRouteId(routeId)
        if let direction = visit.directionId {
            let directionEnum = Current.directionProvider.directionEnum(for: direction, routeId: routeId)
            cell.routeImage.image = image(for: directionEnum)
        }
    }
    if let stationId = visit.stationId {
        let stationName = Current.stationManager.allStations.first { $0.stops.filter { $0.objectId == stationId }.count > 0 }?.name
        cell.stationLabel.text = stationName
    }
    cell.timeLabel.text = visit.time
    if let timeString = visit.time, let initDate = DateFormatter.iso8601Seconds.date(from: timeString) {
        let date = initDate.addingTimeInterval(TimeInterval(-TimeZone.current.secondsFromGMT()))
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d @ h:mm a"
        cell.timeLabel.text = formatter.string(from: date)
    }
    if let identifier = visit.identifier {
        var index = identifier.addedUp()
        if index < 0 { index = -index }
        index = index % allEmojis.count
        cell.emojiLabel.text = allEmojis[index]
    }
}
