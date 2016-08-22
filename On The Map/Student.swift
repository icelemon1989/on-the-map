//
//  Student.swift
//  On The Map
//
//  Created by Yang Ji on 8/22/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

struct Student {
    
    //MARK: Properties
    
    let uniqueKey : String
    let FirstName : String
    let LastName : String
    var mediaURL : String
    var FullName : String {
        return "\(FirstName) \(LastName)"
    }
    
    //MARK: Initializers
    
    init (uniqueKey: String) {
        self.uniqueKey = uniqueKey
        FirstName = ""
        LastName = ""
        mediaURL = ""
        
    }
    
    init(uniqueKey: String, FirstName: String, LastName: String, mediaURL: String) {
        self.uniqueKey = uniqueKey
        self.FirstName = FirstName
        self.LastName = LastName
        self.mediaURL = mediaURL
    }
    
}
