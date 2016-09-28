//
//  SharedData.swift
//  On The Map
//
//  Created by Yang Ji on 8/29/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

class SharedData: NSObject {
    
    //MARK: Properties
    
    private let parseClient = ParseClient.sharedClient()
    var studentLocations = [StudentLocation]()
    var currentStudent : Student? = nil
    
    //MARK: Initializer
    override init() {
        super.init()
    }
    
    //MARK: Singleton Instance
    
    private static var shareInstance = SharedData()
    
    class func sharedDataSource() -> SharedData {
        return shareInstance
    }
    
    //MARK: Notification
    
    private func sentDataNotification(notificationName: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil)
    }
    
    //MARK: Refresh Student Locations
    
    func refreshStudentLocations() {
        parseClient.studentLocations { (studentlocations, error) in
            if error != nil {
                print("errorrrrrrrrrrrrrr")
                self.sentDataNotification("\(ParseClient.Methods.StudentLocation)\(ParseClient.Notifications.LocationsUpdatedError)")
            }
            
            if let students = studentlocations {
                self.studentLocations = students
                self.sentDataNotification("\(ParseClient.Methods.StudentLocation)\(ParseClient.Notifications.LocationsUpdated)")
                print("refreshed studentlocations")
            }
        }
    }
}


