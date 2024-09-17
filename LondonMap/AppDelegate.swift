//
//  AppDelegate.swift
//  LondonMap
//
//  Created by Elliot Schrock on 3/31/16.
//  Copyright © 2016 Thryv. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import NagController
import PlaygroundVCHelpers

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NagControllerDelegate {
    let LastNaggedKey = "LastNaggedKey"
    var window: UIWindow?
    var nagger: NagController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Fabric.with([Crashlytics()])
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red: 58.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "AvenirNext-Regular", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)]
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            DatabaseLoader.loadDb()
        })
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let mapVC = MapViewController.makeFromXIB()
        
        let navVC = UINavigationController(rootViewController: mapVC)
        window?.rootViewController = navVC;
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        var appOpens = NSUserDefaults.standardUserDefaults().integerForKey("numberOfAppOpens")
        appOpens++
        NSUserDefaults.standardUserDefaults().setInteger(appOpens, forKey: "numberOfAppOpens")
        
        if appOpens % 3 == 0 {
            if let lastTime = lastNagged() {
                if lastTime.isBefore(NSDate().incrementUnit(NSCalendarUnit.Day, by: -2)) {
                    nag()
                }
            }else{
                nag()
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func nag() {
        nagger = NagController()
        nagger.delegate = self
        nagger.ratingURLStr = "https://itunes.apple.com/us/app/subway-map-nyc/id1025535484?ls=1&mt=8"
        nagger.startNag()
    }
    
    func lastNagged() -> NSDate? {
        return NSUserDefaults.standardUserDefaults().objectForKey(LastNaggedKey) as? NSDate
    }
    
    // MARK: Nag Delegate
    
    func didPerformNag(eventName: String!, withResponse response: NagResponse) {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: LastNaggedKey)
    }
}

