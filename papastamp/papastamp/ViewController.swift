//
//  ViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 1..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import CryptoSwift

class ViewController: UIViewController {

    var aseKey: String = "Glu0r6o0GzBZIe0Qsrh2FA=="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.aestest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func aestest() {
        /*
         핸드폰 번호(pid)는 AES 알고리즘 (AES/ECB/PKCS5Padding) 사용하여 변경(uid)
         Key 값 (Glu0r6o0GzBZIe0Qsrh2FA==)
         Ex) 08201026181715  ==➔  9c4e059cb007a6d5065017d8f07133cd
         */

        let aes = try! AES(key: aseKey, iv: "08201026181715", padding: .pkcs5)
        
        debugPrint()

    }
    
}

