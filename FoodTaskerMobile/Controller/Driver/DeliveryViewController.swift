//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 14/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit
import MapKit

class DeliveryViewController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var lbCustomerName: UILabel!
    @IBOutlet weak var lbCustomerAddress: UILabel!
    @IBOutlet weak var imgCustomerAvatar: UIImageView!
    
    @IBOutlet weak var viewinfo: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bComplete: UIButton!
    
    var orderId: Int?
    var destination: MKPlacemark?
    var source: MKPlacemark?
    
    var locationManager: CLLocationManager!
    var driverPin: MKPointAnnotation!
    var lastLocation: CLLocationCoordinate2D!
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //show current driver's location
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            self.map.showsUserLocation = false
        }
        //running the updating location process
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLocation(_:)), userInfo: nil, repeats: true)
    }
    @objc func updateLocation(_ sender: AnyObject){
        APIManager.shared.updateLocation(location: self.lastLocation) { (json) in
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    func loadData(){
        APIManager.shared.getCurrentDriverOrder { (json) in
            print(json)
            let order = json["order"]
            
            if let id = order["id"].int, order["status"]=="On the way"{
                self.orderId = id
                let from = order["address"].string!
                let to = order["restaurant"]["address"].string!
                
                let customerName = order["customer"]["name"].string!
                let customerAvatar = order["customer"]["avatar"].string!
                
                self.lbCustomerName.text = customerName
                self.lbCustomerAddress.text = from
                
                self.imgCustomerAvatar.image = try! UIImage(data: Data(contentsOf: URL(string: customerAvatar)!))
                self.imgCustomerAvatar.layer.cornerRadius = 50/2
                self.imgCustomerAvatar.clipsToBounds = true
                
                self.getLocation(from, "Customer", { (source) in
                    self.source = source
                    
                    self.getLocation(to, "Restaurant", { (destination) in
                        self.destination = destination
                    })
                })
                
            }else{
                self.map.isHidden = true
                self.viewinfo.isHidden = true
                self.bComplete.isHidden = true
                
                //show a message
                let lbMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
                lbMessage.center = self.view.center
                lbMessage.textAlignment = NSTextAlignment.center
                lbMessage.text = "Your don't have any orders for delivery."
                
                self.view.addSubview(lbMessage)
            }
        }
    }

}

extension DeliveryViewController: MKMapViewDelegate{
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
                print("Error(getLocation): ", error!," address: ",address)
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
extension DeliveryViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last! as CLLocation
        self.lastLocation = location.coordinate
        
        //create pin annotation for driver
        if driverPin != nil{
            driverPin.coordinate = self.lastLocation
        }else{
            driverPin = MKPointAnnotation()
            driverPin.coordinate = self.lastLocation
            self.map.addAnnotation(driverPin)
        }
        //resume the zoom rect to cover 3 locations
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
