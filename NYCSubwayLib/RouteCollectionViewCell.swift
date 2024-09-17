//
//  RouteCollectionViewCell.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/14/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var routeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        routeLabel.layer.cornerRadius = 25
        routeLabel.clipsToBounds = true
    }

}
