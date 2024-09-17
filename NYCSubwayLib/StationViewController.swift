//
//  StationViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 7/27/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import LUX
import FunNet
import LithoOperators
import Prelude
import fuikit
import Slippers
import FlexDataSource
import SubwayStations
import GTFSStations
import CoreGraphics
import Combine
import PlaygroundVCHelpers
import SwiftDate

func stationVC(for station: Station) -> StationViewController {
    let vc = StationViewController.makeFromXIB()
    let setStationName = set(\UIViewController.title, station.name)
    let setupStationVC: (StationViewController) -> Void = union(^\.tableView >>> setupTableView,
                                                                ^\.actionButtonBottomConstraint >>> setupActionButtonPosition,
                                                                ^\StationViewController.actionButton >?> setupCircleCappedView,
                                                                station >||> configure(_:with:),
                                                                station >||> setupBarButtons,
                                                                initializeStationVC)
    vc.onViewDidLoad = union(setStationName, ~>setupStationVC, setupEdges, set(\UIViewController.view.backgroundColor, .primaryDark()))
    vc.onOpenRoutes = { $0.pushAnimated(routesVC(station)) }
    vc.onActionPressed = { $0.pushAnimated(chooseVC($0, station)) }
    vc.onToggleFavoriteStation = station >||> toggleFavStation
    return vc
}

let initializeStationVC = { (stationVC: StationViewController) in
    stationVC.startLoading()
    stationVC.hideLineViews()
}

func setupBarButtons(_ stationVC: StationViewController, _ station: Station) {
    stationVC.navigationItem.rightBarButtonItems = [favoriteButton(stationVC, station), navButton(stationVC, station)]
}

