//
//  GetEstimatesCall.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/23/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import FunNet
import Combine
import LithoOperators
import Prelude
import SwiftDate
import SubwayStations

func getEstimatesCall(_ serverConfig: ServerConfigurationProtocol = Current.serverConfig) -> CombineNetCall {
    var endpoint = Endpoint()
    endpoint.path = "estimates"
    endpoint /> addJsonHeaders
    let call = CombineNetCall(configuration: serverConfig, endpoint)
    if serverConfig.shouldStub {
        call.firingFunc = { $0.responder?.data = estimatesJson().data(using: .utf8) }
    }
    return call
}

func estimateFilterParams(for station: Station) -> [String: String] {
    var filterParams: [String: String] = [:]
    filterParams["station_ids"] = station.stopIdsFilterString()
    filterParams["after"] = DateFormatter.iso8601Full.string(from: Current.timeProvider().adjustForTimeZone() - 5.minutes)
    return filterParams
}

func estimatesJson() -> String {
    return """
"""
}
