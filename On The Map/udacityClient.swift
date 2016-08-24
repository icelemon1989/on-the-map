//
//  udacityClient.swift
//  On The Map
//
//  Created by Yang Ji on 8/17/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation

class udacityClient {
    
    //MARK: Properties
    
    let apiCommon : APICommon
    
    //MARK : initializer
    
    init() {
        let httpData = HTTPData(scheme: Components.Scheme, host: Components.Host, path: Components.Path, domain: Components.Domain)
        apiCommon = APICommon(httpData: httpData)
        
    }
    
    // MARK: Singleton Instance
    
    private static var sharedInstance = udacityClient()
    
    class func sharedClient() -> udacityClient {
        return sharedInstance
    }
    
    //MARK: Make request
    
    private func makeRequestForUdacity(url url:NSURL, method: HTTPMethod, headers:[String: String]? = nil, body: [String:AnyObject]? = nil, completeHandler: (jsonAsDictionary: [String: AnyObject]?, error: NSError?) -> Void) {
        
        var allHeaders = [
            HeaderKeys.Accept : HeaderValues.JSON,
            HeaderKeys.ContentType : HeaderValues.JSON
        ]
        if let headers = headers {
            for (key, value) in headers {
                allHeaders[key] = value
            }
        }
        
        apiCommon.taskForREQUESTMethod(url, method: method, header: allHeaders, body: body) { (data, error) in
            if let data = data {
                let jsonDinctionary = try! NSJSONSerialization.JSONObjectWithData(data.subdataWithRange(NSMakeRange(5, data.length - 5)), options: .AllowFragments) as! [String:AnyObject]
                completeHandler(jsonAsDictionary: jsonDinctionary, error: nil)
            } else {
                completeHandler(jsonAsDictionary: nil, error: error)
            }
        }
    }
    
    func loginWithUsername(username: String, password: String, completeHandler: (userKey: String?, error: NSError?) -> Void) {

        let loginURL = apiCommon.urlFromParameters(Methods.Session)
        let loginBody : [String: AnyObject] = [
            HTTPBodyKeys.Udacity : [
                HTTPBodyKeys.Username : username,
                HTTPBodyKeys.Password : password
            ]
        ]
        
        makeRequestForUdacity(url: loginURL, method: HTTPMethod.POST, body: loginBody) { (jsonAsDictionary, error) in
            
            if let jsonAsDictionary = jsonAsDictionary {
                
                if let status = jsonAsDictionary[JSONResponseKeys.Status] as? Int,
                    error = jsonAsDictionary[JSONResponseKeys.Error] as? String {
                    
                    completeHandler(userKey: nil, error: self.apiCommon.errorWithStatus(status, description: error))
                    return
                }
                if let account = jsonAsDictionary[JSONResponseKeys.Account] as? [String: AnyObject] {
                    if let key = account[JSONResponseKeys.UserKey] as? String {
                        completeHandler(userKey: key, error: nil)
                        return
                    }
                }
            }
            
            // catch-all error case
            completeHandler(userKey: nil, error: self.apiCommon.errorWithStatus(0, description: Errors.UnableToLogin))
            
        }

    }
    
    //MARK: Logout
    
    func logout(CompleteHandler:(sucess: Bool?, error: NSError?) -> Void) {
        
        //create Method: https://www.udacity.com/api/session
        //Method Type: DELETE
        let logoutURL = apiCommon.urlFromParameters(Methods.Session)
        var logoutHeaders = [String:String]()
        if let xsrfCookie = apiCommon.cookieForName(Cookies.XSRFToken) {
            logoutHeaders[HeaderKeys.XSRFToken] = xsrfCookie.value
        }
        makeRequestForUdacity(url: logoutURL, method: .DELETE) { (jsonAsDictionary, error) in
            if let error = error {
                CompleteHandler(sucess: false, error: error)
            } else {
                if (jsonAsDictionary![JSONResponseKeys.Session] as? [String: AnyObject]) != nil {
                    CompleteHandler(sucess: true, error: nil)
                }
            }
        }
    }
    
    // MARK: GET Student Data  
    
    func studentWithUserKey(userKey: String, completeHandler:(student: Student?, error: NSError?) -> Void) {
        
        let studentDataURL = apiCommon.urlFromParameters(Methods.Users, withPathExtension: "/\(userKey)")
        
        makeRequestForUdacity(url: studentDataURL, method: .GET) { (jsonAsDictionary, error) in
            if let error = error {
                completeHandler(student: nil, error: error)
            } else {
                //success
                if let dic = jsonAsDictionary {
                    guard let user = dic[JSONResponseKeys.User] as? [String: AnyObject] else {
                        print("no found \(JSONResponseKeys.User) in \(dic)")
                        return
                    }
                    guard let first = user[JSONResponseKeys.FirstName] as? String else {
                        print("no found \(JSONResponseKeys.FirstName) in \(user)")
                        return
                    }
                    guard let last = user[JSONResponseKeys.LastName] as? String else {
                        print("no found \(JSONResponseKeys.LastName) in \(user)")
                        return
                    }
                    let student = Student(uniqueKey: userKey, FirstName: first, LastName: last, mediaURL: "")
                    completeHandler(student: student, error: nil)
                }
                
            }
        }
        
    }
    
    
}
