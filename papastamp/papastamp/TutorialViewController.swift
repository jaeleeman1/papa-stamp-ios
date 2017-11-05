//
//  TutorialViewController.swift
//  papastamp
//
//  Created by 김대현 on 2017. 11. 4..
//  Copyright © 2017년 김대현. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class TutorialViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        debugPrint(Auth.auth().currentUser?.uid)
        if (Auth.auth().currentUser?.uid == nil) {
            appDelegate.moveMainViewController()
        } else {
            appDelegate.moveWebViewController()
        }

    }
}

extension TutorialViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewMoveAnimation()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewMoveAnimation()
    }
    
    func scrollViewMoveAnimation() {
        let pageNumber = round(self.scrollView.contentOffset.x / self.scrollView.frame.size.width)
        self.pageControl.currentPage = Int(pageNumber)
        
        UIView.animate(withDuration: 0.5) {
            if (pageNumber == 0) {
                self.closeButton.titleLabel?.text = "건너뛰기"
            } else if (pageNumber == 1) {
                self.closeButton.titleLabel?.text = "확인완료"
            }
            
            self.view.layoutIfNeeded()
        }
    }
}
