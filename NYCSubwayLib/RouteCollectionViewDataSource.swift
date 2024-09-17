//
//  RouteCollectionViewDataSource.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/14/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit
import SubwayStations

class RouteCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    var routeIds: [String]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeIds?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeCell", for: indexPath) as! RouteCollectionViewCell
        if let routeId = routeIds?[indexPath.row] {
            cell.routeLabel.text = routeId
            cell.routeLabel.backgroundColor = Current.colorManager.colorForRouteId(routeId)
        }
        return cell
    }
}
