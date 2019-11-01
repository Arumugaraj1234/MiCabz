//
//  HomeVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-06.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftGifOrigin

class HomeVC: UIViewController,UIGestureRecognizerDelegate {
    
    //Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fromLocationTF: PaddedTextField!
    @IBOutlet weak var destinationLocationTF: PaddedTextField!
    @IBOutlet weak var slideUpView: UIView!
    @IBOutlet weak var addWorkAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var addHomeAddressHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bookConfirmView: UIView!
    @IBOutlet weak var estimatedFareLbl: UILabel!
    @IBOutlet weak var bookBtn: UIButton!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var driverDetailsView: UIView!
    @IBOutlet weak var carFirstNoLbl: UILabel!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var driverImageView: RoundedImage!
    @IBOutlet var gestureScreenEdgePan: UIScreenEdgePanGestureRecognizer! //
    @IBOutlet weak var viewBlack: UIView! //
    @IBOutlet weak var viewMenu: UIView! //
    @IBOutlet weak var constraintMenuLeft: NSLayoutConstraint! //
    @IBOutlet weak var constraintMenuWidth: NSLayoutConstraint! //
    @IBOutlet weak var menuBtn: UIButton! //
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){}
    @IBOutlet weak var confirmBookBtn: UIButton!
    @IBOutlet weak var favouritesTableView: UITableView!
    @IBOutlet weak var editPlacesBtn: UIButton!
    @IBOutlet weak var fromToContainerView: ShadowView!
    @IBOutlet weak var centreMapBtn: UIButton!
    @IBOutlet weak var gifImageView: UIImageView!
    
    //Variables
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    
    var originMaker: GMSMarker?
    var destinationMarker: GMSMarker?
    var routePolyLine: GMSPolyline?
    
    var markersArray = [GMSMarker]()
    var wayPointsArray = [String]()
    
    var tableView = UITableView()
    var tableData = [String]()
    var fetcher: GMSAutocompleteFetcher?
    var isTableViewOpen: Bool = false
    var isDestinationSelectedInTV: Bool = false
    
    var myCurrentLatitude: CLLocationDegrees?
    var myCurrentLongitude: CLLocationDegrees?
    
    var driverMarkers = [GMSMarker]()
    
    var selectedCarName = ""
    var selectedCarType = 0
    var selectedCarFare:Double = 0
    var failedTimes = 0
    var timer = Timer()
    var riderId = 0
    var pathToCentre: GMSPath?
    
    //Hamburger Menu Variables
    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    var isLeftToRight = true
    
    var isMapCentered: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        favouritesTableView.tag = 77
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        fromLocationTF.delegate = self
        destinationLocationTF.delegate = self
        fromLocationTF.tag = 0
        destinationLocationTF.tag = 1
        //addHomeAddressHeight.constant = 0
        //addWorkAddressHeight.constant = 0
        collectionViewBottomConstraint.constant = 100
        bookConfirmView.isHidden = true
        driverDetailsView.isHidden = true
        centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        editPlaceBtnInitSetup()
        getRiderId()
        NotificationCenter.default.addObserver(self, selector: #selector(backFromTrackDriver), name: NOTIF_BACK_FROM_TRACK_DRIVER, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.userDataDidChange(_:)), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        
        let neBoundsCorner = CLLocationCoordinate2DMake(25.5736, 93.2473)
        let swBoundsCorner = CLLocationCoordinate2DMake(23.520964, 68.663599)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
        fetcher?.delegate = self
        
        destinationLocationTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestAlwaysAuthorization()
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        slideUpView.isHidden = true
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(HomeVC.wasDragged(gestureRecognizer:)))
        slideUpView.addGestureRecognizer(gesture)
        gesture.delegate = self
        gettingNearestCars()
        
        // set variables to their initial conditions - these can be set in Storyboard as well
        constraintMenuLeft.constant = -constraintMenuWidth.constant
        
        viewBlack.alpha = 0
        viewBlack.isHidden = true
        
        let language = NSLocale.preferredLanguages.first!
        let direction = NSLocale.characterDirection(forLanguage: language)
        
        if direction == .leftToRight {
            gestureScreenEdgePan.edges = .left
            isLeftToRight = true
        }
        else {
            gestureScreenEdgePan.edges = .right
            isLeftToRight = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @objc func userDataDidChange(_ notif: Notification){
        if AuthService.instance.isLoggedIn {
            self.confirmBookBtn.sendActions(for: .touchUpInside)
        }
    }
    
    @objc func backFromTrackDriver() {
        shouldPresentLoadingViewWithText(false, "")
        self.destinationLocationTF.text = ""
        self.clearRoute()
    }
    
    func editPlaceBtnInitSetup() {
        editPlacesBtn.layer.cornerRadius = 5.0
        editPlacesBtn.layer.borderWidth = 2.0
        editPlacesBtn.layer.borderColor = UIColor.black.cgColor
        editPlacesBtn.isHidden = true
    }
    
    func getRiderId() {
        if AuthService.instance.isLoggedIn == true {
            if AuthService.instance.loggedInThrough == 1 {
                let order = uiRealm.objects(UserDetailsDB.self).filter("email == '\(AuthService.instance.userEmail)'")
                for item in order {
                    self.riderId = item.userId
                }
            } else if AuthService.instance.loggedInThrough == 2 {
                let order = uiRealm.objects(FBUserDataDB.self).filter("email == '\(AuthService.instance.userEmail)'")
                for item in order {
                    self.riderId = item.userId
                }
            } else if AuthService.instance.loggedInThrough == 3 {
                let order = uiRealm.objects(GglUserDataDB.self).filter("email == '\(AuthService.instance.userEmail)'")
                for item in order {
                    self.riderId = Int(item.userId)!
                }
            }
        }



    }
    
    func getFavouriteList() {
        print(self.riderId)
        if AuthService.instance.isLoggedIn == true {
            AuthService.instance.userFavouriteAddress.removeAll()
            AuthService.instance.getFavouriteList(riderId: 1, completion: { (status) in
                if status == 1 {
                    self.favouritesTableView.reloadData()
                }
            })
        }

    }
    
    //hamburger Menu functions
    
    func openMenu() {
        
        // when menu is opened, it's left constraint should be 0
        constraintMenuLeft.constant = 0
        
        // view for dimming effect should also be shown
        viewBlack.isHidden = false
        
        // animate opening of the menu - including opacity value
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.view.layoutIfNeeded()
            self.viewBlack.alpha = self.maxBlackViewAlpha
            
        }, completion: { (complete) in
            
            // disable the screen edge pan gesture when menu is fully opened
            self.gestureScreenEdgePan.isEnabled = false
        })
    }
    
    func hideMenu() {
        
        // when menu is closed, it's left constraint should be of value that allows it to be completely hidden to the left of the screen - which is negative value of it's width
        constraintMenuLeft.constant = -constraintMenuWidth.constant
        
        // animate closing of the menu - including opacity value
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.view.layoutIfNeeded()
            self.viewBlack.alpha = 0
            
        }, completion: { (complete) in
            
            // reenable the screen edge pan gesture so we can detect it next time
            self.gestureScreenEdgePan.isEnabled = true
            
            // hide the view for dimming effect so it wont interrupt touches for views underneath it
            self.viewBlack.isHidden = true
        })
    }
    
    
    
    @IBAction func bookViewBackBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.4) {
            self.bookConfirmView.isHidden = true
            self.collectionViewBottomConstraint.constant = 0
        }
    }
    
    @IBAction func bookNowBtnPressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn{
            self.animateBookConfirmView(shoulShow: false)
            //self.destinationLocationTF.text = ""
            self.clearRoute()
            let currentCoordinates = CLLocationCoordinate2DMake(myCurrentLatitude!, myCurrentLongitude!)
            mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinates, zoom: 15.0)
            //shouldPresentLoadingViewWithText(true, "Checking for Car...")
