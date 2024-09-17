//
//  StationTableViewCell.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 10/29/15.
//  Copyright © 2015 Thryv. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var firstLineImageView: UIImageView!
    @IBOutlet weak var secondLineImageView: UIImageView!
    @IBOutlet weak var thirdLineImageView: UIImageView!
    @IBOutlet weak var fourthLineImageView: UIImageView!
    var orderedLineImageViews: [UIImageView]?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackgroundColor(contentView)
        orderedLineImageViews = [firstLineImageView, secondLineImageView, thirdLineImageView, fourthLineImageView]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
