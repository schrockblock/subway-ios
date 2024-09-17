//
//  DatabaseLoader.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 7/1/16.
//  Copyright © 2016 Thryv. All rights reserved.
//

import UIKit
import GTFSStationsParis
import SubwayStations
import ZipArchive

public class DatabaseLoader: NSObject {
    static var isDatabaseReady: Bool = false
    static var stationManager: StationManager!
    static let NYCDatabaseLoadedNotification = "PARDatabaseLoadedNotification"
    static var documentsDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    static var destinationPath: String {
        return self.documentsDirectory + "/" + "gtfs.db"
    }
    
    public class func loadDb() {
        unzipDBToDocDirectoryIfNeeded()
        do {
            stationManager = try PARStationManager(sourceFilePath: destinationPath)
            DispatchQueue.main.async(execute: { () -> Void in
                self.isDatabaseReady = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NYCDatabaseLoadedNotification), object: nil)
            })
        }catch let error as NSError{
            print(error.debugDescription)
        }
    }
    
    public class func unzipDBToDocDirectoryIfNeeded(){
        if !FileManager.default.fileExists(atPath: destinationPath) {
            let sourcePath = Bundle.main.path(forResource: "gtfs.db", ofType: "zip")
            var error: NSError?
            let unzipper = ZipArchive()
            unzipper.unzipOpenFile(sourcePath)
            unzipper.unzipFile(to: documentsDirectory, overWrite: false)
            let fileUrl = URL(fileURLWithPath: destinationPath)
            do {
                try (fileUrl as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
            } catch let error1 as NSError {
                error = error1
            }
        }
    }
}
