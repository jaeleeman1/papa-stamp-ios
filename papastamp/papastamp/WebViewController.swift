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
import SVProgressHUD

class WebViewController: UIViewController {
    
    @IBOutlet weak var stampButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var stampButton: UIButton!
    
    var myBeaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString:"24ddf411-8cf1-440c-87cd-e368daf9c93e")!, identifier: "com.mycisco.beacon")
    var locationManager: CLLocationManager = CLLocationManager()
    var isMovedMylocation: Bool = false
    var comeInFromPush: Bool    = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stampViewHide()
        self.beaconSetting()
        self.webViewLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stampViewHide() {
        self.stampButton.isHidden = true
        self.stampButtonHeightConstraint.constant = 0
        self.stampButton.setTitle("스탬프요청", for: .normal)
    }
    
    func stampViewShow() {
        self.stampButtonHeightConstraint.constant = 50
        self.stampButton.isHidden = false
        self.stampButton.setTitle("스탬프요청", for: .normal)
    }
    
    @IBAction func pressedStampButton(_ sender: Any) {
        self.stampButton.setTitle("중지", for: .normal)
        let viewCont: StampViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StampView") as! StampViewController
        viewCont.delegate = self
        
        viewCont.providesPresentationContextTransitionStyle = true
        viewCont.definesPresentationContext = true
        viewCont.modalPresentationStyle = .overCurrentContext
        self.present(viewCont, animated: true)
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
    
    func updateLocation(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.497912, longitude: 127.027574)) {
        
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
            self.webView.reload()
        }
    }
    
    func sendToLocalNotification(_ notiTitle: String, notiBody: String, userInfo: [String:String] = ["":""]) {
        debugPrint("sendToLocalNotification : \(notiBody)")
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title       = notiTitle
            content.body        = notiBody
            content.userInfo   = userInfo
            content.sound       = UNNotificationSound.default()
            
            let request = UNNotificationRequest.init(identifier: "beacon", content: content, trigger: nil)
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
        } else {
            let notification = UILocalNotification()
            notification.alertTitle = notiTitle
            notification.alertBody  = notiBody
            notification.userInfo   = userInfo
            notification.soundName  = UILocalNotificationDefaultSoundName
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
}

extension WebViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (self.isMovedMylocation == false) {
            let userLocation:CLLocation = locations[0] as CLLocation
            manager.stopUpdatingLocation()
            self.updateLocation(coordinate: userLocation.coordinate)
            print("user latitude = \(userLocation.coordinate.latitude)")
            print("user longitude = \(userLocation.coordinate.longitude)")
            self.isMovedMylocation = true
        }        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        // MARK: 위치 검색 실패시 강남역 디폴트 세팅
        self.updateLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        debugPrint("didStartMonitoringFor")
        self.locationManager.requestState(for: self.myBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugPrint("didEnterRegion")
        if (CLLocationManager.isRangingAvailable()) {
            self.sendToLocalNotification("파파스탬프", notiBody: "쿠폰 적립을 쉽고 간편하게~!!")
        }
        
        
        let beacon = region as! CLBeaconRegion
        debugPrint(beacon)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugPrint("didExitRegion")
        self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        debugPrint("didDetermineState")
        if (state == .inside) {
            if (CLLocationManager.isRangingAvailable()) {
                self.sendToLocalNotification("파파스탬프", notiBody: "쿠폰 적립을 쉽고 간편하게~!!")
            }
        } else if (state == .outside) {
            self.locationManager.stopRangingBeacons(in: self.myBeaconRegion)
        } else {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        debugPrint("didRangeBeacons")
        guard beacons.count > 0 else {
            return
        }
        
        // MARK: 로그인이 안되어 있으면 비콘 신호를 무시한다.
        guard Auth.auth().currentUser?.uid.isEmpty == false else {
            return
        }
        
        let nearestBeacon = beacons.first!
        
        // MARK:
        if (self.comeInFromPush == true) {
            self.getShopBeacon(beacon: nearestBeacon)
            self.comeInFromPush = false
        }
        
        // MARK: 비콘 <-> 아이폰 거리
        debugPrint("거리 \(nearestBeacon.accuracy)")
        debugPrint("RSSI \(nearestBeacon.rssi)")
        
        //        let nearestBeacon = beacons.first!
        
        //
        //        var userInfo = [String:String]()
        //        userInfo["minor"]   = nearestBeacon.minor.stringValue
        //        userInfo["major"]   = nearestBeacon.major.stringValue
        //
        //
        //        if (UIApplication.shared.applicationState != .active &&
        //            Defaults[.isSentBeaconPush] == true) {
        //
        //        } else {
        //            self.sendToLocalNotification("파파스탬프", notiBody: "쿠폰 적립을 쉽고 간편하게~!!", userInfo: userInfo)
        //            Defaults[.isSentBeaconPush] = false
        //        }
    }
    
    func startRangingBeacon(){
        self.locationManager.startRangingBeacons(in: self.myBeaconRegion)
    }
    
    
    func getShopBeacon(beacon: CLBeacon){
        /*
         https://whereareevent.com/shop/v1.0/shopBeacon (GET)
         Parameter : ~/shopBeacon/:major/:minor
         Ex) https://whereareevent.com/shop/v1.0/shopBeacon/1000/100 호출 시 shopId(SB-SHOP-00001) 전달
         푸쉬 클릭 시전달된 shopId 와 login에서 생성된 uid를 가지고 웹뷰 페이지 호출(https://whereareevent.com/shop/v1.0/shopInfo/SB-SHOP-00001/9c4e059cb007a6d5065017d8f07133cd)
         */
        
        
        let minor   = beacon.minor.stringValue
        let major   = beacon.major.stringValue
        
        let urlStr = "https://whereareevent.com/shop/v1.0/shopBeacon/\(major)/\(minor)"
        debugPrint(urlStr)
        
        SVProgressHUD.show()
        Alamofire.request(urlStr, method: .get).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                debugPrint("shopBeacon \(json["shopId"])")
                
                /*
                 {
                 "shopId" : "SB-SHOP-00001"
                 }
                 */
                self.stampViewShow()
                self.webViewLoad(shopInfo: json["shopId"].stringValue)
                
            case .failure(let error):
                EZAlertController.alert("", message: error.localizedDescription)
            }
        }
    }
}

extension WebViewController: StampViewControllerDelegate {
    func dismissController(cont: StampViewController) {
        cont.dismiss(animated: true)
        self.stampViewShow()
    }
}
