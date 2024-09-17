import UIKit
import PlaygroundSupport
@testable import NYCSubwayLib
import PlaygroundVCHelpers
import LUX
import LithoOperators

NSSetUncaughtExceptionHandler { exception in
    print("💥 Exception thrown: \(exception)")
}

Current = testing

UINavigationBar.appearance().isTranslucent = false
UINavigationBar.appearance().barTintColor = UIColor.primary()
UINavigationBar.appearance().tintColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "AvenirNext-Regular", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)]
UISearchBar.appearance().tintColor = UIColor.accent()

let mapVC = pdfMapVC()
if let onDbLoad = mapVC.onDatabaseLoaded {
    mapVC.onDatabaseLoaded = union(onDbLoad, {
        let station = Current.stationManager.stationsForSearchString("Times")?.first
        $0.openStation(station)
    })
}
let navVC = AdNavigationController(rootViewController: mapVC)

DispatchQueue.global(qos: .background).async {
    DatabaseLoader.loadDb()
}

PlaygroundPage.current.liveView = navVC
PlaygroundPage.current.needsIndefiniteExecution = true
