//
//  NYCServerConfiguration.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/17/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit
import FunNet

class NYCServerConfiguration: NSObject {
    static let production = ServerConfiguration(host: "nyc-subway.herokuapp.com", apiRoute: "api/v3")
    static let testing = ServerConfiguration(shouldStub: true, host: "nyc-subway.herokuapp.com", apiRoute: "api/v3")
}
