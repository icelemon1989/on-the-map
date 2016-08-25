//
//  parseConstant.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

extension parseClient {
    
    //MARK: Components
    struct Components {
        static let Scheme = "https"
        static let Host = "parse.udacity.com"
        static let Path = "/parse/classes"
    }
    
    //MARK: Methods
    
    struct Methods {
        static let StudentLocation = "/StudentLocation"
    }
    
    //MARK: HeaderKeys
    
    struct HeaderKeys {
        static let AppID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
    }
    
    //MARK: HeaderValue
    
    struct HeaderValue {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: JSONResponseKeys
    
    struct JSONResponseKeys {
        static let Error = "error"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
    }
    
    // MARK: DefaultValues
    
    struct DefaultValues {
        static let ObjectID = "[No Object ID]"
        static let UniqueKey = "[No Unique Key]"
        static let FirstName = "[No First Name]"
        static let LastName = "[No Last Name]"
        static let MediaURL = "[No Media URL]"
        static let MapString = "[No Map String]"
    }
    
    //MARK: Error
    struct Errors {
        static let Domain = "ParseClient"
    }
}