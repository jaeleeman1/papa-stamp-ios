//
//  Test.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 6..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

func get() {

    let headers = ["user_id" : "uid",
                   "Content-Type" : "application/json"]
    
    let parameters = ["a": "a",
                      "b": "b"]
    
    Alamofire.request("https://whereareevent.com/user/v1.0/userCreate", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
        switch response.result {
        case .success(let value):
            let json = JSON(value)
            debugPrint(json.debugDescription)
        case .failure(let error):
            debugPrint(error.localizedDescription)
        }
    }
}

func post() {
    let headers = ["user_id" : "uid",
                   "Content-Type" : "application/json"]
    
    let parameters = ["a": "a",
                      "b": "b"]
    
    Alamofire.request("https://whereareevent.com/user/v1.0/userCreate", method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
        switch response.result {
        case .success(let value):
            let json = JSON(value)
            debugPrint(json.debugDescription)
        case .failure(let error):
            debugPrint(error.localizedDescription)
        }
    }
}

