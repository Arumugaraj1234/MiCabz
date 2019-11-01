//
//  LoginVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-18.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class LoginVC: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate {

    //Outlets
    @IBOutlet weak var emailTF: SignInTF!
    @IBOutlet weak var passTF: SignInTF!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var passErrorLbl: UILabel!
    @IBOutlet var homeView: UIView!
    @IBOutlet weak var googleSignInBtn: GIDSignInButton!
    @IBOutlet weak var forgetPassView: UIView!
    @IBOutlet weak var forgetErrorLbl: UILabel!
    @IBOutlet weak var forgetEmailTF: SignInTF!
    @IBOutlet weak var submitBtn: UIButton!
    
    var gglUserId = ""
    var gglUserName = ""
    var ggluserEmail = ""
    var gglProfileImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.delegate = self
        passTF.delegate = self
        forgetEmailTF.delegate = self
        emailTF.tag = 0
        passTF.tag = 1
        forgetEmailTF.tag = 2
        setupView()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "1080583119736-qunmvek7hrrqpon3rjeroao3occn68hl.apps.googleusercontent.com"

//        if let accessToken = FBSDKAccessToken.current() {
//            AuthService.instance.getFBUserData(completion: { (success) in
//                if success {
//                    NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    self.alertViewToShow(alertTitle: "Oops", alertMsg: "Something went wrong. Please try again later", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
//                }
//            })
//        }
    }
    
    func setupView() {
        loginBtn.layer.cornerRadius = loginBtn.frame.height / 2

        passTF.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        forgetEmailTF.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        submitBtn.layer.cornerRadius = submitBtn.frame.height / 2
        
        forgetPassView.isHidden = true
        //hideKeyboardWhenTappedAround()
    }
    
    @IBAction func loginThroughFBClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                AuthService.instance.getFBUserData(completion: { (success) in
                    if success {
                        self.performSegue(withIdentifier: TO_PHONE_VC, sender: self)
                    } else {
                        self.alertViewToShow(alertTitle: "Oops", alertMsg: "Something went wrong. Please try agaib later", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func forgetScreenBackPressed(_ sender: Any) {
        animateForgetPassView(shouldShow: false)
    }
    
    
    @IBAction func forgetSubmitBtnPressed(_ sender: Any) {
        forgetEmailTF.resignFirstResponder()
        shouldPresentLoadingViewWithText(true, "Loading")
        if forgetEmailTF.text != "" {
            if forgetErrorLbl.text == "" {
                AuthService.instance.forgetPassword(userEmail: forgetEmailTF.text!, completion: { (status) in
                    if status == 1 {
                        let alert:UIAlertController = UIAlertController(title: "Success", message: "Link to change password sent to your mail id", preferredStyle: .alert)
                        let done: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
                        { _ in
                            self.shouldPresentLoadingViewWithText(false, "")
                            self.animateForgetPassView(shouldShow: false)
                        }
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.shouldPresentLoadingViewWithText(false, "")
                        print("Something went wrong in forget password")
                        
                    }
                })
            }
        }
    }
    
    @IBAction func forgetPassPressed(_ sender: Any) {
        animateForgetPassView(shouldShow: true)
    }
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: TO_REGISTER_VC, sender: self)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        shouldPresentLoadingViewWithText(true, "Logging In...")
        isTextFiledIsEmpty { (success) in
            if success {
                self.isErrorLblEmpty(completion: { (success) in
                    if success {
                        AuthService.instance.loggingInUser(userEmail: self.emailTF.text!, password: self.passTF.text!, completion: { (success) in
                            if success {
                                print(AuthService.instance.userId)

                                AuthService.instance.getProfileDetails(riderId: AuthService.instance.userId, completion: { (status) in
                                    if status == 1 {
                                        print("Successfully got profile details")
                                    } else {
                                        print("Something wrong in getting profile details")
                                    }
                                })
                                if AuthService.instance.isUserLoggedInFromHomeVc {
                                    NotificationCenter.default.post(name: NOTIF_USER_LOGIN_FROM_HOME, object: nil)
                                } else {
                                    NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
                                }
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                self.shouldPresentLoadingViewWithText(false, "")
                                self.alertViewToShow(alertTitle: "Oops", alertMsg: "Invalid user email or password", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                            }
                        })
                    } else {
                        self.shouldPresentLoadingViewWithText(false, "")
                    }
                })
            } else {
                self.shouldPresentLoadingViewWithText(false, "")
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error ?? "google error")
            return
        }
        AuthService.instance.loggedInThrough = 3
        let userId = user.userID!
        let fullName = user.profile.name
        let email = user.profile.email
        let userImage = user.profile.imageURL(withDimension: 200)

        print(userId)
        print(fullName)
        print(email)
        self.gglUserId = userId
        self.gglUserName = fullName!
        self.ggluserEmail = email!
        self.gglProfileImage = "\(userImage!)"
        
        self.performSegue(withIdentifier: TO_PHONE_VC, sender: self)
        
    }
    
    
    func isTextFiledIsEmpty(completion: @escaping CompletionHandler) {

        if emailTF.text == "" {
            completion(false)
            emailErrorLbl.text = "Email to be filled"
        }
        if passTF.text == "" {
            completion(false)
            passErrorLbl.text = "Password is empty"
        }
        
        if emailTF.text != "" && passTF.text != "" {
            completion(true)
        }
    }
    
    func isErrorLblEmpty(completion: @escaping CompletionHandler){
        if emailErrorLbl.text == "" &&  passErrorLbl.text == ""  {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_PHONE_VC {
            if AuthService.instance.loggedInThrough == 3 {
                let phoneVC = segue.destination as! PhoneNoVC
                
                phoneVC.gglUserId = self.gglUserId
                phoneVC.gglUserName = self.gglUserName
                phoneVC.ggluserEmail = self.ggluserEmail
                phoneVC.gglProfileImage = self.gglProfileImage
            }
        }
    }
    
    func animateForgetPassView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.forgetPassView.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.forgetPassView.isHidden = true
            })
        }
    }
    

}


extension LoginVC: UITextFieldDelegate {
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
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
        
        if textField.tag == 1 {
            if textField.text == "" {
                passErrorLbl.text = "Password is empty"
            } else {
                passErrorLbl.text = ""
            }
        }
        
        if textField.tag == 2 {
            if textField.text == "" {
                forgetErrorLbl.text = "Email to be filled"
            } else {
                if !isValidEmail(testStr: textField.text!) {
                    forgetErrorLbl.text = "Invalid email"
                } else {
                    forgetErrorLbl.text = ""
                }
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}
