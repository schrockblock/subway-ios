//
//  UuidProvider.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 6/17/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

func fetchUuid() -> String {
    if let uuid = UserDefaults.standard.string(forKey: "uuid") {
        return uuid
    } else {
        let uuid = UUID.init().uuidString
        UserDefaults.standard.set(uuid, forKey: "uuid")
        UserDefaults.standard.synchronize()
        return uuid
    }
}

func mockUuid() -> String {
    return "676a5a3c-5d5c-4a16-a9c0-78a3521fded7"
}
