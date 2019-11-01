//
//  RideDetailsVC.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-10.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class RideDetailsVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var rideInvoiceNoLbl: UILabel!
    @IBOutlet weak var fromDateTimeLbl: UILabel!
    @IBOutlet weak var fromPlaceLbl: UILabel!
    @IBOutlet weak var endDateTimeLbl: UILabel!
    @IBOutlet weak var destPlaceLbl: UILabel!
    @IBOutlet weak var driverImg: RoundedImage!
    @IBOutlet weak var driverNameLbl: UILabel!
    @IBOutlet weak var rideStatusImg: UIImageView!
    @IBOutlet weak var carTypeLbl: UILabel!
    @IBOutlet weak var fareLbl: UILabel!
    @IBOutlet weak var startTimeWidthConst: NSLayoutConstraint!
    @IBOutlet weak var endTimeWidthConst: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    
    
    
    //Variables
    var selectedIndex: Int!
    var routePolyLine: GMSPolyline?
    var originMaker: GMSMarker?
    var destinationMarker: GMSMarker?
    var markersArray = [GMSMarker]()
    var originLat: Double = 0
    var originLon: Double = 0
    var destLat: Double = 0
    var destLon: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        let selectedRide = AuthService.instance.ridesHistory[selectedIndex]
        dateTimeLbl.text = selectedRide.travelDate
        rideInvoiceNoLbl.text = "\(selectedRide.rideId!)"
        startTimeWidthConst.constant = 0
        endTimeWidthConst.constant = 0
        fromPlaceLbl.text = selectedRide.fromLocation
        destPlaceLbl.text = selectedRide.toLocation
        driverImg.downloadedFrom(link: selectedRide.driverProfile)
        driverNameLbl.text = selectedRide.driverName
        carTypeLbl.text = selectedRide.carType
        fareLbl.text = "\(selectedRide.fare!)"
        self.originLat = selectedRide.fromLat
        self.originLon = selectedRide.fromLon
        self.destLat = selectedRide.toLat
        self.destLon = selectedRide.toLon
        recreateRouteForBookingView()
    }


    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func recreateRouteForBookingView() {
        if let polyline = routePolyLine {
            clearRoute()
            AuthService.instance.getDirectionsFromgeoCode(originLat: self.originLat, originLon: self.originLon, destinalat: self.destLat, destLon: destLon, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
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
            AuthService.instance.getDirectionsFromgeoCode(originLat: self.originLat, originLon: self.originLon, destinalat: self.destLat, destLon: destLon, wayPoints: [], travelMode: "driving" as AnyObject, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.configureMapAndMarkersForRoute()
                        self.drawRoute()
                    }
                } else {
                    print("Something wrong in getting Directions")
                }
            })
        }
    }
    
    func configureMapAndMarkersForRoute() {
        let originCoOrdinate = CLLocationCoordinate2DMake(self.originLat, self.originLon)
        originMaker = GMSMarker(position: originCoOrdinate)
        originMaker?.map = self.mapView
        originMaker?.icon = UIImage(named: "passAnnotation")

        
        let destCoordinate = CLLocationCoordinate2DMake(self.destLat, self.destLon)
        destinationMarker = GMSMarker(position: destCoordinate)
        destinationMarker?.map = self.mapView
        destinationMarker?.icon = UIImage(named: "destAnnotation")
        
    }
    
    func drawRoute() {
        let route = AuthService.instance.overViewPolyLine["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyLine = GMSPolyline(path: path)
        routePolyLine?.strokeColor = UIColor(red: 61/255.0, green: 175/255.0, blue: 185/255.0, alpha: 0.75)
        routePolyLine?.strokeWidth = 3.0
        routePolyLine?.map = mapView
        
        let bounds = GMSCoordinateBounds(path: path)
        mapView.animate(with: GMSCameraUpdate.fit(bounds))
    }
    
    func clearRoute() {
        originMaker?.map = nil
        destinationMarker?.map = nil
        routePolyLine?.map = nil
        
        originMaker = nil
        destinationMarker = nil
        routePolyLine = nil
    }
    


}
