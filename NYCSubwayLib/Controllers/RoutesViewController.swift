//
//  RoutesViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/21/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit
import SubwayStations
import GTFSStations
import PlaygroundVCHelpers
import fuikit
import LithoOperators
import Prelude
import LUX
import FlexDataSource

func routesVC(_ station: Station?) -> RoutesViewController {
    let routesVC = RoutesViewController.makeFromXIB()
    configureSearch(routesVC)
    let setStation: (RoutesViewController) -> Void = { routesVC in routesVC.fromStation = station }
    routesVC.onViewDidLoad = union(setupVCBG, set(\UIViewController.title, "Navigate to"), ~>(routesViewLoaded <> setStation <> setupSearchBars <> setupRoutesTable))
    routesVC.onGoToRoute = routeViewController >>> routesVC.emptyBackClosure()
    routesVC.fromStation = station
    return routesVC
}

let routesViewLoaded: (RoutesViewController) -> Void = ^\.tableView >?> setupTableView
    <> ^\.fromSearchBar >?> setupBarColor
    <> ^\.toSearchBar >?> setupBarColor
    <> ^\.goButton >?> setupCircleCappedView
    <> ^\.spinner >?> set(\UIView.alpha, 0)
func setupSearchBars(_ routesVC: RoutesViewController) {
    routesVC.handleStationChoice = ifThen(routesVC.isFrom, routesVC.setFromStation) <> ifThen(routesVC.isTo, routesVC.setToStation)
    routesVC.fromSearchBar.text = routesVC.fromStation?.name
    
    let delegate = routesVC.searchViewModel?.searchBarDelegate
    routesVC.fromSearchBar.delegate = delegate
    routesVC.toSearchBar.delegate = delegate
    
    delegate?.onSearchBarTextDidBeginEditing = { [weak routesVC] searchBar in
        routesVC?.searchBar?.setShowsCancelButton(true, animated: true)
        routesVC?.searchBar = searchBar
        routesVC?.tableView?.isHidden = false
    }
    delegate?.onSearchBarCancelButtonClicked = ignoreArg(union(routesVC.dismissKeyboardAndHideTable, nil *> routesVC.handleStationChoice))
}

func setupRoutesTable(_ routesVC: RoutesViewController) {
    routesVC.tableViewDelegate = FUITableViewDelegate()
    routesVC.tableViewDelegate?.onSelect = union(deselectRow, ignoreFirstArg(f: ^\IndexPath.row >>> routesVC.station(for:) >?> routesVC.handleStationChoice))
    routesVC.tableView?.delegate = routesVC.tableViewDelegate
}

class RoutesViewController: StationSearchViewController, UITableViewDelegate {
    @IBOutlet weak var fromSearchBar: UISearchBar!
    @IBOutlet weak var toSearchBar: UISearchBar!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var goButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var handleStationChoice: (Station?) -> Void = { _ in }
    var onGoToRoute: (([Station], [Trip]) -> Void)?
    var fromStation: Station? { didSet {
            fromSearchBar?.text = fromStation?.name
            toSearchBar?.becomeFirstResponder()
            searchBar = toSearchBar
        }
    }
    var toStation: Station? { didSet {
            toSearchBar.text = toStation?.name
            toSearchBar?.resignFirstResponder()
            tableView?.isHidden = true
        }
    }
    
    func isFrom() -> Bool { return searchBar == fromSearchBar }
    func isTo() -> Bool { return searchBar == toSearchBar }
    func station(for index: Int) -> Station? { return (viewModel?.flexDataSource.sections?[0].items as? [LUXModelItem<Station, StationTableViewCell>])?[index].model }
    func setFromStation(_ station: Station?) { fromStation = station }
    func setToStation(_ station: Station?) { toStation = station }
    
    // MARK: - IBActions
    
    @IBAction func goPressed() {
        let nav: NYCNavigator = NYCNavigator()
        nav.transferStations = (Current.stationManager as! NYCStationManager).transferStations
        
        goButtonWidthConstraint.constant = goButton.bounds.height
        UIView.animate(withDuration: 0.5) {
            self.spinner.alpha = 1
            self.goButton.setTitle("", for: .normal)
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }
        DispatchQueue.global(qos: .default).async(execute: {
            if let first = self.fromStation, let second = self.toStation {
                let (stations, trips) = nav.getStationsAndTripsBetween(first, second, nil)
                DispatchQueue.main.async {
                    self.goButtonWidthConstraint.constant = 63
                    UIView.animate(withDuration: 0.5) {
                        self.spinner.alpha = 0
                        self.goButton.setTitle("Go!", for: .normal)
                        self.view.updateConstraints()
                        self.view.layoutIfNeeded()
                    }
                    self.onGoToRoute?(stations, trips)
                }
            }
        })
    }
}

public func ifThen<T>(_ condition: @escaping () -> Bool, _ f: @escaping (T) -> Void, else g: (() -> Void)? = nil) -> (T) -> Void {
    return { t in
        if condition() {
            return f(t)
        } else {
            g?()
        }
    }
}
