//
//  PDFMapViewController.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/4/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit
import CoreLocation
import PDFKit
import SubwayStations
import SBTextInputView
import FlexDataSource
import Prelude
import LithoOperators
import PlaygroundVCHelpers
import Combine
import fuikit
import LUX
import SwiftDate

public func pdfMapVC() -> PDFMapViewController {
    let vc = PDFMapViewController.makeFromXIB()
    configureSearch(vc)
    vc.onViewDidLoad = union(setupVCBG, setAppTitle, setEdges, ~>styleStationSearch, ~>setupBottomButton)
    vc.onViewWillAppear = ignoreSecondArg(f: ~>setupPDFMap)
    vc.onDatabaseLoaded = onDatabaseLoaded(vc:)
    vc.onOpenStation = ~>stationVC(for:) >?> vc.emptyBackClosure()
    vc.onOpenFavorites = favsVC >>> vc.emptyBackClosure()
    vc.onOpenVisits = userReportsVC >>> vc.emptyBackClosure()
    vc.onNearestStation = onNearestStationPressed(_:)
    vc.onWifi = ignoreArg(followRedirect)
    return vc
}

func onDatabaseLoaded(vc: PDFMapViewController) {
    vc.isLoading = false
    vc.setupBarButtons()
    
    vc.wifiTracker.trackWifi()
    
    vc.stations = Current.stationManager.allStations
    
    vc.clearTapGestureRecognizers()
    vc.setupStationTap()
    vc.pdfView.documentView?.addTapGestureRecognizer(numberOfTaps: 2, action: vc.zoomIn)
    
    UIView.animate(withDuration: 0.5, animations: {
        vc.searchBar?.alpha = 1
        vc.loadingImageView.alpha = 0
    })
}

func isSortedByDistance(to loc: (CLLocationDegrees, CLLocationDegrees)) -> (Station, Station) -> Bool {
    return {
        $0.distance(to: loc, euclideanDistance) < $1.distance(to: loc, euclideanDistance)
    }
}

let stationsSortedBy: ((Station, Station) -> Bool) -> [Station] = { Current.stationManager.allStations.sorted(by: $0) }
let closestStationToLoc: (CLLocation) -> Station? = fzip(^\CLLocation.coordinate.latitude, ^\CLLocation.coordinate.longitude) >>> isSortedByDistance(to:)
    >>> stationsSortedBy >>> ^\[Station].first
func onNearestStationPressed(_ vc: PDFMapViewController) {
    let pushStation = stationVC(for:) >?> vc.emptyBackClosure()
    let updateIsPushingTrue: () -> Void = { [weak vc] in
        vc?._isPushing = true
        vc?.nearestLoadingIndicator.isHidden = true
    }
    let updateIsPushingFalse: () -> Void = { [weak vc] in
        vc?._isPushing = false
    }
    vc.locationDelegate.onDidUpdateLocations = ignoreFirstArg(f: ^\[CLLocation].last >?> ifThen(vc.isNotPushing, closestStationToLoc >?> union(runOnMain(pushStation), ignoreArg(vc.locationManager.stopUpdatingLocation), ignoreArg(updateIsPushingTrue)), else: updateIsPushingFalse))
    vc.locationManager.delegate = vc.locationDelegate
    vc.locationManager.requestAlwaysAuthorization()
    vc.locationManager.startUpdatingLocation()
    vc.nearestLoadingIndicator.isHidden = false
}

public class PDFMapViewController: StationSearchViewController, PDFMapper, UITableViewDelegate {
    @IBOutlet public weak var pdfView: PDFView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var buttonBottomConstaint: NSLayoutConstraint!
    @IBOutlet weak var nearestLoadingIndicator: UIActivityIndicatorView!
    
    var _isPushing = false
    
    var isLoading = false
    let locationManager = CLLocationManager()
    let locationDelegate = FCLLocationManagerDelegate()
    
    var onDatabaseLoaded: ((PDFMapViewController) -> Void)?
    var onOpenStation: ((Station?) -> Void)?
    var onOpenVisits: () -> Void = {}
    var onOpenFavorites: () -> Void = {}
    var onNearestStation: ((PDFMapViewController) -> Void)?
    var onWifi: ((PDFMapViewController) -> Void)?
    
    public let wifiTracker = WifiTracker()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotifs()
        
