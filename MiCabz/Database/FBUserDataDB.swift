//
//  FBUserDataDB.swift
//  MiCabz
//
//  Created by Peach IT Solutions on 2018-07-21.
//  Copyright © 2018 Peach IT Solutions. All rights reserved.
//

import UIKit
import RealmSwift

class FBUserDataDB: Object {
    @objc dynamic var created_id = 1
    @objc dynamic var userId = 0
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var phoneNo = ""
    @objc dynamic var photoUrl = ""
    
    override static func primaryKey() -> String {
        return "created_id"
    }
    
    static func create() -> FBUserDataDB {
        let user = FBUserDataDB()
        user.created_id = lastId()
        return user
    }
    
    static func lastId() -> Int {
        if let auto_id = uiRealm.objects(FBUserDataDB.self).last {
            return auto_id.created_id + 1
        } else {
            return 1
        }
    }
}
