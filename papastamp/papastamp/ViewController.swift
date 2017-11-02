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

    let aesKey: Array<UInt8> = "Glu0r6o0GzBZIe0Qsrh2FA==".bytes.md5()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.aestest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func aestest() {
        
        if let aes = try? AES(key: aesKey, blockMode: .ECB, padding: .pkcs5) {
            let encrypted = try? aes.encrypt(Array("08201026181715".utf8))
            debugPrint(encrypted!.toHexString())
            // 9c4e059cb007a6d5065017d8f07133cd
        }
    }
    
}

