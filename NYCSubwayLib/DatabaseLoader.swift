//
//  DatabaseLoader.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 8/2/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import UIKit
import GTFSStations
import SubwayStations
import ZipArchive

public class DatabaseLoader: NSObject {
    static var isDatabaseReady: Bool = false
    static var stationManager: StationManager!
    static var navManager: StationManager!
    static let NYCDatabaseLoadedNotification = "NYCDatabaseLoadedNotification"
    static var documentsDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
    }
    static var destinationPath: String {
        return self.documentsDirectory + "/" + "gtfs.db"
    }
    static var navDbDestinationPath: String {
        return self.documentsDirectory + "/" + "nav.db"
    }
    
    public class func loadDb() {
        unzipDBToDocDirectoryIfNeeded()
        if let stationManager = try? NYCStationManager(sourceFilePath: destinationPath) {
            self.stationManager = stationManager
            navManager = try? NYCStationManager(sourceFilePath: navDbDestinationPath)
            DispatchQueue.main.async {
                Current.stationManager = self.stationManager
                Current.navManager = self.navManager
                self.isDatabaseReady = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NYCDatabaseLoadedNotification), object: nil)
            }
        }
    }
    
    public class func unzipDBToDocDirectoryIfNeeded(){
        if shouldUnzip(defaultsKey: "version", path: destinationPath) {
            unzipScheduleToDocDirectory()
        }
        if shouldUnzip(defaultsKey: "nav_version", path: navDbDestinationPath) {
            unzipNavToDocDirectory()
        }
    }
    
    public class func shouldUnzip(defaultsKey: String, path: String) -> Bool {
        var shouldUnzip = !FileManager.default.fileExists(atPath: path)
        if let storedVersion = UserDefaults.standard.string(forKey: defaultsKey) {
            shouldUnzip = shouldUnzip || VersionChecker.isNewVersion(version: storedVersion)
        } else {
            shouldUnzip = true
        }
        
        return shouldUnzip
    }
    
    class func unzipScheduleToDocDirectory() {
        unzipDBToDocDirectory(resourceName: "gtfs.db", destination: destinationPath, defaultsKey: "version")
    }
    
    class func unzipNavToDocDirectory() {
        unzipDBToDocDirectory(resourceName: "nav.db", destination: navDbDestinationPath, defaultsKey: "nav_version")
    }
    
    class func unzipDBToDocDirectory(resourceName: String, destination: String, defaultsKey: String){
        let sourcePath = Bundle(for: Self.self).path(forResource: resourceName, ofType: "zip")
        var error: NSError?
        let unzipper = ZipArchive()
        unzipper.unzipOpenFile(sourcePath)
        unzipper.unzipFile(to: documentsDirectory, overWrite: true)
        let fileUrl = URL(fileURLWithPath: destinationPath)
        do {
            try (fileUrl as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        } catch let error1 as NSError {
            error = error1
        }
        
        UserDefaults.standard.set(VersionChecker.bundleVersion(), forKey: defaultsKey)
    }
}
