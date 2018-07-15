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
    @IBOutlet weak var tbvRestaurant: UITableView!
    @IBOutlet weak var searchRestaurant: UISearchBar!
    var restaurants = [Restaurant]()
    var filteredRestaurants = [Restaurant]()
    
    let activityIndicator = UIActivityIndicatorView()
    
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
        Helpers.showActivityIndicatior(activityIndicator, view)
        
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
                    Helpers.hideActivityIndicatior(self.activityIndicator)
                }
            }
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MealList"{
            let controller = segue.destination as! MealListTableViewController
            controller.restaurant = restaurants[(tbvRestaurant.indexPathForSelectedRow?.row)!]
        }
    }

}
extension RestaurantViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRestaurants = self.restaurants.filter({ (res: Restaurant) -> Bool in
            return res.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        self.tbvRestaurant.reloadData()
    }
}

extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchRestaurant.text != ""{
            return self.filteredRestaurants.count
        }
        return self.restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath)as! RestaurantViewCell
        let restaurant: Restaurant
        if searchRestaurant.text != ""{
            restaurant = filteredRestaurants[indexPath.row]
        }
        else{
            restaurant = restaurants[indexPath.row]
        }
        
        cell.lbRestaurantName.text = restaurant.name!
        cell.lbRestaurantAddress.text = restaurant.address!
        
        if let logoName = restaurant.logo{
            Helpers.loadImage(cell.imgRestaurantLogo, "\(logoName)")
        }
        return cell
    }
    
}
