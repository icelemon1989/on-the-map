//
//  parseClient.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

class ParseClient{
    
    //MARK: Property
    let apiCommon : APICommon
    
    //MARK: Initializer
    init () {
        let httpData = HTTPData(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: Errors.Domain)
        apiCommon = APICommon(httpData: httpData)
    }
    
    //MARK: Singleton Instance
    private static let shareInstance = ParseClient()
    class func sharedClient() -> ParseClient {
        return shareInstance
    }
    
    //MARK: Make Request
    
    private func makeRequestForParse(url url:NSURL, method: HTTPMethod, body: [String: AnyObject]? = nil, completeHandle:(jsonAsDictionary: [String:AnyObject]?, error : NSError?) -> Void) {
        
        let headers = [
            HeaderKeys.APIKey: HeaderValue.APIKey,
            HeaderKeys.AppID: HeaderValue.AppID,
            HeaderKeys.ContentType: HeaderValue.JSON,
            HeaderKeys.Accept: HeaderValue.JSON
        ]
        
        apiCommon.taskForREQUESTMethod(url, method: method, header: headers, body: body) { (data, error) in
            if let data = data {
                let jsonDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
                completeHandle(jsonAsDictionary: jsonDictionary, error: nil)
            } else {
                print("error in taskForRequestMethod is \(error)")
                completeHandle(jsonAsDictionary: nil, error: error)
            }
        }
    }
    
    
    // MARK: GET Student Locations
    
    func studentLocations(completeHandler: (studentlocations: [StudentLocation]?, error: NSError?) -> Void) {
        
        let OptionalParameters: [String: AnyObject] = [
            ParametersKey.Limit: ParametersValue.OneHundred,
            ParametersKey.Order: ParametersValue.MostRecentlyUpdated
        ]
        
        let studentlocationsURL = apiCommon.urlFromParameters(Methods.StudentLocation, parameters: OptionalParameters)
        
        makeRequestForParse(url: studentlocationsURL, method: HTTPMethod.GET) { (jsonAsDictionary, error) in
            
            guard error == nil else {
                completeHandler(studentlocations: nil, error: error)
                return
            }
            
            if let jsonDicionary = jsonAsDictionary,
                let results = jsonDicionary[JSONResponseKeys.Results] as? [[String: AnyObject]] {
                let locations = StudentLocation.locationsFromDictionaries(results)
                completeHandler(studentlocations: locations, error: nil)
                return
            }
        
            completeHandler(studentlocations: nil, error: self.apiCommon.errorWithStatus(0, description: Errors.NoRecords))
            
        }
    }
    
    //MARK: GET Current Student Location
    func studentLocationWithUserKey(userKey: String, completeHandler:(location: StudentLocation?, error: NSError?) -> Void) {
        
        let parameters =
        [
            ParametersKey.Where : "{\"" + "\(ParametersKey.UniqueKey)" + "\":\"" + "\(userKey)" + "\"}"
        ]
        
        let studentLocationURL = apiCommon.urlFromParameters(Methods.StudentLocation, parameters: parameters)
        print("Get a student location url:" + "\(studentLocationURL)")
        
        makeRequestForParse(url: studentLocationURL, method: HTTPMethod.GET) { (jsonAsDictionary, error) in
            
            guard error == nil else {
                completeHandler(location: nil, error: error)
                return
            }
            
            if let jsonAsDictionary = jsonAsDictionary,
                let studentDictionaries = jsonAsDictionary[JSONResponseKeys.Results] as? [[String:AnyObject]] {
                if studentDictionaries.count == 1 {
                    completeHandler(location: StudentLocation(dictionary: studentDictionaries[0]), error: nil)
                    return
                }
            }
            
            completeHandler(location: nil, error: self.apiCommon.errorWithStatus(0, description: Errors.NoRecordAtKey))
        }
    }
    
