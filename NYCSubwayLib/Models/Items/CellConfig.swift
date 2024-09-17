//
//  CellConfig.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/24/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import SubwayStations

func configurePredictionCell(_ model: PredictionViewModel, _ cell: PredictionTableViewCell) {
    if let prediction = model.prediction {
        cell.deltaLabel.text = prediction.deltaString()
        if let route = prediction.route {
            cell.routeLabel.text = route.objectId
            cell.routeLabel.backgroundColor = Current.colorManager.colorForRouteId(route.objectId)
            cell.timeLabel.text = Current.directionProvider.directionName(for: prediction.direction!.rawValue, routeId: route.objectId)
            cell.routeImage.image = image(for: Current.directionProvider.directionEnum(for: prediction.direction!.rawValue, routeId: route.objectId))
        }
        cell.visitImageView.isHidden = true
        cell.visitLabel.isHidden = true
        if let visits = model.visits, visits.filter({ ($0.stopsAway ?? -1) > 0 }).count > 0 {
            let image = UIImage(named: "baseline_remove_red_eye_black_48")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.visitImageView.image = image
            cell.visitImageView.tintColor = UIColor.accent()
            if let visit = visits.filter({ ($0.stopsAway ?? -1) > 0 && $0.timeAgoSeconds() > 0 }).first {
                cell.visitImageView.isHidden = false
                cell.visitLabel.isHidden = false
                let stopString = visit.stopsAway == 1 ? "stop" : "stops"
                let timeAgo: Int = visit.timeAgoSeconds()
                cell.visitLabel.text = "\(visit.stopsAway!) \(stopString) away as of \(timeAgo)m ago"
            }
        }
    }
    
    cell.contentView.updateConstraints();
}

func configureEstimateCell(_ model: PredictionViewModel, _ cell: EstimateTableViewCell) {
    configurePredictionCell(model, cell)
    if let estimates = model.estimates, let estimate = estimates.filter({ $0.timeSeconds() > -1 }).first {
        cell.deltaPrimeLabel.text = "\(estimate.timeSeconds())m"
    }
}
