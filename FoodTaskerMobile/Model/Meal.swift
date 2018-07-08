//
//  Meal.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 8/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Meal{
    var id: Int?
    var name: String?
    var short_description: String?
    var image: String?
    var price: Float?
    
    init(json: JSON){
        self.id = json["id"].int
        self.name = json["name"].string
        self.short_description = json["short_description"].string
        self.image = json["image"].string
        self.price = json["price"].float
    }
}