    // MARK: update an existing student post(revised)
    func hackyPUT(mediaURL: String, studentLocation: StudentLocation, objectID: String, completeHandler: (success: Bool, error: NSError?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation/" + objectID)!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body :[String: AnyObject] = [:]
        body["latitude"] = studentLocation.location.latitude
        body["longitude"] = studentLocation.location.longtitdue
        body["firstName"] = studentLocation.student.FirstName
        body["lastName"] = studentLocation.student.LastName
        body["uniqueKey"] = studentLocation.student.uniqueKey
        body["mediaURL"] = mediaURL
        body["mapString"] = studentLocation.location.mapString
        
        print ("URL", request)
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
        //        request.HTTPBody = "{\"uniqueKey\": \"4653568580\", \"firstName\": \"Yang\", \"lastName\": \"Ruan\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://www.wawa.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
        
        print ("request HTTPBody ++++++++++++++++++", request.HTTPBody)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completeHandler(success: false, error: error)
            }
            
            if let data = data {
                let jsonAsDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
                // success
                if let _ = jsonAsDictionary[ParseClient.JSONResponseKeys.UpdatedAt] {
                    completeHandler(success: true, error: nil)
                    return
                }
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            completeHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    //MARK: Post a new student(reversion)
    func hackyPost(mediaURL: String, studentLocation: StudentLocation, completeHandler:(success: Bool, error: NSError?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body :[String: AnyObject] = [:]
        body["latitude"] = studentLocation.location.latitude
        body["longitude"] = studentLocation.location.longtitdue
        body["firstName"] = studentLocation.student.FirstName
        body["lastName"] = studentLocation.student.LastName
        body["uniqueKey"] = studentLocation.student.uniqueKey
        body["mediaURL"] = mediaURL
        body["mapString"] = studentLocation.location.mapString
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
        //request.HTTPBody = "{\"uniqueKey\": \"4653568580\", \"firstName\": \"Yang\", \"lastName\": \"Ruan\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://www.wawa.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)
        
        print ("request HTTPBody ++++++++++++++++++", request.HTTPBody)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completeHandler(success: false, error: error)
            }
            
            if let data = data {
                let jsonAsDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
                // success
                if let _ = jsonAsDictionary[ParseClient.JSONResponseKeys.CreatedAt] {
                    completeHandler(success: true, error: nil)
                    return
                }
            }
            completeHandler(success: true, error: nil)
        }
        task.resume()
    }


    
    // MARK: POST Student Location(new student)
    func postStudentLocation(mediaURL: String, studentLocation: StudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let studentLocationURL = apiCommon.urlFromParameters(Methods.StudentLocation)
        let studentLocationBody: [String:AnyObject] = [
            BodyKeys.UniqueKey: studentLocation.student.uniqueKey,
            BodyKeys.FirstName: studentLocation.student.FirstName,
            BodyKeys.LastName: studentLocation.student.LastName,
            BodyKeys.MapString: studentLocation.location.mapString,
            BodyKeys.MediaURL: mediaURL,
            BodyKeys.Latitude: studentLocation.location.latitude,
            BodyKeys.Longitude: studentLocation.location.longtitdue
        ]
        print("new studentLocationBody is \(studentLocationBody)")
        
        makeRequestForParse(url: studentLocationURL, method: .POST, body: studentLocationBody) { (jsonAsDictionary, error) in
            guard error == nil else {
                print("error in makeRequestForParse function is \(error)")
                completionHandler(success: false, error: error)
                return
            }
            
            // success
            if let jsonAsDictionary = jsonAsDictionary,
                let _ = jsonAsDictionary[JSONResponseKeys.CreatedAt] as? String {
                completionHandler(success: true, error: nil)
                print("success posting a new student mediaURL")
                return
            }
            
//            // known failure
//            if let jsonAsDictionary = jsonAsDictionary,
//                let error = jsonAsDictionary[JSONResponseKeys.Error] as? String {
//                print("jsonAsDictionary is \(jsonAsDictionary)")
//                print("error in jsonAsDictionary: \(error)")
//                completionHandler(success: true, error: self.apiCommon.errorWithStatus(0, description: error))
//                return
//            }
            // unknown failure
            completionHandler(success: false, error: self.apiCommon.errorWithStatus(0, description: Errors.CouldNotPostLocation))
        }
        
    }
    
    // MARK: PUT Student Location(update existing student)
    func updateStudentLocationWithObjectID(objectID: String, mediaURL: String, studentLocation: StudentLocation, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        let studentLocationURL = apiCommon.urlFromParameters(Methods.StudentLocation, withPathExtension: "/\(objectID)")
        print("studentLocationURL is \(studentLocationURL)")
        let studentLocationBody : [String: AnyObject] = [
            BodyKeys.UniqueKey: studentLocation.student.uniqueKey,
            BodyKeys.FirstName: studentLocation.student.FirstName,
            BodyKeys.LastName: studentLocation.student.LastName,
            BodyKeys.MapString: studentLocation.location.mapString,
            BodyKeys.MediaURL: mediaURL,
            BodyKeys.Latitude: studentLocation.location.latitude,
            BodyKeys.Longitude: studentLocation.location.longtitdue
        ]
        print("posting an existing student studentLocationbody: \(studentLocationBody)")
        
        makeRequestForParse(url: studentLocationURL, method: .PUT, body: studentLocationBody) { (jsonAsDictionary, error) in
            guard error == nil else {
                completionHandler(success: false, error: error)
                return
            }
            // success
            if let jsonAsDictionary = jsonAsDictionary,
                let _ = jsonAsDictionary[JSONResponseKeys.UpdatedAt] {
                completionHandler(success: true, error: nil)
                return
            }
            
            // known failure
            if let jsonAsDictionary = jsonAsDictionary,
                let error = jsonAsDictionary[JSONResponseKeys.Error] as? String {
                completionHandler(success: true, error: self.apiCommon.errorWithStatus(0, description: error))
                return
            }
            
            // unknown failure
            completionHandler(success: false, error: self.apiCommon.errorWithStatus(0, description: Errors.CouldNotUpdateLocation))
        }
    }
}
    
