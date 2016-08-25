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
    
    
    
}