//            self.gifImageView.isHidden = false
//            self.gifImageView.loadGif(name: "ripple"
            self.animateSearchingView(shouldShow: true)
            checkingCarAvailablity()
        } else {
            performSegue(withIdentifier: TO_LOGINVC_SEGUE, sender: self)
        }

    }
    
    @IBAction func centreMapBtnPressed(_ sender: Any) {
        
        if self.pathToCentre == nil {
            let currentCoordinates = CLLocationCoordinate2DMake(myCurrentLatitude!, myCurrentLongitude!)
            mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinates, zoom: 15.0)
        } else {
                let bounds = GMSCoordinateBounds(path: pathToCentre!)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        }
        
        self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        self.isMapCentered = true

    }
    
    @IBAction func backFromDriverConfimPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.driverDetailsView.isHidden = true
        }) { (success) in
            self.destinationLocationTF.text = ""
            self.clearRoute()
        }
    }
    
    @IBAction func gestureScreenEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        // retrieve the current state of the gesture
        if sender.state == UIGestureRecognizerState.began {
            
            // if the user has just started dragging, make sure view for dimming effect is hidden well
            viewBlack.isHidden = false
            viewBlack.alpha = 0
            
        } else if (sender.state == UIGestureRecognizerState.changed) {
            
            // retrieve the amount viewMenu has been dragged
            var translationX = sender.translation(in: sender.view).x
            
            if !isLeftToRight {
                translationX = -translationX
            }
            
            if -constraintMenuWidth.constant + translationX > 0 {
                
                // viewMenu fully dragged out
                constraintMenuLeft.constant = 0
                viewBlack.alpha = maxBlackViewAlpha
                
            } else if translationX < 0 {
                
                // viewMenu fully dragged in
                constraintMenuLeft.constant = -constraintMenuWidth.constant
                viewBlack.alpha = 0
                
            } else {
                
                // viewMenu is being dragged somewhere between min and max amount
                constraintMenuLeft.constant = -constraintMenuWidth.constant + translationX
                
                let ratio = translationX / constraintMenuWidth.constant
                let alphaValue = ratio * maxBlackViewAlpha
                viewBlack.alpha = alphaValue
            }
        } else {
            
            // if the menu was dragged less than half of it's width, close it. Otherwise, open it.
            if constraintMenuLeft.constant < -constraintMenuWidth.constant / 2 {
                self.hideMenu()
            } else {
                self.openMenu()
            }
        }
    }
    
    @IBAction func gesturePan(_ sender: UIPanGestureRecognizer) {
        // retrieve the current state of the gesture
        if sender.state == UIGestureRecognizerState.began {
            
            // no need to do anything
        } else if sender.state == UIGestureRecognizerState.changed {
            
            // retrieve the amount viewMenu has been dragged
            var translationX = sender.translation(in: sender.view).x
            
            if !isLeftToRight {
                translationX = -translationX
            }
            
            if translationX > 0 {
                
                // viewMenu fully dragged out
                constraintMenuLeft.constant = 0
                viewBlack.alpha = maxBlackViewAlpha
                
            } else if translationX < -constraintMenuWidth.constant {
                
                // viewMenu fully dragged in
                constraintMenuLeft.constant = -constraintMenuWidth.constant
                viewBlack.alpha = 0
                
            } else {
                
                // it's being dragged somewhere between min and max amount
                constraintMenuLeft.constant = translationX
                
                let ratio = (constraintMenuWidth.constant + translationX) / constraintMenuWidth.constant
                let alphaValue = ratio * maxBlackViewAlpha
                viewBlack.alpha = alphaValue
            }
        } else {
            
            // if the drag was less than half of it's width, close it. Otherwise, open it.
            if constraintMenuLeft.constant < -constraintMenuWidth.constant / 2 {
                self.hideMenu()
            } else {
                self.openMenu()
            }
        }
    }
    
    @IBAction func gestureTap(_ sender: UITapGestureRecognizer) {
        self.hideMenu()
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        self.destinationLocationTF.text = ""
        self.clearRoute()
        animateCollectionView(shouldShow: false)
        self.openMenu()
    }
    
    @IBAction func callDriver(_ sender: Any) {
        
    }
    
    @IBAction func trackDriver(_ sender: Any) {
        if AuthService.instance.acceptedDriverDetails != nil  {
            self.performSegue(withIdentifier: TO_TRACK_DRIVER_VC, sender: self)
//            self.animateDriverDetailsView(shouldShow: false)
//            let driverId = AuthService.instance.acceptedDriverDetails.driverId
//            AuthService.instance.trackDriver(driverId: driverId!, completion: { (success) in
//                if success {
//
//                } else {
//                    print("Something wrong in getting driver position")
//                }
//            })
        }
    }
    
    @IBAction func editPlaceBtnPressed(_ sender: Any) {
        animateFromToContainerView(shoulShow: true)
        clearRoute()
        destinationLocationTF.becomeFirstResponder()
    }
    
    
    func driverCurrentLocationMarker(coordinates: CLLocationCoordinate2D) {
        var driverTrackLocationMarker = GMSMarker()
        driverTrackLocationMarker = GMSMarker(position: coordinates)
        driverTrackLocationMarker.icon = UIImage(named: "carIcon")
        driverTrackLocationMarker.map = mapView
    }
    
    @IBAction func cancelRide(_ sender: Any) {
        
    }
    
    func mapInitialSetUp() {
        let camera : GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 13.267929, longitude: 80.266868, zoom: 6.0)
        mapView.camera = camera
        //centreMapBtn.isHidden = true
    }
    
    func setuplocationMarker(coordinate: CLLocationCoordinate2D) {
            locationMarker = GMSMarker(position: coordinate)
            locationMarker.map = mapView
    }
    
    func setLocationMarkerForDrivers(driverPosition: [NearestCars]) {
        for item in driverPosition {
            let driverLocationMarker = GMSMarker()
            driverLocationMarker.position = CLLocationCoordinate2DMake(item.latitude, item.longitude)
            driverLocationMarker.icon = UIImage(named: "carIcon")
            driverLocationMarker.map = mapView
        }
    }
    
    func settingPolyLine() {
        configureMapAndMarkersForRoute()
        drawRoute()
    }
    
    func gettingNearestCars() {
        AuthService.instance.getNearestCars(latitude: 13.2703208, Longitude: 80.2711587) { (success) in
            if success {
                self.setLocationMarkerForDrivers(driverPosition: AuthService.instance.nearestCars)
            } else {
                print("Wrong")
            }
        }
    }
    
    func gettingCarTypes() {
        AuthService.instance.carTypes.removeAll()
        print(Double(AuthService.instance.totalDistanceInMeters))
        print(AuthService.instance.distanceInkiloMeters)
        AuthService.instance.getCarTypes(distance: AuthService.instance.distanceInkiloMeters) { (success) in
            if success {
                self.animateCollectionView(shouldShow: true)
                self.collectionView.reloadData()
                self.shouldPresentLoadingViewWithText(false, "")
            } else {
               print("Error")
            }
        }
    }
    
    
    func checkingCarAvailablity() {
        print("RiderId: \(self.riderId)")
        print("Source: \(AuthService.instance.currentAddressFromCurrentCoordinates!)")
        print("Destination: \(destinationLocationTF.text!)")
        print("Tolat: \(AuthService.instance.fetchedAddressLatitude!)")
        print("Tolat: \(AuthService.instance.fetchedAddressLongitude!)")
        print("carType: \(self.selectedCarType)")
        print("distance: \(AuthService.instance.distanceInkiloMeters)")
        AuthService.instance.checkingCarAvailablity(riderId: self.riderId, fromPlcae: AuthService.instance.currentAddressFromCurrentCoordinates!, toPlace: destinationLocationTF.text!, fromLat: "13.267872", fromLon: "80.266949", toLat: "\(AuthService.instance.fetchedAddressLatitude!)", toLon: "\(AuthService.instance.fetchedAddressLongitude!)", carType: self.selectedCarType, distanceinKm: AuthService.instance.distanceInkiloMeters) { (success) in
            if success {
                self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(HomeVC.gettingMyCar), userInfo: nil, repeats: true)
            } else {
                print("Something went wrong while checking availablity of car")
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
    
    @objc func gettingMyCar() {
        print("RideId: \(AuthService.instance.rideId)")
        AuthService.instance.getMyCar(rideId: AuthService.instance.rideId) { (success) in
            if success {
                self.failedTimes = 0
                self.animateCollectionView(shouldShow: false)
                self.animateBookConfirmView(shoulShow: false)
                //self.animateDriverDetailsView(shouldShow: true)
                //self.shouldPresentLoadingViewWithText(false, "")
                //self.gifImageView.isHidden = true
                self.animateSearchingView(shouldShow: false)
                self.performSegue(withIdentifier: TO_TRACK_DRIVER_VC, sender: self)
                self.timer.invalidate()
                self.timer = Timer()
            } else {
                self.failedTimes += 1
                print("Not getting car, Trying again")
                print(self.failedTimes)
                if self.failedTimes == 2 {
                    AuthService.instance.testRideId(rideId: AuthService.instance.rideId, completion: { (success) in
                        if success {
                            self.timer.invalidate()
                            self.timer = Timer()
                            print("Car allocated for the rideid: \(AuthService.instance.rideId)")
                            self.gettingCarAgain()
                        } else {
                            self.rejectRides()
                            print("Oops, Car not allocated")
                        }
                    })
                }
                
                if self.failedTimes > 19 {
                    self.timer.invalidate()
                    self.timer = Timer()
                    self.failedTimes = 0
                    print("No car available for ride")
                    self.rejectRides()
                    self.shouldPresentLoadingViewWithText(false, "")
                    self.alertViewToShow(alertTitle: "Not Available", alertMsg: "Car not available nearby you", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
                }
            }
        }
    }
    
    func gettingCarAgain() {
            AuthService.instance.getMyCar(rideId: AuthService.instance.rideId, completion: { (success) in
                if success {
                    self.animateCollectionView(shouldShow: false)
                    self.animateBookConfirmView(shoulShow: false)
                    //self.animateDriverDetailsView(shouldShow: true)
                    self.performSegue(withIdentifier: TO_TRACK_DRIVER_VC, sender: self)
                } else {
                    self.shouldPresentLoadingViewWithText(false, "")
                    print("Ooops something went wroong")
                }
            })
    }
    
    func rejectRides() {
        print("RideId to reject: \(AuthService.instance.rideId)")
        AuthService.instance.rejectRide(rideId: AuthService.instance.rideId) { (status) in
            if status == 1 {
                print("Successfully rejected the rided id: \(AuthService.instance.rideId)")
            } else {
                print("oops, something went wrong in rejecting ride")
            }
        }
    }

    
    func configureMapAndMarkersForRoute() {
        mapView.camera = GMSCameraPosition.camera(withTarget: AuthService.instance.originCoordinate, zoom: 15.0)
        //centreMapBtn.isHidden = true

        
        originMaker = GMSMarker(position: AuthService.instance.originCoordinate)
        originMaker?.map = self.mapView
        originMaker?.icon = UIImage(named: "passAnnotation")
        //originMaker?.title = AuthService.instance.originAddress
        originMaker?.snippet = AuthService.instance.originAddress
        self.mapView.selectedMarker = originMaker

        destinationMarker = GMSMarker(position: AuthService.instance.destinationCoordinate)
        destinationMarker?.map = self.mapView
        destinationMarker?.icon = UIImage(named: "destAnnotation")
        //destinationMarker?.title = AuthService.instance.destinationAddress
        destinationMarker?.snippet = destinationLocationTF.text!
        self.mapView.selectedMarker = destinationMarker

        
        if wayPointsArray.count > 0 {
            for wapoint in wayPointsArray {
                let reqCoOrdinate = wapoint.components(separatedBy: ",")
                let lat: Double = Double(reqCoOrdinate[0])!
                let lon:Double = Double(reqCoOrdinate[1])!
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lon))
                marker.map = mapView
                marker.icon = GMSMarker.markerImage(with: UIColor.darkGray)
                markersArray.append(marker)
            }
        }
    }
    
    func drawRoute() {
        let route = AuthService.instance.overViewPolyLine["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyLine = GMSPolyline(path: path)
        routePolyLine?.strokeColor = UIColor(red: 61/255.0, green: 175/255.0, blue: 185/255.0, alpha: 0.75)
        routePolyLine?.strokeWidth = 3.0
        routePolyLine?.map = mapView
        self.pathToCentre = path
        let bounds = GMSCoordinateBounds(path: path)
        //mapView.animate(with: GMSCameraUpdate.fit(bounds))
       mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
        self.animateFromToContainerView(shoulShow: false)
    }
    
    
    
    func clearRoute() {
        originMaker?.map = nil
        destinationMarker?.map = nil
        routePolyLine?.map = nil
        
        originMaker = nil
        destinationMarker = nil
        routePolyLine = nil
        self.pathToCentre = nil
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            markersArray.removeAll(keepingCapacity: false)
        }
        
        animateFromToContainerView(shoulShow: true)
    }
    
    func recreateRoute() {
        if let polyline = routePolyLine {
            clearRoute()
            AuthService.instance.geocodeAddress(address: destinationLocationTF.text!) { (success) in
                if success {
                    AuthService.instance.getDirectionsFromgeoCode(originLat: 13.267872, originLon: 80.266949, destinalat: AuthService.instance.fetchedAddressLatitude, destLon: AuthService.instance.fetchedAddressLongitude, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.configureMapAndMarkersForRoute()
                                self.drawRoute()
                                self.isDestinationSelectedInTV = true
                                self.gettingCarTypes()
                            }
                        } else {
                            print("Something wrong in getting Directions")
                        }
                    })
                } else {
                    print("problem in getting geo code")
                }
            }
        } else {
            AuthService.instance.geocodeAddress(address: destinationLocationTF.text!) { (success) in
                if success {
                    AuthService.instance.getDirectionsFromgeoCode(originLat: 13.267872, originLon: 80.266949, destinalat: AuthService.instance.fetchedAddressLatitude, destLon: AuthService.instance.fetchedAddressLongitude, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.configureMapAndMarkersForRoute()
                                self.drawRoute()
                                self.isDestinationSelectedInTV = true
                                self.gettingCarTypes()
                            }
                        } else {
                            print("Something wrong in getting Directions")
                        }
                    })
                } else {
                    print("problem in getting geo code")
                }
            }
        }
    }
    
    func recreateRouteForBookingView() {
        if let polyline = routePolyLine {
            clearRoute()
            AuthService.instance.geocodeAddress(address: destinationLocationTF.text!) { (success) in
                if success {
                    AuthService.instance.getDirectionsFromgeoCode(originLat: 13.267872, originLon: 80.266949, destinalat: AuthService.instance.fetchedAddressLatitude, destLon: AuthService.instance.fetchedAddressLongitude, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.configureMapAndMarkersForRoute()
                                self.drawRoute()
                            }
                        } else {
                            print("Something wrong in getting Directions")
                        }
                    })
                } else {
                    print("problem in getting geo code")
                }
            }
        }
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 16, y: 190, width: self.view.frame.width - 32, height: self.view.frame.height - 200)
                self.isTableViewOpen = true
            })
        } else {
            self.isTableViewOpen = false
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 16, y: self.view.frame.height, width: self.view.frame.width - 32, height: self.view.frame.height - 200)
            }, completion: { (finished) in
                for subview in self.view.subviews {
                    if subview.tag == 18 {
                        subview.removeFromSuperview()
                    }
                }
            })
        }
    }
    
    func animateCollectionView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionViewBottomConstraint.constant = 0
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionViewBottomConstraint.constant = 100
            })
        }
    }
    
    func animateBookConfirmView(shoulShow: Bool) {
        if shoulShow {
            UIView.animate(withDuration: 0.4, animations: {
                self.bookConfirmView.isHidden = false
                self.collectionViewBottomConstraint.constant = -150
                self.recreateRouteForBookingView()
            }, completion: { (success) in
                self.estimatedFareLbl.text = "$\(self.selectedCarFare)/- (Aprox)"
                self.carNameLbl.text = self.selectedCarName
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.bookConfirmView.isHidden = true
                self.collectionViewBottomConstraint.constant = 100
            })
        }
    }
    
    func animateDriverDetailsView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.3, animations: {
                self.driverDetailsView.isHidden = false
            }) { (success) in
                let carNo = AuthService.instance.acceptedDriverDetails.carNumber!
                let carNoWithoutSpace = carNo.replacingOccurrences(of: " ", with: "")
                self.carFirstNoLbl.text = carNoWithoutSpace
                self.driverNameLbl.text = AuthService.instance.acceptedDriverDetails.driverName!
                self.otpLbl.text = "OTP:\(AuthService.instance.acceptedDriverDetails.rideCode!)"
                //let url = URL(fileURLWithPath: AuthService.instance.acceptedDriverDetails.profileImg!)
                self.driverImageView.downloadedFrom(link: AuthService.instance.acceptedDriverDetails.profileImg!)
                self.shouldPresentLoadingViewWithText(false, "")
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.driverDetailsView.isHidden = true
            })
        }

    }
    
    func animateEditPlacesBtn(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.editPlacesBtn.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.editPlacesBtn.isHidden = true
            })
        }
    }
    
    func animateFromToContainerView(shoulShow: Bool) {
        if shoulShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.fromToContainerView.isHidden = false
                self.animateEditPlacesBtn(shouldShow: false)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.fromToContainerView.isHidden = true
                self.animateEditPlacesBtn(shouldShow: true)
            })
        }
    }
    
    func animateSearchingView(shouldShow: Bool) {
        let gifView = UIView()
        gifView.frame = self.view.bounds
        let gifImage = UIImageView()
        gifImage.frame = CGRect(x: gifView.frame.width / 2 - 100.0, y: gifView.frame.height / 2 - 90.0, width: 200.0, height: 200.0)
        gifImage.loadGif(name: "ripple")
        gifView.addSubview(gifImage)
        gifView.tag = 21
        
        if shouldShow {
            mapView.addSubview(gifView)
        } else {
            for view in mapView.subviews {
                if view.tag == 21 {
                   view.removeFromSuperview()
                }
            }
        }

    }
    
    func slideUpViewinit() {
        //slideUpViewYPosition.constant = 200.0
    }
    
    func animateSlideUpView() {
        UIView.animate(withDuration: 0.2) {
            //self.slideUpViewYPosition.constant = 10.0
        }
    }
    
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began || gestureRecognizer.state == UIGestureRecognizerState.changed {
            let translation = gestureRecognizer.translation(in: self.view)
            if(gestureRecognizer.view!.center.y > 444) {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            }else {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:444)
            }
            
            if(gestureRecognizer.view!.center.y < 875) {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
            }else {
                gestureRecognizer.view!.center = CGPoint(x:gestureRecognizer.view!.center.x, y:874)
            }
            

            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }
    
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
            //locationManager.startUpdatingLocation()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            myCurrentLatitude = myLocation.coordinate.latitude
            myCurrentLongitude = myLocation.coordinate.longitude
            print("currentLatitude: \(myCurrentLatitude!)")
            print("Current Longitude: \(myCurrentLongitude!)")
            //AuthService.instance.getAddressFromGeoCode(latitude:13.267872 , longitude: 80.266949)
            AuthService.instance.getAddressFromGeoCode(latitude:myLocation.coordinate.latitude , longitude: myLocation.coordinate.longitude) { (success) in
                if success {
                    print("Successfully received")
                } else {
                    print("Something went wrong")
                }
            }
            mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15.0)
            //centreMapBtn.isHidden = true
            //mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            didFindMyLocation = false
            //setuplocationMarker(coordinate: myLocation.coordinate)
        }
    }
    

}

