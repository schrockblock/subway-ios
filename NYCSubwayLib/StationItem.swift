//
//  StationItem.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/25/19.
//  Copyright © 2019 Thryv. All rights reserved.
//

import SubwayStations
import FlexDataSource
import LUX

func configureCellLines(_ station: Station, _ cell: StationTableViewCell){
    cell.stationNameLabel?.text = station.name
    for imageView in cell.orderedLineImageViews! {
        imageView.image = nil
    }
    if let shouldShowLines = Bundle.main.infoDictionary!["ShowLines"] as? Bool {
        if shouldShowLines {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                if let lines = Current.stationManager.linesForStation(station) {
                    DispatchQueue.main.async {
                        if cell.stationNameLabel.text != station.name {
                            return
                        }
                        cell.firstLineImageView.image = nil
                        cell.secondLineImageView.image = nil
                        cell.thirdLineImageView.image = nil
                        cell.fourthLineImageView.image = nil
                        for line in lines {
                            let image = UIImage(named: "Grey")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate);
                            if cell.firstLineImageView.image == nil {
                                cell.firstLineImageView.image = image
                                cell.firstLineImageView.tintColor = line.color
                            } else if cell.secondLineImageView.image == nil {
                                cell.secondLineImageView.image = image
                                cell.secondLineImageView.tintColor = line.color
                            } else if cell.thirdLineImageView.image == nil {
                                cell.thirdLineImageView.image = image
                                cell.thirdLineImageView.tintColor = line.color
                            } else if cell.fourthLineImageView.image == nil {
                                cell.fourthLineImageView.image = image
                                cell.fourthLineImageView.tintColor = line.color
                            }
                        }
                    };
                }
            };
        }
    }
}
