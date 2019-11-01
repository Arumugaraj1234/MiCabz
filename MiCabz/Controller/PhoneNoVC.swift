//
//  PhoneNoVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-21.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class PhoneNoVC: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var phoneErrorLbl: UILabel!
    @IBOutlet weak var phoneTF: SignInTF!
    @IBOutlet weak var goBtn: UIButton!
    
    
    var gglUserId: String?
    var gglUserName: String?
    var ggluserEmail: String?
    var gglProfileImage: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        phoneTF.delegate = self
        phoneTF.tag = 0
        setupView()
    }
    
    
    func setupView() {
        goBtn.layer.cornerRadius = goBtn.frame.height / 2
        phoneTF.attributedPlaceholder = NSAttributedString(string: "phone no", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        hideKeyboardWhenTappedAround()
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBtnPressed(_ sender: Any) {
        if phoneTF.text != "" {
            if phoneErrorLbl.text == "" {
                if AuthService.instance.loggedInThrough == 2 {
                    let addUser = FBUserDataDB.create()
                    print("Added user id is: ", addUser.created_id)
                    addUser.userId = Int(AuthService.instance.fbuserId)!
                    addUser.email = AuthService.instance.fbEmail
                    addUser.name = AuthService.instance.fbName
                    addUser.phoneNo = phoneTF.text!
                    addUser.photoUrl = AuthService.instance.fbPicUrl
                    
                    try! uiRealm.write {
                        uiRealm.add(addUser)
                    }
                    
                    AuthService.instance.fbuserId = ""
                    AuthService.instance.fbEmail = ""
                    AuthService.instance.fbName = ""
                    AuthService.instance.fbPicUrl = ""
                    NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                    performSegue(withIdentifier: UNWIND_FROM_PHONEVC, sender: nil)
                } else if AuthService.instance.loggedInThrough == 3 {
                    
                    let addUser = GglUserDataDB.create()
                    print("Added user id is: ", addUser.created_id)
                    addUser.userId = self.gglUserId!
                    addUser.name = self.gglUserName!
                    addUser.phoneNo = self.phoneTF.text!
                    addUser.email = self.ggluserEmail!
                    addUser.photoUrl = self.gglProfileImage!
                    
                    try! uiRealm.write {
                        uiRealm.add(addUser)
                    }
                    AuthService.instance.isLoggedIn = true
                    AuthService.instance.userEmail = self.ggluserEmail!
                    NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                    performSegue(withIdentifier: UNWIND_FROM_PHONEVC, sender: nil)
                }
                }

        } else {
            phoneErrorLbl.text = "Phone no to be filled"
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            if textField.text == "" {
                phoneErrorLbl.text = "Phone no to be filled"
            } else {
                if (textField.text?.count)! < 10 && (textField.text?.count) != 0 {
                    phoneErrorLbl.text = "This phone number is invalid"
                } else {
                    phoneErrorLbl.text = ""
                }
            }
        }
    }
    
}
