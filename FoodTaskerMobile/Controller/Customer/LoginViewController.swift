//
//  LoginViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 2/6/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var bLogin: UIButton!
    @IBOutlet weak var bLogout: UIButton!
    @IBOutlet weak var switchUser: UISegmentedControl!
    
    var fbLoginSuccess = false
    var userType: String = USERTYPE_CUSTOMER
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (FBSDKAccessToken.current() != nil){
            bLogout.isHidden = false
            FBManager.getFBUserData(completionHandler: {
                self.bLogin.setTitle("Continue as \(User.currentUser.email!)", for: .normal)
                //self.bLogin.sizeToFit()
                
            })
        }else{
            self.bLogout.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userType = userType.capitalized
        if(FBSDKAccessToken.current() != nil && fbLoginSuccess == true){
            performSegue(withIdentifier: "\(userType)View", sender: self)
        }
    }
    
    @IBAction func facebookLogout(_ sender: Any) {
        APIManager.shared.logout { (error) in
            if error == nil{
                FBManager.shared.logOut()
                User.currentUser.resetInfo()
                self.bLogout.isHidden = true
                self.bLogin.setTitle("Login with Facebook", for: .normal)
            }
        }
    }
    @IBAction func facebookLogin(_ sender: Any) {
        if(FBSDKAccessToken.current() != nil){
            APIManager.shared.login(userType: userType, completionHandler: { (error) in
                if error == nil {
                    self.fbLoginSuccess = true
                    self.viewDidAppear(true)
                }
            })
            
        }else{
            FBManager.shared.logIn(
                withReadPermissions: ["public_profile","email"],
                from: self) { (result, error) in
                    if (error == nil){
                        FBManager.getFBUserData(completionHandler: {
                            APIManager.shared.login(userType: self.userType, completionHandler:  { (error) in
                                if error == nil {
                                    self.fbLoginSuccess = true
                                    self.viewDidAppear(true)
                                }
                            })
                        })
                    }
            }
        }
    }
    @IBAction func switchAccount(_ sender: Any) {
        let type = switchUser.selectedSegmentIndex
        if type == 0{
            userType = USERTYPE_CUSTOMER
        }else{
            userType = USERTYPE_DRIVER
        }
    }
    
}
