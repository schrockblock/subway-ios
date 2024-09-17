//
//  StationSearchViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/25/19.
//  Copyright © 2019 Thryv. All rights reserved.
//

import UIKit
import SubwayStations
import FlexDataSource
import Prelude
import LithoOperators
import LUX
import fuikit
import Combine

let styleStationSearch: (StationSearchViewController) -> Void = union(^\.tableView >?> setupTableView, ^\.searchBar >?> setupBarColor)

func configureSearch(_ vc: StationSearchViewController) {
    if DatabaseLoader.isDatabaseReady {
        vc.stations = Current.stationManager.allStations
    }
    
    let searcher = LUXSearcher<Station>(^\Station.name, .noneMatchNilNoneMatchEmpty, .wordPrefixes)
    
    let stationsPub = searcher.filteredIncrementalPublisher(from: vc.$stations.skipNils().eraseToAnyPublisher())
    let viewModel = LUXModelListViewModel(modelsPublisher: stationsPub, modelToItem: configureCellLines >||> LUXModelItem.init)
    vc.viewModel = viewModel
    
    let showTable: () -> Void = { [weak vc] in vc?.tableView?.isHidden = false }
    vc.searchViewModel?.onIncrementalSearch = union(searcher.updateIncrementalSearch, ignoreArg(showTable))
    vc.searchViewModel?.searchBarDelegate.onSearchBarTextDidBeginEditing = { searchBar in
        searchBar.setShowsCancelButton(true, animated: true)
    }
    vc.searchViewModel?.searchBarDelegate.onSearchBarCancelButtonClicked = { [weak vc] _ in
        vc?.dismissKeyboardAndHideTable()
    }
}

public class StationSearchViewController: LUXSearchViewController<LUXModelListViewModel<Station>, Station>, UISearchBarDelegate {
    @Published var stations: [Station]?
    
    open func dismissKeyboardAndHideTable() {
        searchBar?.resignFirstResponder()
        clearSearchBar()
        searchBar?.setShowsCancelButton(false, animated: true)
        tableView?.isHidden = true
    }
}
