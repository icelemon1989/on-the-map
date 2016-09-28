//
//  LoginViewController.swift
//  On The Map
//
//  Created by Yang Ji on 8/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    //MARK: IBOutlet
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var udacityImage: UIImageView!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    // MARK: Properties
    private var keyboardOnScreen = false
    
    private let udacityClient = UdacityClient.sharedClient()
    private let otmSharedData = SharedData.sharedDataSource()
    private let facebookClient = FacebookClient.sharedClient()
    
    //MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        subscribeNotification()
        
        facebookClient.logout()
        
        facebookLoginButton.readPermissions = ["public_profile"]
        facebookLoginButton.delegate = self
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    private func subscribeNotification() {
        subscribeToNotification(UIKeyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIKeyboardWillHideNotification, selector: #selector(keyboardWillHide))
        subscribeToNotification(UIKeyboardDidShowNotification, selector: #selector(keyboardDidShow))
        subscribeToNotification(UIKeyboardDidHideNotification, selector: #selector(keyboardDidHide))
    }

    //MARK: Action
    @IBAction func udacityLoginButtonPressed(sender: boardedButton) {
        //TODO: login activity
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            //TODO: improve debug
            debugLabel.text = "missing email or password"
        } else {
            udacityClient.loginWithUsername(emailTextField.text!, password:passwordTextField.text! , completeHandler: { (userKey, error) in
                performUIUpdatesOnMain({
                    if let userKey = userKey {
                        self.getStudentData(userKey)
                    } else {
                        self.alertWithError(error!.localizedDescription)
                    }
                })
            })
        }
    }
    
    
    //MARK: Get Student Data
    private func getStudentData(userKey: String) {
        udacityClient.studentWithUserKey(userKey) { (student, error) in
            performUIUpdatesOnMain({
                if let student = student {
                    self.otmSharedData.currentStudent = student
                    self.login()
                } else {
                    print(error)
                    self.debugLabel.text = error?.localizedDescription
                }
            })
        }
    }
    
    

    @IBAction func signUpButtonPressed(sender: UIButton) {
        if let signUpURL = NSURL(string: UdacityClient.Common.signUpURL) where UIApplication.sharedApplication().canOpenURL(signUpURL) {
            UIApplication.sharedApplication().openURL(signUpURL)
        }
    }
    
    private func login() {
        performSegueWithIdentifier("login", sender: self)
    }
    
    // MARK: Display Error Alert
    
    private func alertWithError(error: String) {
        
        let alertView = UIAlertController(title: AppConstant.Alert.LoginTitle, message: error, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: AppConstant.AlertActions.Dismiss, style: .Cancel, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
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

extension LoginViewController : FBSDKLoginButtonDelegate {
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        if facebookClient.currentAccessToken() == nil {
            emailTextField.text = ""
            passwordTextField.text = ""
        }
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        func displayError(error: String) {
            self.facebookClient.logout()
            debugLabel.text = error
        }
        
        if let token = result.token.tokenString {
            udacityClient.loginWithFacebookToken(token) { (userKey, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    if let userKey = userKey {
                        self.getStudentData(userKey)
                    } else {
                        displayError(error!.localizedDescription)
                    }
                }
            }
        } else if result.isCancelled {
            print(" login cancelled")
            
        }else {
            displayError(error!.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("FB log out")
    }
}