func favoriteButton(_ stationVC: StationViewController, _ station: Station) -> UIBarButtonItem {
    let imageName = Current.favManager.isFavorite(station.name) ? "star_white_24pt" : "star_border_white_24pt"
    return stationVC.barButtonItem(for: imageName, selector: #selector(StationViewController.toggleFavoriteStation))
}

func navButton(_ stationVC: StationViewController, _ station: Station) -> UIBarButtonItem {
    return stationVC.barButtonItem(for: "navigation_white_24pt", selector: #selector(StationViewController.openRoutes))
}

func toggleFavStation(_ stationVC: StationViewController, _ station: Station) {
    Current.favManager.isFavorite(station.name) ? Current.favManager.removeFavorites([station]) : Current.favManager.addFavorites([station])
    setupBarButtons(stationVC, station)
}

func configure(_ vc: StationViewController, with station: Station) {
    let dbRefresher = DBPredictionRefresher(station)
    let predictionPub = dbRefresher.$predictions.skipNils().map { preds in preds.sorted(by: { $0.secondsToArrival < $1.secondsToArrival }) }.skipNils()
    
    let visitsCall = getVisitsCall()
    let visitsRefresher = LUXCallRefresher(visitsCall)
    visitsCall.endpoint.addGetParams(params: filterParams(for: station))
    let visitsPub = unwrappedModelPublisher(from: visitsCall.publisher.$data.eraseToAnyPublisher(), ^\VisitsResponse.visits)
        .skipNils().map(station >|> calcVisitsStopsAway(from:_:))
    
    let estimatesCall = getEstimatesCall()
    let estimatesRefresher = LUXCallRefresher(estimatesCall)
    estimatesCall.endpoint.addGetParams(params: estimateFilterParams(for: station))
    let estimatesPub = unwrappedModelPublisher(from: estimatesCall.publisher.$data.eraseToAnyPublisher(), ^\EstimatesResponse.estimates)
        .skipNils()
    
    let predictionVMPub = predictionPub.combineLatest(visitsPub, estimatesPub).map(models(from:visits:estimates:))
    let filteredPVMPub = predictionVMPub
        .combineLatest(vc.$chosenColor).map(~filter(predictions:byColor:))
        .combineLatest(vc.$chosenDirection).map(~filter(predictions:byDirection:))
    
    vc.$chosenDirection.skipNils().sink(receiveValue: vc.chooseDirection).store(in: &vc.cancelBag)
    
    let itemsPub = filteredPVMPub.map(item(from:) >||> map)
    
    let refresher = MetaRefresher(dbRefresher, visitsRefresher, estimatesRefresher)
    
    let vm = LUXItemsTableViewModel(refresher, itemsPublisher: itemsPub.eraseToAnyPublisher())
    vm.setupEndRefreshing(from: visitsCall)
    if let ds = vm.dataSource as? FlexDataSource {
        let delegate = FUITableViewDelegate()
        delegate.onSelect = ds.tappableOnSelect
        vm.tableDelegate = delegate
    }
    vm.tableView = vc.tableView
    vm.refresh()
    
    predictionVMPub.map(lines(from:)).sink { vc.lineModels = $0 }.store(in: &vc.cancelBag)
    predictionVMPub.map(directions(from:)).sink { vc.setDirectionViews($0) }.store(in: &vc.cancelBag)
    
    itemsPub.sink(receiveValue: ignoreArg(vc.stopLoading)).store(in: &vc.cancelBag)
}

func lines(from predictions: [PredictionViewModel]) -> [LineViewModel] {
    let routeIds = predictions.compactMap(\PredictionViewModel.routeId) |> Set.init |> [String].init
    return lines(from: routeIds)
}

func directions(from predictions: [PredictionViewModel]) -> [ImageDirection] {
    return predictions
        .filter { $0.direction != nil }
        .map(fzip(^\PredictionViewModel.direction!.rawValue, ^\.routeId) >>> Current.directionProvider.directionEnum(for:routeId:))
        |> Set.init
        |> [ImageDirection].init
}

class StationViewController: FUITableViewViewController, LineChoiceViewDelegate {
    @IBOutlet var directionChoices: [UIImageView]!
    @IBOutlet var dirWidths: [NSLayoutConstraint]!
    @IBOutlet var dirLeadings: [NSLayoutConstraint]!
    
    @IBOutlet  var lineChoices: [LineChoiceView]!
    
    @IBOutlet weak var loadingImageView: UIImageView?
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var actionButtonBottomConstraint: NSLayoutConstraint?
    var lineModels: [LineViewModel] = [LineViewModel]() { didSet { setLineViews() }}
    var cancelBag = Set<AnyCancellable>()
    
    var isLoading = false { didSet { toggleLoadingAnimations() }}
    var directions: [ImageDirection]?
    @Published var chosenColor: UIColor?
    @Published var chosenDirection: ImageDirection?
    
    var onToggleFavoriteStation: ((StationViewController) -> Void)?
    var onOpenRoutes: ((StationViewController) -> Void)?
    var onActionPressed: ((StationViewController) -> Void)?

    @objc func toggleFavoriteStation() { onToggleFavoriteStation?(self) }
    @objc func openRoutes() { onOpenRoutes?(self) }
    @IBAction func actionButtonPressed() { onActionPressed?(self) }
    
    func startLoading() {
        if !isLoading {
            isLoading = true
        }
    }
    func stopLoading() { isLoading = false }
    
    func toggleLoadingAnimations() {
        if isLoading {
            spinLoadingImage(UIView.AnimationOptions.curveLinear)
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.loadingImageView?.alpha = 0
            })
        }
    }
    
    func spinLoadingImage(_ animOptions: UIView.AnimationOptions) {
        self.loadingImageView?.alpha = 1
        UIView.animate(withDuration: 1.0, delay: 0.0, options: animOptions, animations: {
            if let imageView = self.loadingImageView {
                imageView.transform = imageView.transform.rotated(by: .pi)
            }
        }, completion: { finished in
                if finished {
                    if self.isLoading {
                        self.spinLoadingImage(UIView.AnimationOptions.curveLinear)
                    } else if animOptions != UIView.AnimationOptions.curveEaseOut {
                        self.spinLoadingImage(UIView.AnimationOptions.curveEaseOut)
                        self.stopLoading()
                    }
                }
        })
    }
    
    func setDirectionViews(_ directions: [ImageDirection]) {
        self.directions = directions
        for i in 0..<directionChoices.count {
            if i < directions.count {
                let img = image(for: directions[i])
                setupDirectionChoice(i, with: img)
            } else {
                hideDirectionChoice(i)
            }
        }
    }
    
    func setupDirectionChoice(_ i: Int, with img: UIImage?) {
        directionChoices[i].isHidden = false
        directionChoices[i] |> setupCircleCappedView(_:)
        directionChoices[i].image = img
        directionChoices[i].layer.borderWidth = 1.0
        unhighlightDirection(i)
        directionChoices[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(directionPressed(_:))))
        directionChoices[i].isUserInteractionEnabled = true
        dirWidths[i].constant = 30
        dirLeadings[i].constant = 8
        view.setNeedsUpdateConstraints()
        view.updateConstraints()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func hideDirectionChoice(_ i: Int) {
        directionChoices[i].isHidden = true
        dirWidths[i].constant = 0
        dirLeadings[i].constant = 0
        view.setNeedsUpdateConstraints()
        view.updateConstraints()
    }
    
    func highlightDirection(_ i: Int) {
        directionChoices[i].image = directionChoices[i].image?.withTintColor(.primaryDark())
        directionChoices[i].layer.borderColor = UIColor.white.cgColor
        directionChoices[i].backgroundColor = UIColor.white
    }
    
    func unhighlightDirection(_ i: Int) {
        directionChoices[i].image = directionChoices[i].image?.withTintColor(.white)
        directionChoices[i].layer.borderColor = UIColor.white.cgColor
        directionChoices[i].backgroundColor = UIColor.clear
    }
    
    @objc func directionPressed(_ recognizer: UIGestureRecognizer) {
        if let i = directionChoices.firstIndex(of: recognizer.view as! UIImageView) {
            chosenDirection = directions?[i]
        }
    }
    
    func chooseDirection(_ direction: ImageDirection) {
        if let dirs = directions {
            setDirectionViews(dirs)
        }
        if let i = directions?.firstIndex(of: direction) {
            highlightDirection(i)
        }
    }
    
    func setLineViews(){
        var count = 0
        while count < lineChoices.count {
            let lineView = lineChoices[count]
            if count < lineModels.count {
                lineView.isHidden = false
                lineView.lineLabel.text = lineModels[count].routesString()
                let image = UIImage(named: "Grey")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                lineView.dotImageView.image = image
                lineView.dotImageView.tintColor = lineModels[count].color
            } else {
                lineView.isHidden = true
            }
            lineView.delegate = self
            lineView.updateConstraints()
            lineView.setNeedsLayout()
            lineView.layoutIfNeeded()
            count += 1
        }
    }
    
    func hideLineViews() {
        for lineChoice in lineChoices {
            lineChoice.isHidden = true
        }
    }
    
    //MARK: line choice delegate
    
    func didSelectLineWithColor(_ color: UIColor) {
        for lineView in lineChoices {
            if lineView.dotImageView.tintColor != color {
                lineView.isSelected = false
            }
        }
        
        chosenColor = color
    }
    
    func didDeselectLineWithColor(_ color: UIColor) { chosenColor = nil }
}

