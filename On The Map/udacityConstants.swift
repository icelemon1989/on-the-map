//
//  udacityConstants.swift
//  On The Map
//
//  Created by Yang Ji on 8/19/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

//MARK: udacityClient extension

import Foundation

extension udacityClient {
    
    // MARK: Components
    
    struct Components {
        static let Scheme = "https"
        static let Host = "www.udacity.com"
        static let Path = "/api"
        static let Domain = "UdacityClient"
    }
    
    // MARK: HeaderKeys
    
    struct HeaderKeys {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        static let XSRFToken = "X-XSRF-TOKEN"
    }
    
    // MARK: HeaderValues
    
    struct HeaderValues {
        static let JSON = "application/json"
    }
    
    // MARK: Methods
    
    struct Methods {
        static let Session = "/session"
        static let Users = "/users"
    }
    
    // MARK: HTTPBodyKeys
    
    struct HTTPBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSONResponseKeys
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let UserKey = "key"
        static let Status = "status"
        static let Session = "session"
        static let Error = "error"
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
    
    // MARK: Errors
    
    struct Errors {
        static let Domain = "UdacityClient"
        static let UnableToLogin = "Unable to login. The internet is disconnected."
        static let UnableToLogout = "Unable to logout."
        static let NoUserData = "Cannot access user data."
    }
    
    //MARK: Common
    
    struct Common {
        static let signUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    // MARK: Cookies
    
    struct Cookies {
        static let XSRFToken = "XSRF-TOKEN"
    }

}