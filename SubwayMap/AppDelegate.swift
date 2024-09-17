//
//  AppDelegate.swift
//  SubwayMap
//
//  Created by Elliot Schrock on 7/27/15.
//  Copyright (c) 2015 Thryv. All rights reserved.
//

import UIKit
import Crashlytics
import NYCSubwayLib
import SBNag_swift
import PlaygroundVCHelpers
import StoreKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    let mapVC = pdfMapVC()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        Fabric.with([Crashlytics()])
        
        UNUserNotificationCenter.current().delegate = self
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = UIColor.primary()
        UINavigationBar.appearance().tintColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "AvenirNext-Regular", size: 20)!, NSAttributedString.Key.foregroundColor : UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1)]
        UISearchBar.appearance().tintColor = UIColor.accent()
        
        DispatchQueue.global(qos: .background).async {
            DatabaseLoader.loadDb()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navVC = AdNavigationController(rootViewController: mapVC)
        navVC.navigationBar.barStyle = UIBarStyle.black
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
//        mapVC.wifiTracker.trackWifi()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let nag = SBNagService()
        
        let rateNagtion = SBNagtion()
        rateNagtion.defaultsKey = "rate"
        rateNagtion.title = "Sorry to interrupt..."
        rateNagtion.message = "...but would you mind rating this app?"
        rateNagtion.noText = "Nope, I'll never rate this app"
        rateNagtion.yesAction = { () in
            SKStoreReviewController.requestReview()
//            UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/subway-map-nyc/id1025535484?ls=1&mt=8")!)
        }
        
        nag.nagtions.append(rateNagtion)
        nag.startCountDown()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

