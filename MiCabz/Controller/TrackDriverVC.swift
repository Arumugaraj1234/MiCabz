//
//  TrackDriverVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-23.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class TrackDriverVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var carNameLbl: UILabel!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carNumberLbl: UILabel!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var driverImage: RoundedImage!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var cancelReasonView: UIView!
    @IBOutlet weak var cancelReasonTableView: UITableView!
    @IBOutlet weak var resonSubmitBtn: UIButton!
    @IBOutlet weak var driverDetailsView: UIView!
    @IBOutlet weak var driverLocationView: UIView!
    @IBOutlet weak var driverLocationMapView: GMSMapView!
    @IBOutlet weak var trackBtn: UIButton!
    @IBOutlet weak var driverDistanceStatusLbl: UILabel!
    
    
    
    //Variables
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var locationMarker: GMSMarker!
    var driverTrackLocationMarker: GMSMarker?
    var timer = Timer()
    var counterForTrack = 0
    
    let backBtn = UIButton()
    let centreMapBtn = UIButton()
    var myCurrentLatitude: CLLocationDegrees?
    var myCurrentLongitude: CLLocationDegrees?
    
    var cancelReasonId = 0
    
    
    let coOrd1 = CLLocationCoordinate2DMake(13.269217, 80.263671)
    let coOrd2 = CLLocationCoordinate2DMake(13.267303, 80.264790)
    let coOrd3 = CLLocationCoordinate2DMake(13.265848, 80.266135)
    let coOrd4 = CLLocationCoordinate2DMake(13.265702, 80.266468)
    let coOrd5 = CLLocationCoordinate2DMake(13.266114, 80.266591)
    let coOrd6 = CLLocationCoordinate2DMake(13.266522, 80.266688)
    let coOrd7 = CLLocationCoordinate2DMake(13.267023, 80.266806)
    let coOrd8 = CLLocationCoordinate2DMake(13.267346, 80.266784)
    let coOrd9 = CLLocationCoordinate2DMake(13.267670, 80.266848)
    let coOrd10 = CLLocationCoordinate2DMake(13.267900, 80.266945)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        cancelReasonTableView.delegate = self
        cancelReasonTableView.dataSource = self
        setupView()
         mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        driverCurrentLocationMarker()
        backBtn.frame = CGRect(x: 20.0, y: 28.0, width: 35.0, height: 35.0)
        backBtn.setImage(UIImage(named: "arrowBack"), for: .normal)
        backBtn.addTarget(self, action: #selector(TrackDriverVC.backBtnPressed(_:)), for: .touchUpInside)
        mapView.addSubview(backBtn)
        
        centreMapBtn.frame = CGRect(x: self.view.frame.width - 60, y: self.view.frame.height - 272, width: 40.0, height: 40.0)
        centreMapBtn.setImage(UIImage(named: "centreMapBtn"), for: .normal)
        centreMapBtn.addTarget(self, action: #selector(centreMapBtnPressed), for: .touchUpInside)
        mapView.addSubview(centreMapBtn)
        
    }

    
    func setupView() {
        driverLocationMapView.layer.cornerRadius = driverLocationMapView.frame.height / 2
        settingDriverDetails()
        getCancelReasonsDetails()
        cancelReasonView.isHidden = true
        resonSubmitBtn.layer.cornerRadius = 5.0
        driverDetailsView.layer.shadowColor = UIColor.darkGray.cgColor
        driverDetailsView.layer.shadowRadius = 5.0
        driverDetailsView.layer.shadowOpacity = 0.5
        driverDetailsView.layer.shadowOffset = CGSize(width: 0, height: -5.0)
        
        
    }
    
    @objc func backBtnPressed(_ sender: Any) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NOTIF_BACK_FROM_TRACK_DRIVER, object: nil)
        }
    }
    
    func getCancelReasonsDetails() {
        AuthService.instance.cancelReasons.removeAll()
        AuthService.instance.getReasonsForCancelRide { (status) in
            if status == 1 {
                print("Successfully got the cancel reasons list")
            } else {
                print("Something went wrong in getting reason list")
            }
        }
    }
    
    @objc func centreMapBtnPressed() {
        let currentCoordinates = CLLocationCoordinate2DMake(myCurrentLatitude!, myCurrentLongitude!)
        mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinates, zoom: 15.0)
    }
    
    @objc func gettingDriverPosition() {
        AuthService.instance.trackDriver(driverId: AuthService.instance.acceptedDriverDetails.driverId) { (success) in
            if success {
                self.driverTrackLocationMarker?.map = nil
                self.driverTrackLocationMarker = nil
                print("Driver Current Coordinate: \(AuthService.instance.driversCurrentLocationForTrack)")
                self.driverTrackLocationMarker = GMSMarker(position: AuthService.instance.driversCurrentLocationForTrack)
                self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
                self.driverTrackLocationMarker?.map = self.mapView
            }
        }
    }
    
    func settingDriverDetails() {
        let carNo = AuthService.instance.acceptedDriverDetails.carNumber!
        let carNoWithoutSpace = carNo.replacingOccurrences(of: " ", with: "")
        self.carNumberLbl.text = carNoWithoutSpace
        self.driverNameLbl.text = AuthService.instance.acceptedDriverDetails.driverName!
        self.otpLbl.text = "OTP:\(AuthService.instance.acceptedDriverDetails.rideCode!)"
        self.driverImage.downloadedFrom(link: AuthService.instance.acceptedDriverDetails.profileImg!)
    }
    
    func driverCurrentLocationMarker() {
        self.driverTrackLocationMarker = GMSMarker(position: self.coOrd1)
        self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
        //self.driverTrackLocationMarker?.map = self.mapView
        self.driverTrackLocationMarker?.map = self.driverLocationMapView
        driverLocationMapView.camera = GMSCameraPosition.camera(withTarget: self.coOrd1, zoom: 15.0)
        //mapView.camera = GMSCameraPosition.camera(withTarget: self.coOrd1, zoom: 15.0)
    }
    
    func animateCancelReasonsView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.cancelReasonView.isHidden = false
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.cancelReasonView.isHidden = true
                self.cancelReasonId = 0
            })
        }
    }
    
    @IBAction func cancelReasonViewPressed(_ sender: Any) {
        animateCancelReasonsView(shouldShow: false)
    }
    
    @IBAction func callDriver(_ sender: Any) {
    }
    
    @IBAction func stopTracking(_ sender: Any) {
        trackBtn.setTitle("Stop Track", for: .normal)
        driverDistanceStatusLbl.isHidden = true
        animateDriverMapView(shouldShow: false)
        counterForTrack = 0
        self.driverTrackLocationMarker = GMSMarker(position: self.coOrd1)
        self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
        self.driverTrackLocationMarker?.map = self.mapView
        mapView.camera = GMSCameraPosition.camera(withTarget: self.coOrd1, zoom: 15.0)

//         self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(TrackDriverVC.gettingDriverPosition), userInfo: nil, repeats: true)
    }
    
    @IBAction func cancelReasonSubmitPressed(_ sender: Any) {
        if cancelReasonId != 0 {
            animateCancelReasonsView(shouldShow: false)
            shouldPresentLoadingViewWithText(true, "Cancelling...")
            cancelRide(rideId:AuthService.instance.rideId, reasonId: cancelReasonId)
        } else {
            self.alertViewToShow(alertTitle: "Error", alertMsg: "Please select a reason", alertStyle: .alert, btnTitle: "OK", btnStyle: .cancel, handler: nil, completion: nil)
        }

    }
    
    
    
    @objc func trackingDriver() {
        driverTrackLocationMarker?.map = nil
        driverTrackLocationMarker = nil
        self.driverTrackLocationMarker = GMSMarker(position: self.coOrd2)
        self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
        self.driverTrackLocationMarker?.map = self.mapView
        /*
        if counterForTrack == 0 {
            counterForTrack = 1
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd2)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 1 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 2
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd3)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 2 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 3
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd4)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 3 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 4
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd5)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 4 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 5
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd6)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 5 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 6
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd7)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 6 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 7
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd8)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 7 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 8
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd9)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 8 {
            driverTrackLocationMarker?.map = nil
            driverTrackLocationMarker = nil
            counterForTrack = 9
            self.driverTrackLocationMarker = GMSMarker(position: self.coOrd10)
            self.driverTrackLocationMarker?.icon = UIImage(named: "carIcon")
            self.driverTrackLocationMarker?.map = self.mapView
        }
        
        if counterForTrack == 9 {
            self.timer.invalidate()
            self.timer = Timer()
        }
 */
    }
    
    func cancelRide(rideId: Int, reasonId: Int) {
        AuthService.instance.cancellingRide(rideid: rideId, reasonCode: reasonId) { (status) in
            if status == 1 {
                self.shouldPresentLoadingViewWithText(false, "")
                let alert:UIAlertController = UIAlertController(title: "Success", message: "Successfully cancelled the ride", preferredStyle: .alert)
                let done: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel)
                { _ in
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NOTIF_BACK_FROM_TRACK_DRIVER, object: nil)
                    }
                }
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.shouldPresentLoadingViewWithText(false, "")
                let alert:UIAlertController = UIAlertController(title: "Oops!", message: "Could not cancel the ride right now", preferredStyle: .alert)
                let done:UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelRide(_ sender: Any) {
        print("RideId: \(AuthService.instance.rideId)")
        animateCancelReasonsView(shouldShow: true)
        cancelReasonTableView.reloadData()
    }
    
    func animateDriverMapView(shouldShow: Bool) {
        if shouldShow {
            self.driverLocationView.fadeTo(alphaValue: 1.0, withDuration: 0.2)
        } else {
            self.driverLocationView.fadeTo(alphaValue: 0.0, withDuration: 0.2)
        }
    }
    
}

extension TrackDriverVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
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
//            mapView.settings.myLocationButton = true
//            mapView.settings.compassButton = true
            didFindMyLocation = true
            //setuplocationMarker(coordinate: myLocation.coordinate)
        }
    }
    
}

extension TrackDriverVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AuthService.instance.cancelReasons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = cancelReasonTableView.dequeueReusableCell(withIdentifier: "cancelReasonCell", for: indexPath) as? CancelReasonCell {
            let reason = AuthService.instance.cancelReasons[indexPath.row]
            cell.configureCell(cancelReason: reason)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selReasonId = AuthService.instance.cancelReasons[indexPath.row].reasonId
        print("Selected Reason Id: \(selReasonId!)")
        cancelReasonId = selReasonId!
        if let cell = cancelReasonTableView.cellForRow(at: indexPath) as? CancelReasonCell {
            cell.statusImg.image = SELECTED_CIRCLE
        }
        
        for i in 0...AuthService.instance.cancelReasons.count - 1 where i != indexPath.row {
            var index = IndexPath(row: i, section: 0)
            if let cell = cancelReasonTableView.cellForRow(at: index) as? CancelReasonCell {
                cell.statusImg.image = DESELECTED_CIRCLE
            }
        }
    }
    
    
    

}
