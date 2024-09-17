//
//  ChooseDirectionViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/14/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import LUX
import FunNet
import SubwayStations
import Combine

class ChooseDirectionViewController: UIViewController {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightLabel: UILabel!
    var callingViewController: UIViewController?
    var station: Station!
    var routeId: String!
    var reportCall: CombineNetCall?
    private var cancelBag = Set<AnyCancellable?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundColor(view)
        
        setupChoice(imageView: leftImageView, label: leftLabel, directionId: 0)
        setupChoice(imageView: rightImageView, label: rightLabel, directionId: 1)
    }
    
    func setupChoice(imageView: UIImageView, label: UILabel, directionId: Int) {
        label.text = Current.directionProvider.directionName(for: directionId, routeId: routeId)
        let directionEnum = Current.directionProvider.directionEnum(for: directionId, routeId: routeId)
        imageView.image = image(for: directionEnum)
    }
    
    @IBAction func leftButtonPressed() {
        reportVisit(with: 0)
    }
    
    @IBAction func rightButtonPressed() {
        reportVisit(with: 1)
    }
    
    func reportVisit(with direction: Int) {
        let visit = Visit()
        visit.directionId = direction
        visit.routeId = routeId
        visit.stationId = station.stops.first?.objectId
        reportCall = reportVisitCall(visit: visit)
        cancelBag.insert(reportCall?.responder?.$httpResponse.sink { _ in
            self.thankYou()
        })
        reportCall?.fire()
    }
    
    func thankYou() {
        let trainReports = UserDefaults.standard.integer(forKey: "trains") + 1
        UserDefaults.standard.set(trainReports, forKey: "trains")
        
        let trainPlural = trainReports == 1 ? "train" : "trains"
        let alert = UIAlertController(title: "Thank you!", message: "You've reported \(trainReports) \(trainPlural).", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hooray!", style: .default, handler: { _ in self.pop() }))
        self.present(alert, animated: true)
    }
    
    func pop() {
        if let vc = self.callingViewController {
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
}
