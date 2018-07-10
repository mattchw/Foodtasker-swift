//
//  Helpers.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 9/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation

class Helpers{
    //helper method to load image asychronously
    static func loadImage(_ imageView: UIImageView,_ urlString: String){
        let imgURL: URL = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: imgURL) { (data, response, error) in
            guard let data = data, error == nil else{return}
            
            DispatchQueue.main.async(execute: {
                imageView.image = UIImage(data: data)
            })
            }.resume()
    }
    
    //helper method to show activity indicator
    static func showActivityIndicatior(_ activityIndicator: UIActivityIndicatorView,_ view: UIView){
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.color = UIColor.black
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    //helper method to hide activity indicator
    static func hideActivityIndicatior(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.stopAnimating()
    }
}