        var pdfName = "subway"
        Current.pdfTouchConverter = NYCPDFTouchConverter()
        let rNY = Region(calendar: Calendars.gregorian, zone: Zones.americaNewYork, locale: Locales.english)
        if Date().convertTo(region: rNY).hour < 6 {
            pdfName = "night"
            Current.pdfTouchConverter = NYCNightPDFTouchConverter()
        }
        let pdf = PDFDocument(url: URL(fileURLWithPath: Bundle(for: Self.self).path(forResource: pdfName, ofType:"pdf") ?? ""))
        pdfView.document = pdf
        pdfView.documentView?.addTapGestureRecognizer(numberOfTaps: 2, action: zoomIn)
        
        tableViewDelegate = FUITableViewDelegate()
        if let onOpenStation = onOpenStation, let dataSource = viewModel?.flexDataSource {
            let openStation = ^\LUXModelItem<Station, StationTableViewCell>.model >?> onOpenStation
            tableViewDelegate?.onSelect = union(dataSource.itemTapOnSelect(onTap: ~>openStation), ignoreArgs(dismissKeyboardAndHideTable))
        }
        tableView?.delegate = tableViewDelegate
        
        if !DatabaseLoader.isDatabaseReady {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(PDFMapViewController.databaseLoaded),
                                                   name: NSNotification.Name(rawValue: DatabaseLoader.NYCDatabaseLoadedNotification),
                                                   object: nil)
            searchBar?.alpha = 0
            startLoading()
        } else {
            databaseLoaded()
        }
        
        ifSimulator {
            Current.pdfTouchConverter.addStopDots(to: self.pdfView.documentView!, dots: &Current.pdfTouchConverter.dots)
        }
    }
    
    func setupNotifs() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert,.sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied")
            } else {
                print("yay")
            }
        }
    }
    
    func isNotPushing() -> Bool {
        return !_isPushing
    }
    
    func setupStationTap() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(PDFMapViewController.openStationAt))
        singleTap.numberOfTapsRequired = 1
        pdfView.documentView?.addGestureRecognizer(singleTap)
    }
    
    @objc func openStationAt(_ recognizer: UITapGestureRecognizer) {
        if !isZoomedOut {
            let touch = recognizer.location(in: pdfView.documentView)
            
            let vAdjustment = Current.pdfTouchConverter.verticalAdjustment
            let hAdjustment = Current.pdfTouchConverter.horizontalAdjustment
            let vScaleFactor = Current.pdfTouchConverter.verticalScaleFactor
            let hScaleFactor = Current.pdfTouchConverter.horizontalScaleFactor
            
            let x = touch.x * hScaleFactor / pdfView.documentView!.bounds.size.width - hAdjustment
            let y = touch.y * vScaleFactor / pdfView.documentView!.bounds.size.height - vAdjustment
            
            if let id = Current.pdfTouchConverter.fuzzyCoordToId(coord: (Int(x), Int(y)), fuzziness: Int(Current.pdfTouchConverter.fuzzyRadius)) {
                onOpenStation?(Current.stationManager.allStations.filter { $0.stops.filter { $0.objectId == id }.count > 0 }.first)
            }
        }
    }
    
    func setupBarButtons() {
        setupFavoritesButton()
        setupVisitsButton()
    }
    
    func setupVisitsButton() {
        let visitsBarButton = barButtonItem(for: "eye_white", selector: #selector(PDFMapViewController.openVisits))
        if var items = self.navigationItem.rightBarButtonItems {
            items.append(visitsBarButton)
            self.navigationItem.rightBarButtonItems = items
        }
    }
    
    func setupFavoritesButton() {
        let favBarButton = barButtonItem(for: "star_white_24pt", selector: #selector(PDFMapViewController.openFavorites))
        self.navigationItem.rightBarButtonItems = [favBarButton]
    }
    
    func startLoading() {
        if !isLoading {
            isLoading = true
            spinLoadingImage()
        }
    }
    
    func spinLoadingImage(_ animOptions: UIView.AnimationOptions = .curveLinear) {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: animOptions, animations: {
            self.loadingImageView.transform = self.loadingImageView.transform.rotated(by: CGFloat(Double.pi))
            return
        }, completion: { finished in
            if finished {
                if self.isLoading {
                    self.spinLoadingImage(.curveLinear)
                }else if animOptions != .curveEaseOut{
                    self.spinLoadingImage(.curveEaseOut)
                }
            }
        })
    }
    
    @objc func openVisits() { onOpenVisits() }
    @objc func openFavorites() { onOpenFavorites() }
    @objc func databaseLoaded() { onDatabaseLoaded?(self) }
    @IBAction func actionButtonPressed() { onNearestStation?(self) }
    @IBAction func wifiButtonPressed() { onWifi?(self) }
    deinit { NotificationCenter.default.removeObserver(self) }
}
