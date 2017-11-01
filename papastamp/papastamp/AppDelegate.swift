//
//  AppDelegate.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 1..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var myBeaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString:"24ddf411-8cf1-440c-87cd-e368daf9c93e")!, identifier: "com.mycisco.beacon")
    var locationManager: CLLocationManager = CLLocationManager()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.beaconSetting()
        // MARK: Push Setting
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
            
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if (CLLocationManager.isRangingAvailable()) {
            self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
    }
    
    func beaconSetting() {
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.myBeaconRegion.notifyOnEntry = true
        self.myBeaconRegion.notifyOnExit = true
        self.locationManager.startMonitoring(for: self.myBeaconRegion)

    }
    
    func sendToLocalNotification(_ notiTitle: String, notiBody: String) {
        debugPrint("sendToLocalNotification : \(notiBody)")
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title       = notiTitle
            content.body        = notiBody
            content.sound       = UNNotificationSound.default()
            
            let request = UNNotificationRequest.init(identifier: "beacon", content: content, trigger: nil)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
        } else {
            let notification = UILocalNotification()
            notification.alertTitle = notiTitle
            notification.alertBody  = notiBody
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.locationManager.requestState(for: self.myBeaconRegion)
        self.sendToLocalNotification("[DEBUG]", notiBody: "didStartMonitoringFor")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        self.sendToLocalNotification("[DEBUG]", notiBody: "monitoringDidFailFor")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.sendToLocalNotification("[DEBUG]", notiBody: "didEnterRegion")
        
        if (CLLocationManager.isRangingAvailable()) {
            self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.sendToLocalNotification("[DEBUG]", notiBody: "didExitRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {

        if (state == .inside) {
            if (CLLocationManager.isRangingAvailable()) {
                self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
            }
            self.sendToLocalNotification("[DEBUG]", notiBody: "didDetermineState inside")
        } else if (state == .outside) {
            self.sendToLocalNotification("[DEBUG]", notiBody: "didDetermineState outside")
        } else {
            self.sendToLocalNotification("[DEBUG]", notiBody: "didDetermineState unknow")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        self.sendToLocalNotification("[DEBUG]", notiBody: "didRangeBeacons")
        
        if beacons.count > 0 {
            let nearestBeacon = beacons.first!
            let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
            let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)
            self.sendToLocalNotification("[DEBUG]", notiBody: "didRangeBeacons \(major),\(minor)")
        }
    }
}
