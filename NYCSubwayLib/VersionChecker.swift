//
//  VersionChecker.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 4/27/18.
//  Copyright © 2018 Thryv. All rights reserved.
//

import UIKit

class VersionChecker {
    static func isNewVersion(version: String) -> Bool {
        let bundleVersion = self.bundleVersion()
        let bundleComponents = bundleVersion.components(separatedBy: ".")
        let versionCompenents = version.components(separatedBy: ".")
        if bundleComponents.count == versionCompenents.count {
            for i in 0...bundleComponents.count - 1 {
                let bundleComponent = Int(bundleComponents[i]) ?? 0
                let versionComponent = Int(versionCompenents[i]) ?? 0
                
                if versionComponent < bundleComponent {
                    return true
                }
            }
        } else {
            return true
        }
        return false
    }
    
    static func bundleVersion() -> String {
        return ((Bundle.main.infoDictionary?["CFBundleVersion"] as? String?) ?? "")!
    }
}
