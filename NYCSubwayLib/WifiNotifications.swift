//
//  WifiNotifications.swift
//  NYCSubwayLib
//
//  Created by Elliot Schrock on 5/23/21.
//  Copyright © 2021 Thryv. All rights reserved.
//

import Foundation
import UserNotifications

func sendJoinedNotification() {
    let content = UNMutableNotificationContent()
    content.title = "MTA Wifi Joined"
    content.body = "You've joined the MTA's wifi network."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendResponseCodeNotification(_ code: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Attempted login to MTA Wifi"
    content.body = "Response code was \(code)."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendHeadersNotification(_ headers: [AnyHashable: Any]) {
    let content = UNMutableNotificationContent()
    content.title = "Attempted wifi login with headers:"
    content.body = "\(headers)."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendStringNotification(_ string: String) {
    let content = UNMutableNotificationContent()
    content.title = "Wifi debugging:"
    content.body = "\(string)."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendRedirectNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Ad redirect on MTA Wifi"
    content.body = "Redirected to ad, skipping now..."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendAuthNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Authorizing MTA Wifi"
    content.body = "Authorizing..."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendLoginNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Logging in to MTA Wifi"
    content.body = "Logging in post ad..."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendLoggedInNotification(_ stationName: String) {
    let content = UNMutableNotificationContent()
    content.title = "MTA Wifi Detected"
    content.body = "We've detected MTA wifi at \(stationName)."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendNearbyNotification(_ stationName: String) {
    let content = UNMutableNotificationContent()
    content.title = "Nearby \(stationName)"
    content.body = "You are at \(stationName), it looks like"
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendLoggedInNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Auto logged in to MTA Wifi"
    content.body = "We've logged you in successfully."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}

func sendConnectedNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Connected to MTA Wifi"
    content.body = "We've logged you in successfully."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.15, repeats: false)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString,
                content: content, trigger: trigger)

    // Schedule the request with the system.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
       if error != nil {
//          print(error)
       }
    }
}
