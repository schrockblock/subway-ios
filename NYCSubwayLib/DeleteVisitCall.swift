//
//  DeleteVisitCall.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 2/14/20.
//  Copyright © 2020 Thryv. All rights reserved.
//

import LUX
import FunNet
import Combine
import LithoOperators
import Prelude

func deleteVisitCall(_ serverConfig: ServerConfigurationProtocol = Current.serverConfig, id: String) -> CombineNetCall {
    var endpoint = Endpoint()
    endpoint.path = "visits/\(id)"
    endpoint /> setToDelete
    endpoint /> addJsonHeaders
    return CombineNetCall(configuration: serverConfig, endpoint)
}
