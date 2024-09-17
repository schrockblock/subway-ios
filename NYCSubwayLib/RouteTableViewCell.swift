//
//  RouteTableViewCell.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/24/19.
//  Copyright © 2019 Thryv. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var routeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackgroundColor(contentView)
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        circleView.clipsToBounds = true
    }
    
}
