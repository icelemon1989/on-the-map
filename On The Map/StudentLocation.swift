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
        
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as? String ?? ""
        
        //student data
        let uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String ?? ParseClient.DefaultValues.UniqueKey
        let firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String ?? ParseClient.DefaultValues.FirstName
        let lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String ?? ParseClient.DefaultValues.LastName
        let mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String ?? ParseClient.JSONResponseKeys.MediaURL
        student = Student(uniqueKey: uniqueKey, FirstName: firstName, LastName: lastName, mediaURL: mediaURL)
        
        //location data
        let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double ?? 0.0
        let longtitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double ?? 0.0
        let mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String ?? ParseClient.DefaultValues.MapString
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
