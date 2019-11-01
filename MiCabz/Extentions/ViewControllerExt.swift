//
//  ViewControllerExt.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-13.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func shouldPresentLoadingViewWithText(_ show : Bool, _ title: String) {
        var fadedView: UIView?
        
        if show == true {
            fadedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            fadedView?.backgroundColor = UIColor.black
            fadedView?.alpha = 0.0
            fadedView?.tag = 99
            
            var activityIndicator = UIActivityIndicatorView()
            var strLabel = UILabel()
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            
            effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()
            
            effectView.contentView.addSubview(activityIndicator)
            effectView.contentView.addSubview(strLabel)
            
            
            view.addSubview(fadedView!)
            fadedView?.addSubview(effectView)
            fadedView?.fadeTo(alphaValue: 0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 99 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0.0
                    }, completion: { (finished) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func alertViewToShow(alertTitle: String, alertMsg: String, alertStyle:UIAlertControllerStyle, btnTitle: String, btnStyle: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?, completion:(() -> Void)? ) {
        let alert:UIAlertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: alertStyle)
        let done:UIAlertAction = UIAlertAction(title: btnTitle, style: btnStyle, handler: handler)
        alert.addAction(done)
        self.present(alert, animated: true, completion: completion)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
