//
//  StampViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 4..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit

protocol StampViewControllerDelegate {
    func dismissController(cont: StampViewController)
}

class StampViewController: UIViewController {

    var delegate: StampViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.dismissController(cont: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
