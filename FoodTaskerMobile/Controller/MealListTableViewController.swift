//
//  MealListTableViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 12/5/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit

class MealListTableViewController: UITableViewController {
    var restaurant: Restaurant?
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let restaurantName = restaurant?.name {
            self.navigationItem.title = restaurantName
        }
        loadMeals()
    }
    func loadMeals(){
        if let restaurantId = restaurant?.id{
            APIManager.shared.getMeals(restaurantId: restaurantId, completionHandler: {(json) in
                print(json)
                if json != nil {
                    self.meals = []
                    if let tempMeals = json["meals"].array{
                        for item in tempMeals{
                            let meal = Meal(json: item)
                            self.meals.append(meal)
                        }
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    func loadImage(imageView: UIImageView, urlString: String){
        let imgURL: URL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            guard let data = data, error == nil else{return}
            
            DispatchQueue.main.async(execute: {
                imageView.image = UIImage(data: data)
            })
            }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meals.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MealViewCell
        
        let meal = meals[indexPath.row]
        cell.lbMealName.text = meal.name
        cell.lbMealShortDescription.text = meal.short_description
        
        if let price = meal.price {
            cell.lbMealPrice.text = "$\(price)"
        }

        if let image = meal.image {
            loadImage(imageView: cell.imgMealImage, urlString: "\(image)")
        }
        
        return cell
    }
}
