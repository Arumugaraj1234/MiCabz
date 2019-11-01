//
//  ProfileVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-17.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, ChangePassDelegate {


    //Outlets
    @IBOutlet weak var profileImg: RoundedImage!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userPhoneNoLbl: UILabel!
    @IBOutlet weak var userMaillbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Outlets of Edit Profile View
    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var firstNameTF: SignInTF!
    @IBOutlet weak var firstNameErrorLbl: UILabel!
    @IBOutlet weak var lastNameTF: SignInTF!
    @IBOutlet weak var lastNameErrorLbl: UILabel!
    @IBOutlet weak var phoneTF: SignInTF!
    @IBOutlet weak var phoneErrorLbl: UILabel!
    @IBOutlet weak var saveChangesBtn: UIButton!
    
    
    var profileEditDelegate: ProfileEditDelegate?
    let imagePicker = UIImagePickerController()
    //let profileImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.delegate = self
        firstNameTF.tag = 0
        lastNameTF.delegate = self
        lastNameTF.tag = 1
        phoneTF.delegate = self
        phoneTF.tag = 2
        imagePicker.delegate = self
        
        setupView()
        tableView.delegate = self
        tableView.dataSource = self
        getFavouriteAddress()
    }
    
    func setupView() {
        editProfileView.isHidden = true
        saveChangesBtn.layer.cornerRadius = saveChangesBtn.frame.height / 2
        firstNameTF.attributedPlaceholder = NSAttributedString(string: "first name", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        lastNameTF.attributedPlaceholder = NSAttributedString(string: "last name", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        phoneTF.attributedPlaceholder = NSAttributedString(string: "phone", attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4)])
        let order = uiRealm.objects(UserDetailsDB.self).filter("email == '\(AuthService.instance.userEmail)'")
        for item in order {
            let firstName = item.firstName
            let lastName = item.lastName
            let email = item.email
            let profileLink = item.profileLink
            let phone = item.phoneNo
            userNameLbl.text = "  " + firstName + " " + lastName
            profileImg.downloadedFrom(link: profileLink)
            userPhoneNoLbl.text = "  " + phone
            userMaillbl.text = "  " + email
            
            firstNameTF.text = firstName
            lastNameTF.text = lastName
            phoneTF.text = phone
        }
    }
    
    
    
    func getFavouriteAddress() {
        print("RiderId: \(AuthService.instance.userId)")
        AuthService.instance.userFavouriteAddress.removeAll()
        AuthService.instance.getFavouriteList(riderId: 1) { (status) in
            if status == 1 {
                self.tableView.reloadData()
            }
        }
    }
    
    func changePass() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileEditBtnPressed(_ sender: Any) {
        animateEditProfileView(shouldShow: true)
    }
    
    @IBAction func backFromEditProfilePressed(_ sender: Any) {
        animateEditProfileView(shouldShow: false)
    }
    
    @IBAction func profileImgEditPressed(_ sender: Any) {
        actionsToCall()
    }
    
    
    @IBAction func saveChangesPressed(_ sender: Any) {
        phoneTF.resignFirstResponder()
        print("Phone No: \(phoneTF.text!)")
        self.shouldPresentLoadingViewWithText(true, "Saving...")
        if validateTextField() == true {
            if validateErrorLabels() == true {
                AuthService.instance.editprofile(riderid: AuthService.instance.userId, firstname: firstNameTF.text!, lastname: lastNameTF.text!, email: AuthService.instance.userEmail, phone: phoneTF.text!, completion: { (status) in
                    if status == 1 {
                        self.shouldPresentLoadingViewWithText(false, "")
                        print("Successfully edited your profile")
                        let addUser = UserDetailsDB.create()
                        print("Added user id is: ", addUser.created_id)
                        addUser.userId = AuthService.instance.userId
                        addUser.email = AuthService.instance.userEmail
                        addUser.firstName = self.firstNameTF.text!
                        addUser.lastName = self.lastNameTF.text!
                        addUser.phoneNo = self.phoneTF.text!
                        try! uiRealm.write {
                            uiRealm.add(addUser)
                        }
                        self.userNameLbl.text = "   " + self.firstNameTF.text! + self.lastNameTF.text!
                        self.userPhoneNoLbl.text = "   " + self.phoneTF.text!
                        self.animateEditProfileView(shouldShow: false)
                        self.profileEditDelegate?.profileEdited()
                    } else {
                        self.shouldPresentLoadingViewWithText(false, "")
                        print("Oops, something went wrong in editing your profile")
                    }
                })
            }
        }
    }
    
    func validateTextField() -> Bool {
        if firstNameTF.text == "" {
            firstNameErrorLbl.text = "First name to be filled"
            return false
        }
        if lastNameTF.text == "" {
            lastNameErrorLbl.text = "Last name to be filled"
            return false
        }
        if phoneTF.text == "" {
            phoneErrorLbl.text = "Phone no to be filled"
            return false
        }
        if firstNameTF.text != "" && lastNameTF.text != "" && phoneTF.text != "" {
            return true
        } else {
            return false
        }
    }
    
    func validateErrorLabels() -> Bool {
        if firstNameErrorLbl.text == "" && lastNameErrorLbl.text == "" && phoneErrorLbl.text == "" {
            return true
        } else {
            return false
        }
    }
    
    func savingProfileImage(imageToSave: UIImage) {
        let testImage = UIImage(named: "test")
        let imageData: NSData = UIImageJPEGRepresentation(testImage!, 0.1) as! NSData
        let strBase64: String = imageData.base64EncodedString(options: .lineLength64Characters)
        print(strBase64)
        AuthService.instance.uploadProfile(base64Str: strBase64, riderId: "\(AuthService.instance.userId)", role: 2) { (status) in
            if status == 1 {
                print("Success")
            } else {
                print("Error in upload")
            }
        }
    }
    
    
    func animateEditProfileView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.editProfileView.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.editProfileView.isHidden = true
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let changePassVc = segue.destination as? ChangePassVC {
            changePassVc.delegate = self
        }
    }
    
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthService.instance.userFavouriteAddress.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteLocationCell", for: indexPath) as? FavouriteLocationCell {
            let favourite = AuthService.instance.userFavouriteAddress[indexPath.row]
            cell.configureCell(favourite: favourite)
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

extension ProfileVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag  == 0 || textField.tag == 1 || textField.tag == 2 {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTF {
            firstNameTF.resignFirstResponder()
            lastNameTF.becomeFirstResponder()
        } else if textField == lastNameTF {
            lastNameTF.resignFirstResponder()
            phoneTF.becomeFirstResponder()
        } else if textField == phoneTF {
            phoneTF.resignFirstResponder()
        }
        return true
    }
    
    
}

extension ProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func actionsToCall() {
        let camera = CameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImg.image = pickedImage
            savingProfileImage(imageToSave: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
