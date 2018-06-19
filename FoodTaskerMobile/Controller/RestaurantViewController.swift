//
//  RestaurantViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 10/5/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    
    @IBOutlet weak var tbvRestaurant: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        loadRestaurants()
    }
    
    func loadRestaurants(){
        APIManager.shared.getRestaurants(){ (json) in
            if json != nil {
                self.restaurants = []
                if let listRes = json["restaurants"].array{
                    for item in listRes{
                        let restaurant = Restaurant(json: item)
                        self.restaurants.append(restaurant)
                    }
                    //testing
                    for res in self.restaurants{
                        print(res.name!)
                        print(res.address!)
                        print(res.logo!)
                    }
                    self.tbvRestaurant.reloadData()
                }
            }
            
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

}

extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)as! RestaurantViewCell
        let restaurant: Restaurant
        restaurant = restaurants[indexPath.row]
        
        cell.lbRestaurantName.text = restaurant.name!
        cell.lbRestaurantAddress.text = restaurant.address!
        
        if let logoName = restaurant.logo{
            let url = "\(logoName)"
            loadImage(imageView: cell.imgRestaurantLogo, urlString: url)
        }
        return cell
    }
    
}
