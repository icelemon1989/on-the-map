//
//  facebookClient.swift
//  On The Map
//
//  Created by Yang Ji on 9/21/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class facebookClient {
    // MARK: Properties
    
    private let loginManager = FBSDKLoginManager()
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = facebookClient()
    
    class func sharedClient() -> facebookClient {
        return sharedInstance
    }
    
    // MARK: Class Functions
    
    class func activeApp() {
        // Notifies the Facebook SDK events system that the app has launched and, when appropriate, logs an "activated app" event
        FBSDKAppEvents.activateApp()
    }
    
    class func setupWithOptions(application: UIApplication, launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Ensures proper use of the Facebook SDK
        FBSDKSettings.setAppURLSchemeSuffix(facebookClient.Common.URLSuffix)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    class func processURL(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        // Handle interaction with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs
        if url.scheme == facebookClient.Common.URLScheme {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        } else {
            return true
        }
    }
    
    // MARK: Access Token
    
    func currentAccessToken() -> FBSDKAccessToken! {
        return FBSDKAccessToken.currentAccessToken()
    }
    
    // MARK: Logout
    
    func logout() {
        loginManager.logOut()
    }

}