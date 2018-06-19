//
//  Restaurant.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 19/6/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Restaurant {
    var id: Int?
    var name: String?
    var address: String?
    var logo: String?
    
    init(json: JSON){
        self.id = json["id"].int
        self.name = json["name"].string
        self.address = json["address"].string
        self.logo = json["logo"].string
    }
}
