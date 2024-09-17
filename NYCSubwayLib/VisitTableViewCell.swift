//
//  VisitTableViewCell.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/30/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import UIKit

class VisitTableViewCell: UITableViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var routeImage: UIImageView!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackgroundColor(contentView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
