//
//  ChangePassVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-13.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class ChangePassVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var oldPassTF: SignInTF!
    @IBOutlet weak var newPassTF: SignInTF!
    @IBOutlet weak var confirmPassTF: SignInTF!
    @IBOutlet weak var oldPassErrorLbl: UILabel!
    @IBOutlet weak var newPassErrorLbl: UILabel!
    @IBOutlet weak var confPassErrorLbl: UILabel!
    @IBOutlet weak var changePassBtn: UIButton!
    
    var delegate: ChangePassDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        oldPassTF.delegate = self
        newPassTF.delegate = self
        confirmPassTF.delegate = self
        oldPassTF.tag = 0
        newPassTF.tag = 1
        confirmPassTF.tag = 2
        
    }
    
    func setupView() {
        changePassBtn.layer.cornerRadius = changePassBtn.frame.height / 2
        oldPassTF.attributedPlaceholder = NSAttributedString(string: "Old Password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        newPassTF.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        confirmPassTF.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePassPressed(_ sender: Any) {
        shouldPresentLoadingViewWithText(true, "Changing..")
        let textEvaluationStatus = evaluateTextField()
        let errorLblEvaluvateStatus = evaluvateErrorLbl()
        if textEvaluationStatus {
            if errorLblEvaluvateStatus {
                AuthService.instance.changePassword(riderId: AuthService.instance.userId, currentPass: oldPassTF.text!, newPass: newPassTF.text!, completion: { (status) in
                    if status == 1 {
                        self.shouldPresentLoadingViewWithText(false, "")
                        let alert:UIAlertController = UIAlertController(title: "Success", message: "Successfully changed the password", preferredStyle: .alert)
                        let done: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
                        { _ in
                            AuthService.instance.logoutuser()
                            NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                            self.dismiss(animated: true, completion: nil)
                            self.delegate?.changePass()
                        }
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.shouldPresentLoadingViewWithText(false, "")
                        self.alertViewToShow(alertTitle: "Error", alertMsg: "Error in change password. Try again later", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                    }
                })
            }   
        }
    }
    
    func evaluateTextField() -> Bool {
        
        if oldPassTF.text != "" && newPassTF.text != "" && confirmPassTF.text != "" {
            return true
        } else if oldPassTF.text == "" {
            oldPassErrorLbl.text = "Current password field is empty"
            return false
        } else if newPassTF.text == "" {
            newPassErrorLbl.text = "New password field is empty"
            return false
        } else if confirmPassTF.text == "" {
            confPassErrorLbl.text = "Confirm password is empty"
            return false
        } else {
            return false
        }
    }
    
    func evaluvateErrorLbl() -> Bool {
        if oldPassErrorLbl.text == "" && newPassErrorLbl.text == "" && confPassErrorLbl.text == "" {
            return true
        } else {
            return false
        }
    }
    

}

extension ChangePassVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPassTF {
            oldPassTF.resignFirstResponder()
            newPassTF.becomeFirstResponder()
        } else if textField == newPassTF {
            newPassTF.resignFirstResponder()
            confirmPassTF.becomeFirstResponder()
        } else if textField == confirmPassTF {
            confirmPassTF.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            if textField.text != "" {
                oldPassErrorLbl.text = ""
            } else {
                oldPassErrorLbl.text = "Current password field is empty"
            }
        }
        
        if textField.tag == 1 {
            if textField.text != "" {
                if ((textField.text?.count)! < 6) {
                    newPassErrorLbl.text = "Password must contain 6 charactors"
                } else {
                    newPassErrorLbl.text = ""
                }
            } else {
                newPassErrorLbl.text = "New password field is empty"
            }
        }
        
        if textField.tag == 2 {
            if textField.text != "" {
                if textField.text != newPassTF.text {
                    confPassErrorLbl.text = "Password not matched"
                } else {
                    confPassErrorLbl.text = ""
                }
            } else {
                confPassErrorLbl.text = "Confirm password is empty"
            }
        }
    }
    
}
