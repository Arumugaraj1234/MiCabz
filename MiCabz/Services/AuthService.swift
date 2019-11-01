//
//  AuthService.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-06.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire
import Reachability
import FacebookLogin
import FBSDKLoginKit

class AuthService {
    
    static let instance = AuthService()
    
    //Variables for Getting Geo Code
    var fetchedFormattedAddress: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    
    //Variables for Route map
    var selectedRoute: [String: AnyObject]!
    var overViewPolyLine: [String: AnyObject]!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!
    var originLat: Double!
    var originLon: Double!
    var destlat: Double!
    var destLon: Double!
    
    //Variables for calculated Distance & Duration
    var totalDistanceInMeters: Int = 0
    var totalDistance: String!
    var totalDurationInSeconds: Int = 0
    var totalDuration: String!
    var distanceInkiloMeters: Double = 0.0
    
    // variable to store address from current location
    var currentAddressFromCurrentCoordinates: String!
    
    //Nearby Cars
    var nearestCars = [NearestCars]()
    var carTypes = [CarType]()
    var rideId = 0
    var acceptedDriverDetails: DriverDetails!
    var driversCurrentLocationForTrack: CLLocationCoordinate2D!
    
    //Facebook variables
    var fbName = ""
    var fbEmail = ""
    var fbuserId = ""
    var fbPicUrl = ""
    
    // Variables for favourites
    
    var userFavouriteAddress = [FavouritesModel]()
    var isUserLoggedInFromHomeVc = false
    
    // Variable for Cancel reasons
    var cancelReasons = [CancelReasonModel]()
    
    //Userdefault variables
    
