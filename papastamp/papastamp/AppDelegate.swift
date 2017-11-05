//
//  AppDelegate.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 1..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import Alamofire
import EZAlertController
import SwiftyJSON
import Firebase
import SwiftyUserDefaults
import SVProgressHUD
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func moveTutorialViewController() {
        self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tutorial")
    }
    
    func moveMainViewController() {
        debugPrint("moveMainViewController")
        self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
    }
    
    func moveWebViewController() {
        debugPrint("moveWebViewController")
        self.apnsSetting()
        self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "webView")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UIStoryboard.init(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        self.window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        // MARK: Tutorial
        if (Defaults[.isTutorial] == true ||
            !Defaults.hasKey(.isTutorial)) {
            self.moveTutorialViewController()
            Defaults[.isTutorial] = false
        } else {
            // MARK: 로그인 유저 구분
            if (Auth.auth().currentUser?.uid == nil) {
                self.moveMainViewController()
            } else {
                self.moveWebViewController()
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //        if (CLLocationManager.isRangingAvailable()) {
        //            self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
        //        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Defaults[.isSentBeaconPush] = false
    }
    
    func apnsSetting() {
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // MARK: 앱이 활성화 상태일 때
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        

        
        completionHandler([])
    }
    
    // MARK: 앱이 백그라운드 일때,
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        var topController = UIApplication.shared.keyWindow?.rootViewController
        

        if (topController is WebViewController) {
            (topController as! WebViewController).getShopBeacon(userInfo: userInfo)
            return
        }
        
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
            
            if topController is WebViewController {
                (topController as! WebViewController).getShopBeacon(userInfo: userInfo)
                return
            }
        }
        
        completionHandler()
    }
}

