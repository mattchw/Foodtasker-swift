//
//  PaymentViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 14/5/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func placeOrder(_ sender: Any) {
        APIManager.shared.getLatestOrder { (json) in
            if json["order"]["status"] == nil || json["order"]["status"] == "Delivered"{
                //process the payment
                let card = self.cardTextField.cardParams
                STPAPIClient.shared().createToken(withCard: card, completion: { (token, error) in
                    if let myError = error {
                        print("Error: ", myError)
                    }else if let stripeToken = token{
                        APIManager.shared.createOrder(stripeToken: stripeToken.tokenId, completionHandler: { (json) in
                            Tray.currentTray.reset()
                            self.performSegue(withIdentifier: "ViewOrder", sender: self)
                        })
                    }
                })
            }else{
                //show alert
                let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                let okAction = UIAlertAction(title: "Go to order", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "ViewOrder", sender: self)
                })
                let alertView = UIAlertController(title: "Already order?", message: "Your current order isn't completed", preferredStyle: .alert)
                alertView.addAction(okAction)
                alertView.addAction(cancelAction)
                
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
}
