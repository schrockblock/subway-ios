//
//  World.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 1/29/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import SubwayStations
import GTFSStations
import Slippers

public var Current = paid

let free = World().configure { world in
    ifSimulator { world.isAdmin = true }
    world.serverConfig = NYCServerConfiguration.production
    world.adsEnabled = true
    JsonProvider.jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Seconds)
}

let paid = World().configure { world in
    ifSimulator { world.isAdmin = true }
    world.serverConfig = NYCServerConfiguration.production
    world.adsEnabled = false
    world.pdfTouchConverter = NYCNightPDFTouchConverter()
    world.isAdmin = true
    JsonProvider.jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Seconds)
}

let testing = World().configure {
    $0.serverConfig = NYCServerConfiguration.testing
    $0.adsEnabled = false
    $0.timeProvider = mockTime
    $0.uuidProvider = mockUuid
    JsonProvider.jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Seconds)
}

public struct World {
    public var isAdmin: Bool = false
    public var serverConfig = NYCServerConfiguration.production
    public var colorManager: RouteColorManager = NYCRouteColorManager()
    public var adsEnabled: Bool = false
    public var stationManager: StationManager!
    public var navManager: StationManager!
    public var favManager: FavoritesManager = FavoritesManager()
    public var directionProvider: DirectionProvider = NYCDirectionNameProvider()
    public var pdfTouchConverter: PDFTouchConverter = NYCPDFTouchConverter()
    public var timeProvider: () -> Date = currentTime
    public var uuidProvider: () -> String = fetchUuid
}
extension World: Configurable {}
extension World {
    var nycStationManager: NYCStationManager? { get { self.navManager as? NYCStationManager }}
}

extension DateFormatter: Configurable {}
