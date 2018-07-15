//
//  DeliveryViewController.swift
//  FoodTaskerMobile
//
//  Created by Wong Cho Hin on 14/7/2018.
//  Copyright © 2018 Wong Cho Hin. All rights reserved.
//

import UIKit

class DeliveryViewController: UIViewController {
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

}
