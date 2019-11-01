//
//  Constant.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-06.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ Success: Bool) -> ()
typealias Completionhandler = (_ Status: Int) -> ()

//URL Constant

let GOOGLE_URL_FOR_GEOCODING =  "https://maps.googleapis.com/maps/api/geocode/json?"
let GOOGLE_URL_FOR_DIRECTIONS = "https://maps.googleapis.com/maps/api/directions/json?"
let GOOGLE_URL_FOR_ADDRESS = "https://maps.googleapis.com/maps/api/geocode/json?"

let BASE_URL = "http://mi.mypsx.net:92/MiCabz/WebService/RiderServices.asmx/"
let URL_TO_GET_NEAREST_CARS = "\(BASE_URL)GetNearestCar"
let URL_TO_GET_CAR_TYPES = "\(BASE_URL)/GetCarTypes"
let URL_TO_CHECK_CAR_AVAILABLITY = "\(BASE_URL)/CheckingCar"
let URL_TO_GET_MYCAR = "\(BASE_URL)/GetMyCar"
let URL_TEST_DRIVER_CONFIRM = "\(BASE_URL)/TestUpdate"
let URL_TO_REGISTER_USER = "\(BASE_URL)Register"
let URL_TO_LOGIN = "\(BASE_URL)LogIn"
let URL_TO_TRACK_DRIVER = "\(BASE_URL)TrackDriver"
let URL_TO_GET_FAVOURITES = "\(BASE_URL)GetFavLocations"
let URL_TO_CANCEL_RIDE = "\(BASE_URL)CancelRides"
let URL_TO_GET_PROFILE = "\(BASE_URL)Profile"
let URL_TO_GET_REASONS_FOR_CANCELRIDE = "\(BASE_URL)ReasonforCancelList"
let URL_TO_REJECT_RIDE = "\(BASE_URL)RejectRides"
let URL_TO_FORGET_PASSWORD = "\(BASE_URL)ForGotPassword"
let URL_TO_EDIT_PROFILE =  "\(BASE_URL)EditProfile"
let URL_TO_GET_RIDE_HISTORY = "\(BASE_URL)GetRideDetails"
let URL_TO_CHANGE_PASSWORD = "\(BASE_URL)ChangePassword"
let URL_TO_UPLOAD_PROFILE_PIC = "http://mi.mypsx.net:92/Micabz/Website/WebService.asmx/UploadProfile"

//HEADERS
let HEADER = [
    "Content-Type": "application/x-www-form-urlencoded"
]

//Profile link
let PROFILE_PREFIX_LINK = "http://mi.mypsx.net:92/MiCabz/Website/Assets/Rider/"

//User Defaults
let LOGGED_IN_KEY = "loggedIn"
let USER_EMAIL_KEY = "userEmail"
let USER_LOGGED_THROUGH_KEY = "loggedInThrough"
let USER_ID_KEY = "userId"

//Segues

let TO_LOGINVC_SEGUE = "toLoginVCSegue"
let TO_REGISTER_VC = "toRegisterVC"
let UNWIND_FROM_REGISTER = "fromRegisterToHomeVC"
let UNWIND_FROM_PHONEVC = "unwiindFromPhoneVC"
let TO_PHONE_VC = "toPhoneVC"
let TO_TRACK_DRIVER_VC = "toTrackDriverVC"
let TO_RIDE_DETAILS_VC = "toRideDetailsVc"
let TO_CHANGE_PASSWORD = "toChangePassword"

// Notification Constants
let NOTIF_USER_DATA_DID_CHANGE = Notification.Name("notifUserDataChanged")
let NOTIF_USER_LOGIN_FROM_HOME = Notification.Name("notifUserLoggedInFromHome")
let NOTIF_BACK_FROM_TRACK_DRIVER = Notification.Name("backFromTrackDriver")
let NOTIF_PASSWORD_CHANGED = Notification.Name("passwordChanged")

//Images

let DESELECTED_CIRCLE = UIImage(named: "circleEmpty")
let SELECTED_CIRCLE = UIImage(named: "circleSelected")

//1080583119736-qunmvek7hrrqpon3rjeroao3occn68hl.apps.googleusercontent.com
