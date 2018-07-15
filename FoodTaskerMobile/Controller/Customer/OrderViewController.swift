//
//  OrderViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 27/5/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class OrderViewController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    @IBOutlet weak var tbvMeals: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbStatus: UILabel!
    
    var tray = [JSON]()
    
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        getLatestMeal()
    }
    
    func getLatestMeal(){
        APIManager.shared.getLatestOrder { (json) in
            print(json)
            
            let order = json["order"]
            
            if let orderDetails = json["order"]["order_details"].array {
                self.lbStatus.text = order["status"].string!.uppercased()
                self.tray = orderDetails
                self.tbvMeals.reloadData()
            }
            let from = order["restaurant"]["address"].string!
            let to = order["address"].string!
            
            self.getLocation("Causeway Bay", "Restaurant", { (source) in
                self.source = source
                
                self.getLocation(to, "Customer", { (destination) in
                    self.destination = destination
                    self.getDirections()
                })
            })
        }
    }
    //get the direction and zoom to address
    func getDirections(){
        let request = MKDirectionsRequest()
        request.source = MKMapItem.init(placemark: source!)
        request.destination = MKMapItem.init(placemark: destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            if error != nil{
                print("Error: ",error!)
            }else{
                //show route
                self.showRoute(response: response!)
            }
        }
    }
    func showRoute(response: MKDirectionsResponse){
        for route in response.routes{
            self.map.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        var zoomRect = MKMapRectNull
        for annotation in self.map.annotations{
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let insetWidth = -zoomRect.size.width*0.2
        let insetHeight = -zoomRect.size.height*0.2
        let insetRect = MKMapRectInset(zoomRect, insetWidth, insetHeight)
        
        self.map.setVisibleMapRect(insetRect, animated: true)
    }

}
extension OrderViewController: MKMapViewDelegate{
    //delegate method of MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    //convert address string to a location on the map
    func getLocation(_ address: String,_ title: String,_ completionHandler: @escaping(MKPlacemark)->Void){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if (error != nil){
                print("Error: ", error!)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                
                //create a pin
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = coordinates
                dropPin.title = title
                
                self.map.addAnnotation(dropPin)
                completionHandler(MKPlacemark.init(placemark: placemark))
            }
        }
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderViewCell
        
        let item = tray[indexPath.row]
        cell.lbQty.text = String(item["quantity"].int!)
        cell.lbMealName.text = item["meal"]["name"].string
        cell.lbSubTotal.text = "$\(String(item["sub_total"].float!))"
        
        return cell
    }
}
