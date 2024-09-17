//
//  GetVisitsCall.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/17/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import LUX
import FunNet
import Combine
import LithoOperators
import Prelude
import SwiftDate
import SubwayStations

func getVisitsCall(_ serverConfig: ServerConfigurationProtocol = Current.serverConfig) -> CombineNetCall {
    var endpoint = Endpoint()
    endpoint.path = "visits"
    endpoint /> addJsonHeaders
    let call = CombineNetCall(configuration: serverConfig, endpoint)
    if serverConfig.shouldStub {
        call.firingFunc = { $0.responder?.data = visitsJson().data(using: .utf8) }
    }
    return call
}

func filterParams(for station: Station) -> [String: String] {
    var filterParams: [String: String] = [:]
    filterParams["current_station_ids"] = station.stopIdsFilterString()
    filterParams["after"] = DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 5.minutes)
    if let routeIds = Current.nycStationManager?.routeIdsForStation(station) {
        filterParams["route_ids"] = routeIds.joined(separator: ",")
    }
    return filterParams
}

func visitsJson() -> String {
    return """
    { "visits": [
    {"route_id":"3","station_id":"128","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":1},
    {"route_id":"3","station_id":"132","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"2","station_id":"120","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0},
    {"route_id":"1","station_id":"129","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"1","station_id":"125","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0},
    {"route_id":"1","station_id":"132","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":1},
    {"route_id":"3","station_id":"120","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":1,"stops_away":2},
    {"route_id":"3","station_id":"128","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":1},
    {"route_id":"3","station_id":"132","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"2","station_id":"128","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0,"stops_away":1},
    {"route_id":"2","station_id":"123","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":1,"stops_away":1},
    {"route_id":"2","station_id":"120","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0},
    {"route_id":"2","station_id":"132","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":1},
    {"route_id":"1","station_id":"129","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"1","station_id":"125","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 2.minutes))","direction_id":0},
    {"route_id":"1","station_id":"132","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":1},
    {"route_id":"7","station_id":"723","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0},
    {"route_id":"E","station_id":"A31","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"E","station_id":"A28","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":1},
    {"route_id":"A","station_id":"A31","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":1},
    {"route_id":"A","station_id":"A30","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"A","station_id":"A24","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0},
    {"route_id":"A","station_id":"A31","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"R","station_id":"R17","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":1},
    {"route_id":"R","station_id":"R15","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":0},
    {"route_id":"Q","station_id":"R14","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 3.minutes))","direction_id":1,"stops_away":2},
    {"route_id":"Q","station_id":"R20","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":0,"stops_away":2},
    {"route_id":"Q","station_id":"B08","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":0},
    {"route_id":"N","station_id":"R20","time":"\(DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 4.minutes))","direction_id":0,"stops_away":2}
    ]
    }
    """
}