    let defaults = UserDefaults.standard
    var loggedInThrough: Int {
        get {
            return defaults.integer(forKey: USER_LOGGED_THROUGH_KEY)
        } set {
            defaults.set(newValue, forKey: USER_LOGGED_THROUGH_KEY)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var userEmail: String {
        get {
            return defaults.value(forKey: USER_EMAIL_KEY) as! String
        }
        set {
            defaults.set(newValue, forKey: USER_EMAIL_KEY)
        }
    }
    
    var userId: Int {
        get {
            return defaults.value(forKey: USER_ID_KEY) as! Int
        }
        set {
            defaults.set(newValue, forKey: USER_ID_KEY)
        }
    }
    
    var ridesHistory = [RideHistoryModel]()
    
    
    func checkInternet(completion: @escaping CompletionHandler) {
        DispatchQueue.main.async {
            let reachability = Reachability()!
            
            reachability.whenReachable = { reachability in
                completion(true)
            }
            reachability.whenUnreachable = { reachability in
                completion(false)
            }
            do{
                try reachability.startNotifier()
            }catch{
                print("could not start reachability notifier")
            }
        }
    }
    
    func geocodeAddress(address: String!, completion: @escaping CompletionHandler) {
        var geocodeURLString = "\(GOOGLE_URL_FOR_GEOCODING)address=\(address)&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
        geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let geocodeURL = NSURL(string: geocodeURLString)
        let request = NSMutableURLRequest(url:geocodeURL as URL!);
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil
            {
                completion(false)
                print("error=\(error!)")
                return
            }
            else {
                print("data", data!)
                do{
                    let resultJson = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
                    let status = resultJson!["status"] as! String
                    if status == "OK" {
                        let allResults = resultJson!["results"] as? [[String: AnyObject]]
                        let reqresult = allResults![0]
                        let geometry = reqresult["geometry"] as! [String: AnyObject]
                        let location = geometry["location"] as! [String: AnyObject]
                        self.fetchedAddressLatitude = location["lat"] as! Double
                        self.fetchedAddressLongitude = location["lng"] as! Double
                        self.fetchedFormattedAddress = reqresult["formatted_address"] as! String
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }
            
        }
        task.resume()
    }
    
    
    
    func getAddressFromGeoCode(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping CompletionHandler) {
        var geocodeURLString = "\(GOOGLE_URL_FOR_ADDRESS)latlng=\(latitude),\(longitude)&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
        geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let geocodeURL = NSURL(string: geocodeURLString)
        let request = NSMutableURLRequest(url:geocodeURL as URL!);
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil
            {
                completion(false)
                print("error=\(error!)")
                return
            }
            else {
                print("data", data!)
                do{
                    let resultJson = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
                    let status = resultJson!["status"] as! String
                    if status == "OK" {
                        let resultArray = resultJson!["results"] as! [[String: Any]]
                        let nearByLocation = resultArray[0]
                        self.currentAddressFromCurrentCoordinates = nearByLocation["formatted_address"] as! String
                        print(self.currentAddressFromCurrentCoordinates)
                        completion(true)
                    } else {
                        completion(false)
                    }
                    
                }
                catch{
                    completion(false)
                }
            }
            
        }
        task.resume()
    }

    
    
    func getDirections(origin: String!, destination: String!, wayPoints: [String]!, travelMode: AnyObject!, completion: @escaping CompletionHandler) {
        var directionURLString = "\(GOOGLE_URL_FOR_DIRECTIONS)origin=\(origin!)&destination=\(destination!)&mode=driving&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
        print(directionURLString)
         var reqDirecttionURL = "\(GOOGLE_URL_FOR_DIRECTIONS)origin=\(origin!)&destination=\(destination!)&mode=driving"
        if wayPoints.count > 0 {
           reqDirecttionURL += "&waypoints=optimize:true"
            for waypoint in wayPoints {
                reqDirecttionURL += "|" + waypoint
            }
           directionURLString = reqDirecttionURL + "&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
            
        }
        directionURLString = directionURLString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let directionURL = NSURL(string: directionURLString)
        let request = NSMutableURLRequest(url:directionURL as URL!);
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil
            {
                completion(false)
                print("error=\(error!)")
                return
            }
            else {
                print("data", data!)
                do{
                    let resultJson = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
                    let status = resultJson!["status"] as! String
                    if status == "OK" {
                        let result = resultJson!["routes"] as! [[String: AnyObject]]
                        self.selectedRoute = result[0]
                        self.overViewPolyLine = self.selectedRoute["overview_polyline"] as![String: AnyObject]
                        
                        let legs = self.selectedRoute["legs"] as! [[String: AnyObject]]
                        for item in legs {
                            let startCoordinateDict = item["start_location"] as! [String: AnyObject]
                            let destCoordinateDict = item["end_location"] as! [String: AnyObject]
                            self.originLat = startCoordinateDict["lat"] as! Double
                            self.originLon = startCoordinateDict["lng"] as! Double
                            self.destlat = destCoordinateDict["lat"] as! Double
                            self.destLon = destCoordinateDict["lng"] as! Double
                            self.originAddress = item["start_address"] as! String
                            self.destinationAddress = item["end_address"] as! String
                            self.originCoordinate = CLLocationCoordinate2DMake(self.originLat, self.originLat)
                            self.destinationCoordinate = CLLocationCoordinate2DMake(self.destlat, self.destLon)
                            self.calculateTotalDistanceAndDuration()
                        }
                       completion(true)
                    } else {
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }
            
        }
        task.resume()
    }
    
    func getDirectionsFromgeoCode(originLat: CLLocationDegrees!,originLon: CLLocationDegrees!, destinalat: Double!, destLon: Double!, wayPoints: [String]!, travelMode: AnyObject!, completion: @escaping CompletionHandler) {
        var directionURLString = "\(GOOGLE_URL_FOR_DIRECTIONS)origin=\(originLat!),\(originLon!)&destination=\(destinalat!),\(destLon!)&mode=driving&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
        var reqDirecttionURL = "\(GOOGLE_URL_FOR_DIRECTIONS)origin=\(originLat)&destination=\(destinalat)&mode=driving"
        if wayPoints.count > 0 {
            reqDirecttionURL += "&waypoints=optimize:true"
            for waypoint in wayPoints {
                reqDirecttionURL += "|" + waypoint
            }
            directionURLString = reqDirecttionURL + "&key=AIzaSyDUgw31MfDV88qEnxUqInF8VVElUAjqgpg"
            
        }
        directionURLString = directionURLString.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        let directionURL = NSURL(string: directionURLString)
        let request = NSMutableURLRequest(url:directionURL as URL!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil
            {
                completion(false)
                print("error=\(error!)")
                return
            }
            else {
                print("data", data!)
                do{
                    let resultJson = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String:AnyObject]
                    let status = resultJson!["status"] as! String
                    if status == "OK" {
                        let result = resultJson!["routes"] as! [[String: AnyObject]]
                        self.selectedRoute = result[0]
                        self.overViewPolyLine = self.selectedRoute["overview_polyline"] as![String: AnyObject]

                        let legs = self.selectedRoute["legs"] as! [[String: AnyObject]]
                        for item in legs {
                            let startCoordinateDict = item["start_location"] as! [String: AnyObject]
                            let destCoordinateDict = item["end_location"] as! [String: AnyObject]
                            let startLocLat = startCoordinateDict["lat"] as! Double
                            let startLocLon = startCoordinateDict["lng"] as! Double
                            let endLocLat = destCoordinateDict["lat"] as! Double
                            let endLocLon = destCoordinateDict["lng"] as! Double
                            self.originAddress = item["start_address"] as! String
                            self.destinationAddress = item["end_address"] as! String
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocLat, startLocLon)
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocLat, endLocLon)
                            self.calculateTotalDistanceAndDuration()
                        }
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }
            
        }
        task.resume()
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! [[String: AnyObject]]
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        for leg in legs {
            let distanceDict = leg["distance"] as! [String: AnyObject]
            let distanceInMeter = distanceDict["value"] as! Int
            totalDistanceInMeters = totalDistanceInMeters + distanceInMeter
            
            let durationDict = leg["duration"] as! [String: AnyObject]
            let durationInSec = durationDict["value"] as! Int
            totalDurationInSeconds = totalDurationInSeconds + durationInSec
        }
        let distanceKm = Double(totalDistanceInMeters)
        distanceInkiloMeters = Double(distanceKm / 1000.0)
        totalDistance = "Total Distance: \(distanceInkiloMeters) Km"
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainigSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days)d, \(remainingHours)h, \(remainingMins)m, \(remainigSecs)s"
    }
    
    
    func getNearestCars(latitude: CLLocationDegrees, Longitude: CLLocationDegrees, completion: @escaping CompletionHandler) {
        let body: [String: Any] = [
            "lat": latitude,
            "lon": Longitude
        ]
        
        Alamofire.request(URL_TO_GET_NEAREST_CARS, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let jsonString = response.result.value else {return}
                guard let jsonResult = self.convertToDictionary(text: jsonString) else {return}
                let status = jsonResult["status"] as! Int
                if status == 1 {
                    let reqDataString = jsonResult["data"] as! String
                    let reqDataArray = self.convertToArrayOfDictionary(text: reqDataString)
                    for item in reqDataArray! {
                        let driverId = item["DriverId"] as! Int
                        let distance = item["Distance"] as! Double
                        let latitudeString = item["Latitude"] as! String
                        let latitude = Double(latitudeString)
                        let lonString = item["Longitude"] as! String
                        let longitude = Double(lonString)
                        let nearestCar = NearestCars(driverId: driverId, distance: distance, latitude: latitude, longitude: longitude)
                        self.nearestCars.append(nearestCar)
                    }
                    print(self.nearestCars)
                    completion(true)
                } else {
                    completion(false)
                    let msg = jsonResult["msg"] as! String
                    print(msg)
                }
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
        
    }

    func getCarTypes(distance: Double, completion: @escaping CompletionHandler) {
        
        let body: [String: Any] = [
            "km": distance
        ]
        
        Alamofire.request(URL_TO_GET_CAR_TYPES, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let jsonString = response.result.value else {return}
                guard let jsonResult = self.convertToDictionary(text: jsonString) else {return}
                let status = jsonResult["status"] as! Int
                if status == 1 {
                    let reqDataString = jsonResult["data"] as! String
                    let reqDataArray = self.convertToArrayOfDictionary(text: reqDataString)
                    for item in reqDataArray! {
                        let carName = item["CarName"] as! String
                        let rideCost = item["RideCost"] as! Double
                        let carTypeInt = item["CarType"] as! Int
                        let carType = CarType(rideCost: rideCost, carType: carTypeInt, carName: carName)
                        self.carTypes.append(carType)
                    }
                     print(self.carTypes)
                    completion(true)
                } else {
                    completion(false)
                    let msg = jsonResult["msg"] as! String
                    print(msg)
                }
            } else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }

    }
    
    func checkingCarAvailablity(riderId: Int, fromPlcae: String, toPlace: String,fromLat: String, fromLon: String, toLat: String, toLon: String, carType: Int, distanceinKm: Double, completion: @escaping CompletionHandler ) {
        
        let body: [String: Any] = [
            "riderid": riderId,
            "from": fromPlcae,
            "to": toPlace,
            "fromlat": fromLat,
            "fromlon": fromLon,
            "tolat": toLat,
            "tolon": toLon,
            "cartype": carType,
            "km": distanceinKm
        ]
        
        Alamofire.request(URL_TO_CHECK_CAR_AVAILABLITY, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else { return }
                print(responseString)
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    self.rideId = responseJson!["data"] as! Int
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func getMyCar(rideId: Int, completion: @escaping CompletionHandler) {
        
        let body = [
            "rideid" : rideId
        ]
        
        Alamofire.request(URL_TO_GET_MYCAR, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    let dataString = responseJson!["data"] as! String
                    let dataJson = self.convertToDictionary(text: dataString)
                    let driverId = dataJson!["DriverId"] as! Int
                    print(driverId)
                    let driverCarNo = dataJson!["CarNumber"] as! String
                    let fare = dataJson!["Fare"] as! Double
                    let driverProfileImg = dataJson!["Profile"] as! String
                    let driverName = dataJson!["DriverName"] as! String
                    let rideCode = dataJson!["Code"] as! Int
                    let driverPhoneNo = dataJson!["Phone"] as! String
                    self.acceptedDriverDetails = DriverDetails(driverId: driverId, carNumber: driverCarNo, fare: fare, profileImg: driverProfileImg, driverName: driverName, rideCode: rideCode, driverPhoneNo: driverPhoneNo)
                    print(self.acceptedDriverDetails)
                    completion(true)
                } else {
                    completion(false)
                }
                
            } else {
                debugPrint(response.error as Any)
                completion(false)
            }
        }
        
    }
    
    func testRideId(rideId: Int, completion: @escaping CompletionHandler) {
        
        let body = [
            "Id" : rideId
        ]
        
        Alamofire.request(URL_TEST_DRIVER_CONFIRM, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let jsonString = response.result.value else {return}
                print(jsonString)
                completion(true)
            } else {
                debugPrint(response.error as Any)
                completion(false)
            }
        }
        
    }
    
