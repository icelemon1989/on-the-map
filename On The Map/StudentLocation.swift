//
//  StudentLocation.swift
//  On The Map
//
//  Created by Yang Ji on 8/25/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//


struct StudentLocation {
    
    //MARK: Property
    
    let objectID: String
    let student: Student
    let location: Location
    
    //MARK: Initializer
    
    init(dictionary: [String:AnyObject]) {
        
        objectID = dictionary[parseClient.JSONResponseKeys.ObjectID] as? String ?? ""
        
        //student data
        let uniqueKey = dictionary[parseClient.JSONResponseKeys.UniqueKey] as? String ?? parseClient.DefaultValues.UniqueKey
        let firstName = dictionary[parseClient.JSONResponseKeys.FirstName] as? String ?? parseClient.DefaultValues.FirstName
        let lastName = dictionary[parseClient.JSONResponseKeys.LastName] as? String ?? parseClient.DefaultValues.LastName
        let mediaURL = dictionary[parseClient.JSONResponseKeys.MediaURL] as? String ?? parseClient.JSONResponseKeys.MediaURL
        student = Student(uniqueKey: uniqueKey, FirstName: firstName, LastName: lastName, mediaURL: mediaURL)
        
        //location data
        let latitude = dictionary[parseClient.JSONResponseKeys.Latitude] as? Double ?? 0.0
        let longtitude = dictionary[parseClient.JSONResponseKeys.Longitude] as? Double ?? 0.0
        let mapString = dictionary[parseClient.JSONResponseKeys.MapString] as? String ?? parseClient.DefaultValues.MapString
        location = Location(latitude: latitude, longtitdue: longtitude, mapString: mapString)
        
    }
    
    init(student: Student, location: Location) {
        objectID = ""
        self.student = student
        self.location = location
    }
    
    init(objectID: String, student: Student, location: Location) {
        self.objectID = objectID
        self.student = student
        self.location = location
    }
    
    //MARK: Array for studentlocation
    static func locationsFromDictionaries(dictionarties: [[String: AnyObject]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        for studentDictionary in dictionarties {
            studentLocations.append(StudentLocation(dictionary: studentDictionary))
        }
        return studentLocations
    }
    
}
