//
//  AutoLoginWifi.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 4/11/21.
//  Copyright © 2021 Thryv. All rights reserved.
//

import NetworkExtension

let wifiSSID = "TransitWirelessWiFi"//"Arthouse"//

func fetchNetwork() {
    if #available(iOS 14.0, *) {
        NEHotspotNetwork.fetchCurrent(completionHandler: handleNetwork)
    } else {
        // Fallback on earlier versions
    }
}
let handleNetwork: (NEHotspotNetwork?) -> Void = { network in
    if let net = network, net.ssid == wifiSSID /*&& net.didJustJoin*/ {
        followRedirect()
    }
}
