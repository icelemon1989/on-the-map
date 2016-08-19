//
//  LoginViewController.swift
//  On The Map
//
//  Created by Yang Ji on 8/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: IBOutlet
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    
    // MARK: Properties
    private let UdacityClient = udacityClient.sharedClient()
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: Action
    @IBAction func udacityLoginButtonPressed(sender: boardedButton) {
        //TODO: login activity
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            //TODO: improve debug
            debugLabel.text = "missing email or password"
        } else {
            UdacityClient.loginWithUsername(emailTextField.text!, password: passwordTextField.text!, completeHandler: { (userKey, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let key = userKey {
                        self.debugLabel.text = key
                    } else {
                        print(error)
                        self.debugLabel.text = error?.localizedDescription
                    }
                }
            })
        }
        
    }

    @IBAction func signUpButtonPressed(sender: UIButton) {
        //TODO: sign up activity
    }
}

