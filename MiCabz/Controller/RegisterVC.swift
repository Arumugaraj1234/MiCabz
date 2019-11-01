//
//  RegisterVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-18.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
    //Outlets
    
    @IBOutlet weak var firstNameTF: SignInTF!
    @IBOutlet weak var lastNameTF: SignInTF!
    @IBOutlet weak var emailTF: SignInTF!
    @IBOutlet weak var phoneTF: SignInTF!
    @IBOutlet weak var passTF: SignInTF!
    @IBOutlet weak var confirmPassTF: SignInTF!
    @IBOutlet weak var firstNameErrorLbl: UILabel!
    @IBOutlet weak var lastNameErrorLbl: UILabel!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var phoneErrorLbl: UILabel!
    @IBOutlet weak var passErrorLbl: UILabel!
    @IBOutlet weak var conPassErrorLbl: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet var homeView: UIView!
    @IBOutlet weak var registerBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        phoneTF.delegate = self
        passTF.delegate = self
        confirmPassTF.delegate = self
        firstNameTF.tag = 0
        lastNameTF.tag = 1
        emailTF.tag = 2
        phoneTF.tag = 3
        passTF.tag = 4
        confirmPassTF.tag = 5
        hideKeyboardWhenTappedAround()
        setupView()
    }
    
    func setupView() {
        registerBtn.layer.cornerRadius = registerBtn.frame.height / 2
        firstNameTF.attributedPlaceholder = NSAttributedString(string: "first name", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        lastNameTF.attributedPlaceholder = NSAttributedString(string: "last name", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        emailTF.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        phoneTF.attributedPlaceholder = NSAttributedString(string: "phone no", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        passTF.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        confirmPassTF.attributedPlaceholder = NSAttributedString(string: "confirm password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerBtnWasPressed(_ sender: Any) {
        registerBtn.isEnabled = false
        shouldPresentLoadingViewWithText(true, "Registering..")
        closetextField()
        isTextFiledIsEmpty { (success) in
            if success {
                self.isErrorLblEmpty(completion: { (success) in
                    if success {
                        AuthService.instance.checkInternet(completion: { (success) in
                            if success {
                                AuthService.instance.registeringUser(firstName: self.firstNameTF.text!, lastName: self.lastNameTF.text!, email: self.emailTF.text!, phone: self.phoneTF.text!, password: self.passTF.text!, completion: { (success) in
                                    if success {
                                        self.registerBtn.isEnabled = true
                                        self.shouldPresentLoadingViewWithText(false, "")
                                        let alert:UIAlertController = UIAlertController(title: "SUCCESS", message: "You are successfully Registered with us. With this you are acknowledging with our policies.", preferredStyle: .alert)
                                        let done: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
                                        { _ in
                                            NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                                            self.performSegue(withIdentifier: UNWIND_FROM_REGISTER, sender: nil)
                                        }
                                        alert.addAction(done)
                                        self.present(alert, animated: true, completion: nil)
                                    } else {
                                        self.registerBtn.isEnabled = true
                                        self.shouldPresentLoadingViewWithText(false, "")
                                        self.alertViewToShow(alertTitle: "Oops!", alertMsg: "Email or Phone already exists", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                                    }
                                })
                            } else {
                                self.registerBtn.isEnabled = true
                                self.shouldPresentLoadingViewWithText(false, "")
                                self.alertViewToShow(alertTitle: "No Network", alertMsg: "You seems to be offline. Please try again later", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                            }
                        })
                    } else {
                        self.registerBtn.isEnabled = true
                        self.shouldPresentLoadingViewWithText(false, "")
                        self.alertViewToShow(alertTitle: "Invalid Details", alertMsg: "Some given details are invalid. Please provide valid details", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                    }
                })
            } else {
                self.registerBtn.isEnabled = true
                self.shouldPresentLoadingViewWithText(false, "")
                self.alertViewToShow(alertTitle: "Some fields missing", alertMsg: "Please enter all required fields", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
            }
        }
    }
    
    func closetextField() {
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        phoneTF.resignFirstResponder()
        passTF.resignFirstResponder()
        confirmPassTF.resignFirstResponder()
    }
    
    
    func isTextFiledIsEmpty(completion: @escaping CompletionHandler) {
        if firstNameTF.text == "" {
            completion(false)
            firstNameErrorLbl.text = "First name to be filled"
        }
        if lastNameTF.text == "" {
            completion(false)
            lastNameErrorLbl.text = "Last name to be filled"
        }
        if emailTF.text == "" {
            completion(false)
            emailErrorLbl.text = "Email to be filled"
        }
        if phoneTF.text == "" {
            completion(false)
            phoneErrorLbl.text = "Phone no to be filled"
        }
        if passTF.text == "" {
            completion(false)
            passErrorLbl.text = "Password is empty"
        }
        if confirmPassTF.text == "" {
            completion(false)
            conPassErrorLbl.text = "Confirm password empty"
        }
        
        if firstNameTF.text != "" && lastNameTF.text != "" && emailTF.text != "" && phoneTF.text != "" && passTF.text != "" && confirmPassTF.text != "" {
            completion(true)
        }
    }
    
    func isErrorLblEmpty(completion: @escaping CompletionHandler){
        if firstNameErrorLbl.text == "" && lastNameErrorLbl.text == "" && emailErrorLbl.text == "" && phoneErrorLbl.text == "" && passErrorLbl.text == "" && conPassErrorLbl.text == "" {
            completion(true)
        } else {
            completion(false)
        }
    }
    

}

extension RegisterVC: UITextFieldDelegate {
    
    func viewShouldMove(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.2, animations: {
                self.registerBottomConstraint.constant = 250
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.registerBottomConstraint.constant = 100
            })
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 4 || textField.tag == 5 {
            viewShouldMove(show: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 4 || textField.tag == 5 {
            viewShouldMove(show: false)
        }
        if textField.tag == 0 {
            if textField.text == "" {
                firstNameErrorLbl.text = "First name to be filled"
            } else {
                firstNameErrorLbl.text = ""
            }
        }
        if textField.tag == 1 {
            if textField.text == "" {
                lastNameErrorLbl.text = "Last name to be filled"
            } else {
                lastNameErrorLbl.text = ""
            }
        }
        if textField.tag == 2 {
            if textField.text == "" {
                emailErrorLbl.text = "Email to be filled"
            } else {
                if !isValidEmail(testStr: textField.text!) {
                    emailErrorLbl.text = "Invalid email"
                } else {
                    emailErrorLbl.text = ""
                }
            }
        }
        if textField.tag == 3 {
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
        
        if textField.tag == 4 {
            if textField.text == "" {
                passErrorLbl.text = "Password is empty"
            } else {
                if (textField.text?.count)! < 6 {
                    passErrorLbl.text = "Password must contain min 6 charactors"
                } else {
                    passErrorLbl.text = ""
                }
            }
        }
        if textField.tag == 5 {
            if textField.text == "" {
                conPassErrorLbl.text = "Confirm password empty"
            } else {
                if textField.text != passTF.text {
                    conPassErrorLbl.text = "Password Not Matched"
                } else {
                    conPassErrorLbl.text = ""
                }
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF {
            textField.resignFirstResponder()
            lastNameTF.becomeFirstResponder()
        } else if textField == lastNameTF {
            textField.resignFirstResponder()
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
            textField.resignFirstResponder()
            phoneTF.becomeFirstResponder()
        } else if textField == phoneTF {
            textField.resignFirstResponder()
            passTF.becomeFirstResponder()
        } else if textField == passTF {
            textField.resignFirstResponder()
            confirmPassTF.becomeFirstResponder()
        }else if textField == confirmPassTF {
            confirmPassTF.resignFirstResponder()
        }
        return true
    }
}
