//
//  RideHistoryModel.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-08-04.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import Foundation

struct RideHistoryModel {
    
    public private(set) var rideId: Int!
    public private(set) var driverId: Int!
    public private(set) var carNumber: String!
    public private(set) var carType: String!
    public private(set) var travelDate: String!
    public private(set) var fromLocation: String!
    public private(set) var toLocation: String!
    public private(set) var fare: Double!
    public private(set) var driverProfile: String!
    public private(set) var driverName: String!
    public private(set) var driverPhoneNo: String!
    public private(set) var fromLat: Double!
    public private(set) var fromLon: Double!
    public private(set) var toLat: Double!
    public private(set) var toLon: Double!
    
}
