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
    @IBOutlet weak var udacityImage: UIImageView!
    
    // MARK: Properties
    private var keyboardOnScreen = false
    
    private let UdacityClient = udacityClient.sharedClient()
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    //MARK: Action
    @IBAction func udacityLoginButtonPressed(sender: boardedButton) {
        //TODO: login activity
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            //TODO: improve debug
            debugLabel.text = "missing email or password"
        } else {
            UdacityClient.loginWithUsername(emailTextField.text!, password: passwordTextField.text!, completeHandler: { (userKey, error) in
                performUIUpdatesOnMain({
                    if let key = userKey {
                        self.debugLabel.text = key
                        print(key)
                        //TODO: retrieve data successfully NEXT pass to map and tableview
                        self.UdacityClient.studentWithUserKey(key, completeHandler: { (student, error) in
                            print("key")
                            performUIUpdatesOnMain({
                                self.login()
                            })
                        })
                    } else {
                        print(error)
                        self.debugLabel.text = error?.localizedDescription
                    }
                })
            })
        }
        
    }
    
    

    @IBAction func signUpButtonPressed(sender: UIButton) {
        if let signUpURL = NSURL(string: udacityClient.Common.signUpURL) where UIApplication.sharedApplication().canOpenURL(signUpURL) {
            UIApplication.sharedApplication().openURL(signUpURL)
        }
    }
    
    private func login() {
        performSegueWithIdentifier("login", sender: self)
    }
    
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController : UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            udacityImage.hidden = true
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
            udacityImage.hidden = false
    
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    private func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTap(sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

