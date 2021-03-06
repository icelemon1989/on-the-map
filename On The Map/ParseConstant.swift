//
//  parseConstant.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

extension ParseClient {
    
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
    
    //MARK: Parameters Key
    
    struct ParametersKey {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let UniqueKey = "uniqueKey"
    }
    
    //MARK: Parameters Value
    struct ParametersValue {
        static let OneHundred = 100
        static let TwoHundred = 200
        static let MostRecentlyUpdated = "-updatedAt"
        static let MostRecentlyCreated = "-createdAt"
    }
    
    //MARK: HeaderKeys
    
    struct HeaderKeys {
        static let AppID = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let Accept = "Accept"
        static let ContentType = "ContentType"
    }
    
    //MARK: HeaderValue
    
    struct HeaderValue {
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let JSON = "application/json"
    }
    
    // MARK: JSONResponseKeys
    
    struct JSONResponseKeys {
        static let Error = "error"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        static let CreatedAt = "createdAt"
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
        static let NoRecords = "NoRecords"
        static let NoRecordAtKey = "No object record at userkey."
        static let CouldNotUpdateLocation = "Student location could not be updated."
        static let CouldNotPostLocation = "Student location could not be posted."
    }
    
    // MARK: Notifications
    
    struct Notifications {
        static let LocationsUpdated = "Updated"
        static let LocationsUpdatedError = "UpdatedError"
    }
    
    // MARK: BodyKeys
    
    struct BodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
    }
}