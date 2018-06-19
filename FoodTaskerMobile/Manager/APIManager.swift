//
//  APIManager.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 8/6/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class APIManager{
    static let shared = APIManager()
    
    let baseURL = NSURL (string: BASE_URL)
    var accessToken = ""
    var refreshToken = ""
    var expired = Date()
    
    //API to login an user
    func login(userType: String, completionHandler: @escaping (NSError?) -> Void){
        let path = "api/social/convert-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "grant_type":"convert_token",
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "backend": "facebook",
            "token": FBSDKAccessToken.current().tokenString,
            "user_type": userType
        ]
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let jsonData = JSON(value)
                self.accessToken = jsonData["access_token"].string!
                self.refreshToken = jsonData["refresh_token"].string!
                self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                
                completionHandler(nil)
                break
                
            case .failure(let error):
                completionHandler(error as NSError?)
                break
            }
        }
    }
    //API to logout an user
    func logout(completionHandler: @escaping (NSError?) -> Void){
        let path = "api/social/revoke-token/"
        let url = baseURL!.appendingPathComponent(path)
        let params: [String: Any] = [
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "token": self.accessToken
        ]
        
        Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseString { (response) in
            switch response.result{
            case .success:
                completionHandler(nil)
                break
                
            case .failure(let error):
                completionHandler(error as NSError?)
                break
            }
        }
    }
    
    //API to refresh the token when it's expired
    func refreshTokenIfNeed(completionHandler: @escaping () -> Void){
        let path = "api/social/refresh-token/"
        let url = baseURL?.appendingPathComponent(path)
        let params:[String: Any] = [
            "access_token": self.accessToken,
            "refresh_token": self.refreshToken
        ]
        if(Date() > self.expired){
            Alamofire.request(url!, method: .post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let jsonData = JSON(value)
                    self.accessToken = jsonData["access_token"].string!
                    self.expired = Date().addingTimeInterval(TimeInterval(jsonData["expires_in"].int!))
                    completionHandler()
                    break
                    
                case .failure:
                    break
                }
            }
        } else {
            completionHandler()
        }
    }
    
    //API getting restaurant list
    func getRestaurants(completionHandler: @escaping (JSON) -> Void){
        let path = "api/customer/restaurants/"
        let url = baseURL?.appendingPathComponent(path)
        refreshTokenIfNeed {
            Alamofire.request(url!, method: .get, parameters: nil, encoding: URLEncoding(), headers: nil).responseJSON(completionHandler: { (response) in
                switch response.result{
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                    
                case .failure:
                    completionHandler(nil)
                    break
                }
            })
        }
    }
    
}