    func registeringUser(firstName: String, lastName: String, email: String, phone: String, password: String, completion: @escaping CompletionHandler) {
        let body = [
            "firstname" : firstName,
            "lastname" : lastName,
            "email" : email,
            "phone" : phone,
            "password" : password
        ]
        
        Alamofire.request(URL_TO_REGISTER_USER, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let jsonString = response.result.value else {return}
                let resultJson = self.convertToDictionary(text: jsonString)
                let status = resultJson!["status"] as! Int
                if status == 1 {
                    let dataString = resultJson!["data"] as! String
                    let dataJson = self.convertToDictionary(text: dataString)
                    let userId = dataJson!["Id"] as! Int
                    print(userId)
                    let firstName = dataJson!["FirstName"] as! String
                    let lastName = dataJson!["LastName"] as! String
                    let phone = dataJson!["Phone"] as! String
                    let email = dataJson!["Email"] as! String
                    self.userEmail = email
                    self.isLoggedIn = true
                    self.loggedInThrough = 1
                    let addUser = UserDetailsDB.create()
                    print("Added user id is: ", addUser.created_id)
                    addUser.userId = userId
                    addUser.firstName = firstName
                    addUser.lastName = lastName
                    addUser.email = email
                    addUser.phoneNo = phone
                    try! uiRealm.write {
                        uiRealm.add(addUser)
                    }
                    completion(true)
                } else {
                 completion(false)
                }
            } else {
                completion(false)
                debugPrint(response.error as Any)
            }
        }
        
    }
    
    func loggingInUser(userEmail: String, password: String, completion: @escaping CompletionHandler) {
        let body = [
            "username" : userEmail,
            "password" : password
        ]
        
        Alamofire.request(URL_TO_LOGIN, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let resultString = response.result.value else {return}
                let resultJson = self.convertToDictionary(text: resultString)
                let status = resultJson!["status"] as! Int
                if status == 1 {
                    let dataString = resultJson!["data"] as! String
                    let dataJson = self.convertToDictionary(text: dataString)
                    let email = dataJson!["Email"] as! String
                    let idOfUser = dataJson!["Id"] as! Int
                    self.userEmail = email
                    self.isLoggedIn = true
                    self.loggedInThrough = 1
                    self.userId = idOfUser
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                debugPrint(response.error as Any)
                completion(false)
            }
        }
    }
    
    func getFBUserData(completion: @escaping CompletionHandler) {
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let facebookDict = result as! [String:AnyObject]
                    let email = facebookDict["email"] as! String
                    let name = facebookDict["name"] as! String
                    let fbUserId = facebookDict["id"] as! String
                    let picture = facebookDict["picture"] as! [String: Any]
                    let picData = picture["data"] as! [String: Any]
                    let picUrl = picData["url"] as! String
                    
                    self.userEmail = email
                    self.isLoggedIn = true
                    self.loggedInThrough = 2
                    
                    self.fbName = name
                    self.fbEmail = email
                    self.fbuserId = fbUserId
                    self.fbPicUrl = picUrl
                    
                    completion(true)
                } else {
                    debugPrint(error as Any)
                    completion(false)
                }
            })
        }
    }
    
    func trackDriver(driverId: Int, completion: @escaping CompletionHandler) {
        let body = [
            "driverid" : driverId
        ]
        
        Alamofire.request(URL_TO_TRACK_DRIVER, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! String
                if status == "1" {
                    let dataString = responseJson!["data"] as! String
                    let dataJson = self.convertToDictionary(text: dataString)
                    let latitudeString = dataJson!["Latitude"] as! String
                    let longitudeString = dataJson!["Longitude"] as! String
                    let latitude = Double(latitudeString)
                    let longitude = Double(longitudeString)
                    self.driversCurrentLocationForTrack = CLLocationCoordinate2DMake(latitude!, longitude!)
                    completion(true)
                } else {
                    completion(false)
                }
                
            } else {
                debugPrint(response.error as Any)
                completion(false)
            }
        }
    }

    func getFavouriteList(riderId: Int, completion: @escaping Completionhandler) {
        
        let body = [
            "riderid" : riderId
        ]
        
        Alamofire.request(URL_TO_GET_FAVOURITES, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                print(responseJson!)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    let dataString = responseJson!["data"] as! String
                    let datajson = self.convertToArrayOfDictionary(text: dataString)
                    print(datajson)
                    if datajson?.count == 0 {
                        completion(3)
                    } else {
                        for item in datajson! {
                            let favouriteId = item["Id"] as! Int
                            let address = item["Address"] as! String
                            var latitude = 0.0
                            var longitude = 0.0
                            
                            let a = self.nullToNil(value: item["Latitude"])
                            if a != nil {
                                latitude = item["Latitude"] as! Double
                            }
                            let b = self.nullToNil(value: item["Longitude"])
                            if b != nil {
                                longitude = item["Longitude"] as! Double
                            }
                            let favourites = FavouritesModel(favouriteId: favouriteId, address: address, latitude: latitude, longitude: longitude)
                            self.userFavouriteAddress.append(favourites)
                        }
                        print(self.userFavouriteAddress)
                        completion(1)
                    }
                    
                } else {
                    completion(0)
                }
                
            } else {
                completion(2)
                debugPrint(response.error as Any)
            }
        }
    }
    
    // Need to change
    func cancellingRide(rideid: Int, reasonCode: Int, completion: @escaping Completionhandler) {
        let body = [
            "rideid" : rideid,
            "Reason" : reasonCode
        ]
       
        Alamofire.request(URL_TO_CANCEL_RIDE, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! String
                if status == "1" {
                    completion(1)
                } else {
                    completion(0)
                }
                
            } else {
                completion(2)
                debugPrint(response.error as Any)
            }
        }
        
        
    }
    
    func getProfileDetails(riderId: Int, completion: @escaping Completionhandler) {
        let body = [
            "Id" : riderId
        ]
        
        Alamofire.request(URL_TO_GET_PROFILE, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                print(responseString)
                let responsejson = self.convertToDictionary(text: responseString)
                print(responsejson!)
                let status = responsejson!["status"] as! Int
                if status == 1 {
                    let dataString = responsejson!["data"] as! String
                    let datajson = self.convertToDictionary(text: dataString)
                    let userId = datajson!["Id"] as! Int
                    let firstName = datajson!["FirstName"] as! String
                    let lastName = datajson!["LastName"] as! String
                    let phone = datajson!["Phone"] as! String
                    let email = datajson!["Email"] as! String
                    let profileImg = datajson!["Profile"] as! String
                    let profileLink = PROFILE_PREFIX_LINK + profileImg
                    
                    let addUser = UserDetailsDB.create()
                    print("Added user id is: ", addUser.created_id)
                    addUser.userId = userId
                    addUser.firstName = firstName
                    addUser.lastName = lastName
                    addUser.email = email
                    addUser.phoneNo = phone
                    addUser.profileLink = profileLink
                    try! uiRealm.write {
                        uiRealm.add(addUser)
                    }
                    
                    completion(1)
                } else {
                    completion(0)
                }
            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    
    
    func getReasonsForCancelRide(completion: @escaping Completionhandler) {
        Alamofire.request(URL_TO_GET_REASONS_FOR_CANCELRIDE, method: .post, parameters: nil, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    let dataString = responseJson!["data"] as! String
                    let dataJson = self.convertToArrayOfDictionary(text: dataString)
                    for item in dataJson! {
                        let id = item["Id"] as! Int
                        let reason = item["Reason"] as! String
                        let cancelreason = CancelReasonModel(reasonId: id, reason: reason)
                        self.cancelReasons.append(cancelreason)
                    }
                    print(self.cancelReasons)
                    completion(1)
                } else {
                    completion(0)
                }
            } else {
                completion(2)
                debugPrint(response.error as Any)
            }
        }
    }
    
    func rejectRide(rideId: Int, completion: @escaping Completionhandler) {
        let body = [
            "rideid": rideId
        ]
        Alamofire.request(URL_TO_REJECT_RIDE, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! String
                if status == "1" {
                    completion(1)
                } else {
                    completion(0)
                }
            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    
    func forgetPassword(userEmail: String, completion: @escaping Completionhandler) {
        let body = [
            "username" : userEmail
        ]
        
        Alamofire.request(URL_TO_FORGET_PASSWORD, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    completion(1)
                } else {
                    completion(0)
                }
            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    func editprofile(riderid: Int, firstname: String, lastname: String, email: String, phone: String, completion: @escaping Completionhandler) {
        let body = [
            "riderid" : riderid,
            "firstname" : firstname,
            "lastname" : lastname,
            "email" : email,
            "phone" : phone
            ] as [String : Any]
        
        Alamofire.request(URL_TO_EDIT_PROFILE, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    completion(1)
                } else {
                    completion(0)
                }
                
            }else{
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    
    func getRideHistory(riderid: Int, completion: @escaping Completionhandler) {
        let body = [
            "riderid" : riderid
        ]
        
        Alamofire.request(URL_TO_GET_RIDE_HISTORY, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    let dataString = responseJson!["data"] as! String
                    let dataJson = self.convertToArrayOfDictionary(text: dataString)
                    for item in dataJson! {
                        let rideId = item["RideId"] as! Int
                        let driverId = 1 // Need to be changed once received correct value from server
                        var carNumber = ""
                       let carNo = self.nullToNil(value: item["CarNumber"])
                        if carNo != nil {
                            carNumber = carNo as! String
                        }
                        let carType = item["CarType"] as! String
                        let from = item["From"] as! String
                        let to = item["To"] as! String
                        let travelDate = "09,Aug,2018 11:35AM"
                        let fare = 25.50 // Need to be changed once received correct value from server
                        let profileLink = item["Profile"] as! String
                        let driverName = item["DriverName"] as! String
                        let driverPhoneNo = "9876543210" // Need to be changed once received correct value from server
                        let fromLat = Double(item["FromLat"] as! String)
                        let fromLon = Double(item["FromLng"] as! String)
                        let toLat = Double(item["ToLat"] as! String)
                        let toLon = Double(item["ToLng"] as! String)
                        let ride = RideHistoryModel(rideId: rideId, driverId: driverId, carNumber: carNumber, carType: carType, travelDate: travelDate, fromLocation: from, toLocation: to, fare: fare, driverProfile: profileLink, driverName: driverName, driverPhoneNo: driverPhoneNo, fromLat: fromLat, fromLon: fromLon, toLat: toLat, toLon: toLon)
                        self.ridesHistory.append(ride)
                        completion(1)
                    }
                } else {
                    completion(0)
                }
            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    
    func changePassword(riderId: Int, currentPass: String, newPass: String, completion: @escaping Completionhandler) {
        let body: [String: Any] = [
            "riderId": riderId,
            "currentPassword": currentPass,
            "newPassword": newPass
            ]
        
        Alamofire.request(URL_TO_CHANGE_PASSWORD, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                let responseJson = self.convertToDictionary(text: responseString)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    completion(1)
                } else {
                    completion(2)
                }
            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
    }
    
    func uploadProfile(base64Str: String, riderId: String, role: Int, completion: @escaping Completionhandler) {
        let body: [String: Any] = [
            "base64string" : base64Str,
            "user_id" : riderId,
            "role" : role
        ]
        
        Alamofire.request(URL_TO_UPLOAD_PROFILE_PIC, method: .post, parameters: body, encoding: URLEncoding.httpBody, headers: HEADER).responseString { (response) in
            if response.result.error == nil {
                guard let responseString = response.result.value else {return}
                print(responseString)
                let responseJson = self.convertToDictionary(text: responseString)
                print(responseJson!)
                let status = responseJson!["status"] as! Int
                if status == 1 {
                    print("Successfully uploaded profile pic")
                    completion(1)
                } else {
                    print("Something wrong in uploading pic")
                    completion(0)
                }

            } else {
                debugPrint(response.error as Any)
                completion(2)
            }
        }
        
    }
    

    func logoutuser() {
        isLoggedIn = false
        userEmail = ""
        loggedInThrough = 0
        NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
    }
    
    func convertToArrayOfDictionary(text: String) -> [[String : Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertToDictionary(text: String) -> [String : Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func nullToNil(value : Any?) -> Any? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
}
