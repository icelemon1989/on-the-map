//
//  APICommon.swift
//  On The Map
//
//  Created by Yang Ji on 8/17/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import Foundation


//MARK: - HTTPMethod Enum

enum HTTPMethod : String {
    case GET, POST, PUT, DELETE
}

//MARK: - HTTP DATA

struct HTTPData {
    let scheme: String
    let host: String
    let path: String
    let domain: String
}

//MARK: - API Common

class APICommon {
    
    // MARK: Properties
    
    private let session: NSURLSession!
    private let httpData : HTTPData
    
    // MARK: Initializers
    
    init(httpData: HTTPData) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        // allow for adjusting of default configuration...
        
        self.session = NSURLSession(configuration: configuration)
        self.httpData = httpData
    }
    
    //MARK: Request Function
    
    func taskForREQUESTMethod(url: NSURL, method: HTTPMethod, header : [String: String]? = nil, body: [String:AnyObject]? = nil, completeHandler:(NSData?, NSError?) -> Void) {
        
        //create request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
        
        //add header if any
        if let header = header {
            for (key, value) in header {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        //add body if any
        if let body = body {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
        }
        
        //create task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // was there an error?
            if let error = error {
                completeHandler(nil, error)
                return
            }
            
            // did we get a successful 2XX response?
            if let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode < 200 && statusCode > 299 {
                let userInfo = [
                    NSLocalizedDescriptionKey: "Unsuccessful response out range of 200 to 299."
                ]
                let error = NSError(domain: "APISession", code: statusCode, userInfo: userInfo)
                completeHandler(nil, error)
                return
            }
            
            if let data = data {
                completeHandler(data, nil)
                return
            }
            
        }
        task.resume()
    }

    //MARK: URLs
    
    func urlFromParameters(method: String?, withPathExtension: String? = nil, parameters: [String: AnyObject]? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = httpData.scheme
        components.host = httpData.host
        components.path = httpData.path + (method ?? "") + (withPathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [NSURLQueryItem]()
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        print("url is \(components.URL)")
        return components.URL!
    }
    
    // MARK: Errors
    
    func errorWithStatus(status: Int, description: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "APICommon", code: status, userInfo: userInfo)
    }
    
    //MARK: Cookies
    
    func cookieForName(name: String) -> NSHTTPCookie? {
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == name {
                return cookie
            }
        }
        return nil
    }
}