func filter(predictions: [PredictionViewModel], byColor color: UIColor?) -> [PredictionViewModel] {
    return predictions.filter { color == nil || Current.colorManager.colorForRouteId($0.routeId) == color }
}

func filter(predictions: [PredictionViewModel], byDirection direction: ImageDirection?) -> [PredictionViewModel] {
    return predictions.filter { direction == nil || Current.directionProvider.directionEnum(for: $0.direction!.rawValue, routeId: $0.routeId) == direction! }
}

func calcVisitsStopsAway(from station: Station, _ visits: [Visit]) -> [Visit] {
    for visit in visits {
        if visit.stopsAway == -1 {
            visit.stopsAway = Current.nycStationManager?.numberOfStopsBetween(station, visit.stationId!, visit.routeId!, Int64(visit.directionId!))
        }
    }
    return visits
}

func item(from model: PredictionViewModel) -> FlexDataSourceItem {
    return (model.estimates?.filter { $0.timeSeconds() > -1 }.count ?? 0) > 0 ? LUXModelItem(model, configureEstimateCell) : LUXModelItem(model, configurePredictionCell)
}

func models(from predictions: [Prediction], visits: [Visit], estimates: [Estimate]) -> [PredictionViewModel] {
    let uptown = predictions.filter { $0.direction == .uptown }
    let downtown = predictions.filter { $0.direction == .downtown }
    
    var predictionModels = [PredictionViewModel]()
    
    for prediction in uptown {
        let model = PredictionViewModel(routeId: prediction.route?.objectId, direction: prediction.direction!)
        if !predictionModels.contains(model) {
            model.setupWithPredictions(predictions)
            predictionModels.append(model)
        }
    }
    
    for prediction in downtown {
        let model = PredictionViewModel(routeId: prediction.route?.objectId, direction: prediction.direction!)
        if !predictionModels.contains(model) {
            model.setupWithPredictions(predictions)
            predictionModels.append(model)
        }
    }
    
    predictionModels.sort { $0.prediction.secondsToArrival < $1.prediction.secondsToArrival }
    
    for prediction in predictionModels {
        prediction.visits = visits.filter { $0.routeId == prediction.routeId && $0.directionId == prediction.direction.rawValue }
        prediction.estimates = estimates.filter  { $0.routeId == prediction.routeId && $0.directionId == prediction.direction.rawValue && $0.timeSeconds() > -1 }
    }
    
    return predictionModels
}

func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}
