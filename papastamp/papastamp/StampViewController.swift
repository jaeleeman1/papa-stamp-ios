//
//  StampViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 4..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit

class StampViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.4
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
