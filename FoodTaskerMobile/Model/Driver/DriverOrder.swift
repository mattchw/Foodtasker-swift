//
//  DriverOrder.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 15/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation
import SwiftyJSON

class DriverOrder{
    var id: Int?
    var customerName: String?
    var customerAddress: String?
    var customerAvatar: String?
    var restaurantName: String?
    init(json: JSON){
        self.id = json["id"].int
        self.customerName = json["customer"]["name"].string
        self.customerAddress = json["customer"]["address"].string
        self.customerAvatar = json["customer"]["avatar"].string
        self.restaurantName = json["restaurant"]["name"].string
    }
}
