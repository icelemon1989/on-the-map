//
//  TabBarController.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    //MARK: Property
    let UdacityClient = udacityClient.sharedClient()
    
    //MARK: Actions
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        
        UdacityClient.logout { (sucess, error) in
            performUIUpdatesOnMain({
                self.dismissViewControllerAnimated(true, completion: nil)
                print("log out success!")
            })
        }
        
    }
    

}
