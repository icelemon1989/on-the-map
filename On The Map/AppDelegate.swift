//
//  AppDelegate.swift
//  On The Map
//
//  Created by Yang Ji on 8/9/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Ensures proper use of the Facebook SDK
        return facebookClient.setupWithOptions(application, launchOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // Handle interaction with the native Facebook app or Safari as part of SSO authorization flow or Facebook dialogs
        return facebookClient.processURL(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Notifies the Facebook SDK events system that the app has launched and, when appropriate, logs an "activated app" event
        facebookClient.activeApp()
    }

}

