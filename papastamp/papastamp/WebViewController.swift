//
//  WebViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 4..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import Alamofire
import EZAlertController
import SwiftyJSON
import Firebase
import SwiftyUserDefaults
import CoreLocation
import UserNotifications

class WebViewController: UIViewController {

    @IBOutlet weak var stampButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var stampButton: UIButton!
    
    var myBeaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString:"24ddf411-8cf1-440c-87cd-e368daf9c93e")!, identifier: "com.mycisco.beacon")
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stampButton.isHidden = true
        self.stampButtonHeightConstraint.constant = 0
        
        self.beaconSetting()
        self.webViewLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedStampButton(_ sender: Any) {
        
        
    }
    
    func beaconSetting() {
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.myBeaconRegion.notifyOnEntry = true
        self.myBeaconRegion.notifyOnExit = true
        self.locationManager.startMonitoring(for: self.myBeaconRegion)
        self.locationManager.startUpdatingLocation()
    }
    
    func webViewLoad(shopInfo: String = "SB-SHOP-00001") {
        
        /*
         https://whereareevent.com/shop/v1.0/shopInfo (GET)
         Parameter : ~/shopInfo/:shopId/:userId
         Ex) https://whereareevent.com/shop/v1.0/shopInfo/SB-SHOP-00001/9c4e059cb007a6d5065017d8f07133cd
         (참고: shopId는 SB-SHOP-00001를 default로 사용하시면 되고 userId는 login화면에서 전달한 uid를 받으면 됩니다.)
         */
        
        let uid: String = (Auth.auth().currentUser?.uid)!
        let urlStr = "https://whereareevent.com/shop/v1.0/shopInfo/\(shopInfo)/\(uid)"
        self.webView.loadRequest(URLRequest(url: URL(string: urlStr)!))
    }
    
    func updateLocation(coordinate: CLLocationCoordinate2D) {

        /*
         https://whereareevent.com/map/v1.0/updateLocation (PUT)
         Header (Content-Type: application/json) – key : user_id / value : uid
         Body - key : latitude / value : latitude, key : longitude / value : longitude
         */

        let uid: String = (Auth.auth().currentUser?.uid)!
        let headers = ["user_id" : uid,
                       "Content-Type" : "application/json"]

        let parameters = ["latitude": coordinate.latitude,
                          "longitude": coordinate.longitude]
        
        var request = try! URLRequest(url: URL(string: "https://whereareevent.com/map/v1.0/updateLocation")!, method: .put, headers: headers)
        let data = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        if let json = json {
            debugPrint(json)
        }
        request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
        Alamofire.request(request).responseJSON { response in
            debugPrint(response.request)
            debugPrint(response.response)
            debugPrint(response.data)
            debugPrint(response.result)
        }
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

extension WebViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
         manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.updateLocation(coordinate: userLocation.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.locationManager.requestState(for: self.myBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (CLLocationManager.isRangingAvailable()) {
            self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        if (state == .inside) {
            if (CLLocationManager.isRangingAvailable()) {
                self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
            }
        } else if (state == .outside) {
            self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
        } else {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        guard beacons.count > 0 else {
            return
        }
        
        // MARK: 로그인이 안되어 있으면 비콘 신호를 무시한다.
        guard Auth.auth().currentUser?.uid.isEmpty == false else {
            return
        }
        
        let nearestBeacon = beacons.first!
        self.getShopBeacon(beacon: nearestBeacon)
        self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
    }
    
    func getShopBeacon(beacon: CLBeacon){
        /*
         https://whereareevent.com/shop/v1.0/shopBeacon (GET)
         Parameter : ~/shopBeacon/:major/:minor
         Ex) https://whereareevent.com/shop/v1.0/shopBeacon/1000/100 호출 시 shopId(SB-SHOP-00001) 전달
         푸쉬 클릭 시전달된 shopId 와 login에서 생성된 uid를 가지고 웹뷰 페이지 호출(https://whereareevent.com/shop/v1.0/shopInfo/SB-SHOP-00001/9c4e059cb007a6d5065017d8f07133cd)
         */
        
        // MARK: 비콘 <-> 아이폰 거리
        debugPrint("거리 \(beacon.accuracy)")
        debugPrint("RSSI \(beacon.rssi)")
        
        let urlStr = "https://whereareevent.com/shop/v1.0/shopBeacon/\(beacon.major.stringValue)/\(beacon.minor.stringValue)"
        Alamofire.request(urlStr, method: .get).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                debugPrint(json)
                //                Defaults[.uid] = self.getUid()
                //                self.setCustomTokenToFirebase(token: json["customToken"].stringValue)
                
            case .failure(let error):
                EZAlertController.alert("", message: error.localizedDescription)
            }
        }
    }
}

