//
//  ViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 1..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import CryptoSwift
import Alamofire
import EZAlertController
import SwiftyJSON
import Firebase
import SwiftyUserDefaults
import SVProgressHUD

class LoginViewController: UIViewController {

    let aesKey: Array<UInt8> = "Glu0r6o0GzBZIe0Qsrh2FA==".bytes.md5()
    
    @IBOutlet weak var phonNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        registerForNotifications()
    }

    private func registerForNotifications() {
        let notificationName = Notification.Name.UITextFieldTextDidChange
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textDidChange),
            name: notificationName,
            object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func textDidChange() {
        if (self.passwordTextField.text! == self.passwordConfirmTextField.text!) {
            self.passwordConfirmTextField.textColor = UIColor.black
        } else {
            self.passwordConfirmTextField.textColor = UIColor.red
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getUid() -> String {
        if let aes = try? AES(key: aesKey, blockMode: .ECB, padding: .pkcs5) {
            let encrypted = try? aes.encrypt(Array(self.phonNumberTextField.text!.utf8))
            debugPrint(encrypted!.toHexString())
            return encrypted!.toHexString()
        }
        
        return ""
    }
    
    @IBAction func pressedConfirmButton(_ sender: Any) {

        guard self.phonNumberTextField.text?.isEmpty == false else {
            EZAlertController.alert("", message: "폰 번호를 입력하세요.")
            return
        }
        
        guard self.emailTextField.text?.isEmpty == false else {
            EZAlertController.alert("", message: "이메일을 입력하세요.")
            return
        }
        
        guard self.emailTextField.text?.isEmail == true else {
            EZAlertController.alert("", message: "이메일을 형식이 아닙니다.")
            return
        }
        
        guard self.passwordTextField.text?.isEmpty == false else {
            EZAlertController.alert("", message: "패스워드를 입력하세요.")
            return
        }
        
        guard self.passwordConfirmTextField.text?.isEmpty == false else {
            EZAlertController.alert("", message: "패스워드를 확인해 주세요.")
            return
        }
        
        guard self.passwordTextField.text == self.passwordConfirmTextField.text else {
            EZAlertController.alert("", message: "패스워드를 입력값이 다릅니다.")
            return
        }
        
        guard (self.passwordTextField.text?.count)! > 6  else {
            EZAlertController.alert("", message: "패스워드를 6자 이상 입력하세요.")
            return
        }

        self.userCreate()
    }

    func userCreate() {
        
        
        /*
         https://whereareevent.com/user/v1.0/userCreate (GET)
         Header (Content-Type: application/json) – key : user_id / value : uid
         */
        
        let headers = ["user_id" : self.getUid(),
                       "Content-Type" : "application/json"]
        
        debugPrint("userCreate \(self.getUid())")
        
        SVProgressHUD.show()
        Alamofire.request("https://whereareevent.com/user/v1.0/userCreate", method: .get, headers: headers).responseJSON { (response) in
            SVProgressHUD.dismiss()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.setCustomTokenToFirebase(token: json["customToken"].stringValue)

            case .failure(let error):
                EZAlertController.alert("", message: error.localizedDescription)
            }
        }
    }
    
    func setCustomTokenToFirebase(token: String) {
        guard token.isEmpty == false else {
            EZAlertController.alert("", message: "token is empty")
            return
        }
        
        Auth.auth().signIn(withCustomToken: token ) { (user, error) in
            if (error != nil) {
                EZAlertController.alert("", message: error.debugDescription)
            } else {
                self.userUpdateFirebase()
                
                // MARK: move to webView
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.moveWebViewController()
            }
        }
    }
    
    func userUpdateFirebase() {
        Auth.auth().currentUser?.updateEmail(to: self.emailTextField.text!)
        Auth.auth().currentUser?.updatePassword(to: self.passwordTextField.text!)
    }
}

//extension LoginViewController: UITextFieldDelegate {
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
////        debugPrint(self.passwordTextField.text)
////        debugPrint(self.passwordConfirmTextField.text)
////
//        let confirmText: String = "\(self.passwordConfirmTextField.text!)\(string)"
//
//        if (confirmText == self.passwordTextField.text) {
//            self.passwordConfirmTextField.textColor = UIColor.black
//        } else {
//            self.passwordConfirmTextField.textColor = UIColor.red
//        }
//
//
//        return true
//    }
//}

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

