//
//  FBManager.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 2/6/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftyJSON

class FBManager{
    static let shared = FBSDKLoginManager()
    public class func getFBUserData(completionHandler: @escaping ()-> Void){
        if (FBSDKAccessToken.current() != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, picture.type(normal)"]).start { (connection, result, error) in
                if(error == nil){
                    let json = JSON(result!)
                    print(json)
                    
                    User.currentUser.setInfo(json: json)
                    
                    completionHandler()
                }
            }
        }
    }
}