extension HomeVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let polyline = routePolyLine {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            wayPointsArray.append(positionString)
            //recreateRoute()
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        print("1")
        if self.isMapCentered == false {
            self.centreMapBtn.fadeTo(alphaValue: 1.0, withDuration: 0.2)
        } else {
            self.centreMapBtn.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        }
         self.isMapCentered = false
        
    }

}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            animateBookConfirmView(shoulShow: false)
            animateCollectionView(shouldShow: false)
            if AuthService.instance.isLoggedIn {
                self.getFavouriteList()
                slideUpView.isHidden = false
            }
            tableView.frame = CGRect(x: 16, y: self.view.frame.height, width: self.view.frame.width - 32, height: self.view.frame.height - 200)
            tableView.layer.cornerRadius = 5.0
            tableView.tag = 18
            tableView.rowHeight = 50
            tableView.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.6)
            tableView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tableView.layer.borderWidth = 1.0
            tableView.separatorStyle = .none
            view.addSubview(tableView)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    

    
    @objc func textFieldDidChange(textField: UITextField) {
        animateBookConfirmView(shoulShow: false)
        animateCollectionView(shouldShow: false)
        if textField.text != "" {
            slideUpView.isHidden = true
            AuthService.instance.userFavouriteAddress.removeAll()
            tableView.layer.cornerRadius = 5.0
            tableView.tag = 18
            tableView.rowHeight = 50
            tableView.backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.6)
            tableView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tableView.layer.borderWidth = 1.0
            tableView.separatorStyle = .none
            view.addSubview(tableView)
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 16, y: 190, width: self.view.frame.width - 32, height: self.view.frame.height - 200)
                self.isTableViewOpen = true
            })
            fetcher?.sourceTextHasChanged(destinationLocationTF.text!)
            tableView.reloadData()
        } else {
            animateTableView(shouldShow: false)
            if AuthService.instance.isLoggedIn {
                getFavouriteList()
                slideUpView.isHidden = false
            }
        }

    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 18 {
            return tableData.count
        }
        
        if tableView.tag == 77 {
            return AuthService.instance.userFavouriteAddress.count
        }
        return 0
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 18 {
            let cell = LocationCell(style: UITableViewCellStyle.default, reuseIdentifier: "locationCell")
            let address = tableData[indexPath.row]
            cell.configureCell(title: address)
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        
        if tableView.tag == 77 {
            if let cell = favouritesTableView.dequeueReusableCell(withIdentifier: "favouritesCell", for: indexPath) as? FavouritesCell {
                let address = AuthService.instance.userFavouriteAddress[indexPath.row]
                cell.updateUIView(favourites: address)
                return cell
            }
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 18 {
            shouldPresentLoadingViewWithText(true, "Loading")
            destinationLocationTF.text = tableData[indexPath.row]
            view.endEditing(true)
            animateTableView(shouldShow: false)
            if AuthService.instance.fetchedFormattedAddress == nil {
                AuthService.instance.geocodeAddress(address: destinationLocationTF.text!) { (success) in
                    if success {
                        AuthService.instance.getDirectionsFromgeoCode(originLat: 13.267872, originLon: 80.266949, destinalat: AuthService.instance.fetchedAddressLatitude, destLon: AuthService.instance.fetchedAddressLongitude, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    self.configureMapAndMarkersForRoute()
                                    self.drawRoute()
                                    self.isDestinationSelectedInTV = true
                                    self.gettingCarTypes()
                                }
                            } else {
                                print("Something wrong in getting Directions")
                            }
                        })
                    } else {
                        print("problem in getting geo code")
                    }
                }
            } else {
                recreateRoute()
            }
        }
        
        if tableView.tag == 77 {
            slideUpView.isHidden = true
            shouldPresentLoadingViewWithText(true, "Loading")
            destinationLocationTF.text = AuthService.instance.userFavouriteAddress[indexPath.row].address
            view.endEditing(true)
            animateTableView(shouldShow: false)
            if AuthService.instance.fetchedFormattedAddress == nil {
                AuthService.instance.geocodeAddress(address: destinationLocationTF.text!) { (success) in
                    if success {
                        AuthService.instance.getDirectionsFromgeoCode(originLat: 13.267872, originLon: 80.266949, destinalat: AuthService.instance.fetchedAddressLatitude, destLon: AuthService.instance.fetchedAddressLongitude, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                            if success {
                                DispatchQueue.main.async {
                                    self.configureMapAndMarkersForRoute()
                                    self.drawRoute()
                                    self.isDestinationSelectedInTV = true
                                    self.gettingCarTypes()
                                }
                            } else {
                                print("Something wrong in getting Directions")
                            }
                        })
                    } else {
                        print("problem in getting geo code")
                    }
                }
            } else {
                recreateRoute()
            }
        }

      
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if destinationLocationTF.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}

extension HomeVC: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        tableData.removeAll()
        for prediction in predictions {
            let addressText = prediction.attributedFullText.string
            self.tableData.append(addressText)
        }
        tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        debugPrint(error.localizedDescription)
    }
    
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AuthService.instance.carTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carTypeItem", for: indexPath) as? CarTypeCell {
            let carType = AuthService.instance.carTypes[indexPath.row]
            cell.configureCell(carType: carType)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCarName = AuthService.instance.carTypes[indexPath.row].carName
        self.selectedCarType = AuthService.instance.carTypes[indexPath.row].carType
        self.selectedCarFare = AuthService.instance.carTypes[indexPath.row].rideCost
        self.animateBookConfirmView(shoulShow: true)
    }
}


