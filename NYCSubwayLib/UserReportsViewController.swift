//
//  UserReportsViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/29/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import FunNet
import LithoOperators
import Prelude
import Combine
import SubwayStations
import FlexDataSource
import fuikit
import Slippers
import SwiftDate

class UserReportsViewController: LUXFlexViewController<UserReportsViewModel<Visit>> {
    @IBOutlet weak var userLabel: UILabel?
    @IBOutlet weak var autoLabel: UILabel?
    @IBOutlet weak var userSwitch: UISwitch?
    @IBOutlet weak var autoSwitch: UISwitch?
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint?
    
    var onFilter: ((Bool, Bool) -> Void)?
    var deleteCall: CombineNetCall?
    private var cancelBag = Set<AnyCancellable?>()
    
    var stationManager: StationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundColor(view)
        tableView ?> setupBackgroundColor

        title = "Reports"
        
        if Current.isAdmin {
            tableTopConstraint?.constant = 54
        } else {
            tableTopConstraint?.constant = 0
            userSwitch?.isHidden = true
            autoSwitch?.isHidden = true
            userLabel?.isHidden = true
            autoLabel?.isHidden = true
        }
    }
    
    @IBAction func filterByUser() {
        if let byUser = userSwitch?.isOn, let auto = autoSwitch?.isOn {
            onFilter?(byUser, auto)
        }
    }
    
    @IBAction func filterAuto() {
        if let byUser = userSwitch?.isOn, let auto = autoSwitch?.isOn {
            onFilter?(byUser, auto)
        }
    }
    
    func swiped(visit: inout Visit) {
        if let id = visit.id {
            let call = deleteVisitCall(id: "\(id)")
            cancelBag.insert(call.responder?.$data.sink { _ in
                self.deleteCall = nil
                self.refresh()
            })
            deleteCall = call
            call.fire()
        }
    }
}

func userReportsVC() -> UserReportsViewController {
    let vc = UserReportsViewController.makeFromXIB()
    vc.configure()
    vc.onViewDidLoad = { _ in
        vc.onFilter = vc.configure >>> vc.refresh
    }
    return vc
}

extension UserReportsViewController {
    func configure(thisUserOnly: Bool = true, allowAuto: Bool = false) {
        let call = getUserVisitsCall(userId: (thisUserOnly ? Current.uuidProvider() : nil))
        call.endpoint.getParams.updateValue("mta_v1", forKey: "not_identifier")
        call.endpoint.getParams.updateValue(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 1.months), forKey: "after")
        if allowAuto {
            call.endpoint.getParams.removeValue(forKey: "is_auto")
        } else {
            call.endpoint.getParams.updateValue(false, forKey: "is_auto")
        }
        call.endpoint.getParams.updateValue(25, forKey: "per")
        call.endpoint.getParams.updateValue(0, forKey: "page")
        
        let visitsPub = unwrappedModelPublisher(from: call.responder!.$data.eraseToAnyPublisher(), ^\VisitsResponse.visits)
        
        let manager = LUXPageCallModelsManager(firstPageValue: 0, call, visitsPub)
        refreshableModelManager = LUXRefreshableNetworkCallManager(call)
        
        let pagedVisitsPub: AnyPublisher<[Visit], Never> = manager.$models.map { visits in
            if thisUserOnly { visits.forEach(set(\Visit.identifier, nil)) }
            return visits
        }.eraseToAnyPublisher()
        
        let vm = UserReportsViewModel<Visit>(modelsPublisher: pagedVisitsPub,
                                             modelToItem: visitItemFactory(swiped(visit:)),
                                             EmptyItem(identifier: "empty"))
        viewModel = vm

        let delegate = FUITableViewDelegate(onSelect: vm.flexDataSource.tappableOnSelect, onWillDisplay: manager.willDisplayFunction(pageSize: 25))
        self.tableViewDelegate = delegate
    }
}

class EmptyItem: ConcreteFlexDataSourceItem<EmptyReportsTableViewCell> {
    override func configureCell(_ cell: UITableViewCell) {
        cell.backgroundColor = .background()
    }
}

open class UserReportsViewModel<T>: LUXModelTableViewModel<T>, LUXDataSourceProvider {
    public var flexDataSource: FlexDataSource
    
    public init(modelsPublisher: AnyPublisher<[T], Never>, modelToItem: @escaping (T) -> FlexDataSourceItem, _ emptyItem: FlexDataSourceItem) {
        flexDataSource = FlexDataSource()
        super.init(modelsPublisher: modelsPublisher, modelToItem: modelToItem)
        
        cancelBag.insert(self.sectionsPublisher.sink {
            if $0.first?.items?.isEmpty != true {
                self.flexDataSource.sections = $0
                self.flexDataSource.tableView?.separatorStyle = .singleLine
            } else {
                self.flexDataSource.sections = emptyItem |> (arrayOfSingleObject >>> itemsToSection >>> arrayOfSingleObject)
                self.flexDataSource.tableView?.separatorStyle = .none
            }
            self.flexDataSource.tableView?.reloadData()
        })
    }
}

func visitItemFactory(_ onSwipe: @escaping (inout Visit) -> Void) -> (Visit) -> FlexDataSourceItem {
    return { visit in
        VisitItem(visit) {
            var v = visit
            onSwipe(&v)
        }
    }
}

extension String {
    func addedUp() -> Int {
        var sum = 0
        for val in Array(self) {
            let char = Character(String(val))
            sum += char.unicodeScalars.first.hashValue % 255
        }
        return sum
    }
}
