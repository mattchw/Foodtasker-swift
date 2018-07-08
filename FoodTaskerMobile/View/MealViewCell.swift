//
//  MealViewCell.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 8/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit

class MealViewCell: UITableViewCell {

    @IBOutlet weak var lbMealName: UILabel!
    @IBOutlet weak var lbMealShortDescription: UILabel!
    @IBOutlet weak var lbMealPrice: UILabel!
    @IBOutlet weak var imgMealImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
