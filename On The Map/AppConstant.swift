//
//  AppConstant.swift
//  On The Map
//
//  Created by Yang Ji on 8/29/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

struct AppConstant {
    
    //MARK: Alert
    struct Alert {
        static let OverwriteTitle = "Overwrite Location?"
        static let OverwriteMessage = "You've already posted a pin. Would you like to overwrite it?"
        static let LoginTitle = "Login Error"
    }
    
    //MARK: AlertActions
    
    struct AlertActions {
        static let Cancel = "Cancel"
        static let Dismiss = "Dismiss"
        static let Overwrite = "Overwrite"
    }
    
    //MARK: Errors
    struct Errors {
        static let CannotOpenURL = "Cannot open URL."
        static let CouldNotUpdateStudentLocations = "Could not update student locations."
        static let LocationStringEmpty = "Please enter your location."
        static let CouldNotGeocode = "Could not geocode the location input string."
        static let NoLocationFound = "Could not find the location"
        static let LinkStringEmpty = "Please enter your media link."
        static let StudentAndPlacemarkEmpty = "Student and placemark not initialized."
        static let PostStudentLocationFailed = "Student location could not be posted."
    }
}
