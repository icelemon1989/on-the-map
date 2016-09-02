//
//  parseClient.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

class parseClient{
    
    //MARK: Property
    let apiCommon : APICommon
    
    //MARK: Initializer
    init () {
        let httpData = HTTPData(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: Errors.Domain)
        apiCommon = APICommon(httpData: httpData)
    }
    
    //MARK: Singleton Instance
    private static let shareInstance = parseClient()
    class func sharedClient() -> parseClient {
        return shareInstance
    }
    
    //MARK: Make Request
    
    private func makeRequestForParse(url url:NSURL, method: HTTPMethod, body: [String: AnyObject]? = nil, completeHandle:(jsonAsDictionary: [String:AnyObject]?, error : NSError?) -> Void) {
        
        let headers = [
            HeaderKeys.APIKey: HeaderValue.APIKey,
            HeaderKeys.AppID: HeaderValue.AppID,
        ]
        
        apiCommon.taskForREQUESTMethod(url, method: method, header: headers, body: body) { (data, error) in
            if let data = data {
                let jsonDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
                completeHandle(jsonAsDictionary: jsonDictionary, error: nil)
            } else {
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
    
}