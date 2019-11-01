//
//  HamburgerViewController.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-17.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class HamburgerViewController: UIViewController, ProfileEditDelegate {
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var yourTripsBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var favouritesBtn: UIButton!
    @IBOutlet weak var profileImg: RoundedImage!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        NotificationCenter.default.addObserver(self, selector: #selector(HamburgerViewController.userDataDidChanged), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HamburgerViewController.userDataDidChanged), name: NOTIF_USER_LOGIN_FROM_HOME, object: nil)
    }

    func setUpView() {
        if AuthService.instance.isLoggedIn {
            signInBtn.setTitle("SIGNOUT", for: .normal)
            yourTripsBtn.isHidden = false
            profileBtn.isHidden = false
            //favouritesBtn.isHidden = false
            setUserDetails()
            profileImg.isHidden = false
            userNameLbl.isHidden = false
        } else {
            signInBtn.setTitle("SIGNIN / SIGNUP", for: .normal)
            yourTripsBtn.isHidden = true
            profileBtn.isHidden = true
            //favouritesBtn.isHidden = true
            profileImg.isHidden = true
            userNameLbl.isHidden = true
        }
    }
    
    
    func setUserDetails() {
        if AuthService.instance.loggedInThrough == 1 {
            let order = uiRealm.objects(UserDetailsDB.self).filter("email == '\(AuthService.instance.userEmail)'")
            for item in order {
                let firstName = item.firstName
                let lastName = item.lastName
                let profileLink = item.profileLink
                userNameLbl.text = firstName + " " + lastName
                profileImg.downloadedFrom(link: profileLink)
            }

        } else if AuthService.instance.loggedInThrough == 2 {
            let order = uiRealm.objects(FBUserDataDB.self).filter("email == '\(AuthService.instance.userEmail)'")
            for item in order {
                let name = item.name
                userNameLbl.text = name
                let photoString = item.photoUrl
                let photoUrl = URL(string: photoString)
                profileImg.downloadedFrom(url: photoUrl!)
            }
            
        } else if AuthService.instance.loggedInThrough == 3 {
            let order = uiRealm.objects(GglUserDataDB.self).filter("email == '\(AuthService.instance.userEmail)'")
            for item in order {
                let name = item.name
                userNameLbl.text = name
                let photoString = item.photoUrl
                let photoUrl = URL(string: photoString)
                profileImg.downloadedFrom(url: photoUrl!)
            }
            
        }
    }
    
    func profileEdited() {
        setUpView()
    }
    
    @objc func userDataDidChanged() {
        setUpView()
    }
    
    @IBAction func profileVCSelected(_ sender: Any) {
        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = main.instantiateViewController(withIdentifier: "profileVC") as! ProfileVC
        profileVC.profileEditDelegate = self
        present(profileVC, animated: true, completion: nil)
    }
    
    @IBAction func historyVCSelected(_ sender: Any) {
        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let historyVc = main.instantiateViewController(withIdentifier: "rideHistoryVC") as! RideHistoryVC
        present(historyVc, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn == true {
            if AuthService.instance.loggedInThrough == 1 {
                AuthService.instance.logoutuser()
            } else if AuthService.instance.loggedInThrough == 2 {
                let manager = FBSDKLoginManager()
                manager.logOut()
                AuthService.instance.logoutuser()
            } else if AuthService.instance.loggedInThrough == 3 {
                GIDSignIn.sharedInstance().signOut()
                AuthService.instance.logoutuser()
            }
        } else {
            AuthService.instance.isUserLoggedInFromHomeVc = true
            let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = main.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
            present(loginVC, animated: true, completion: nil)
        }

       
    }
    

}
