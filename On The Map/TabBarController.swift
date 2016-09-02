//
//  TabBarController.swift
//  On The Map
//
//  Created by Yang Ji on 8/24/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    //MARK: Property
    
    let UdacityClient = udacityClient.sharedClient()
    let otmSharedData = SharedData.sharedDataSource()
    let ParseClient = parseClient.sharedClient()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.studentLocationUpdateError), name: "\(parseClient.Methods.StudentLocation)\(parseClient.Notifications.LocationsUpdatedError)", object: nil)
    }
    
    //MARK: Actions
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        
        UdacityClient.logout { (sucess, error) in
            performUIUpdatesOnMain({
                self.dismissViewControllerAnimated(true, completion: nil)
                print("log out success!")
            })
        }
        
    }
    
    @IBAction func refreshButtonPressed(sender: UIBarButtonItem) {
        otmSharedData.refreshStudentLocations()
    }

    @IBAction func postStudentLocation(sender: UIBarButtonItem) {
        //To check if I already have post a link, if do, ask if I want to overwirte,
        //if not, post a new
        if let currentStudent = otmSharedData.currentStudent {
            ParseClient.studentLocationWithUserKey(currentStudent.uniqueKey, completeHandler: { (location, error) in
                performUIUpdatesOnMain({
                    if let location = location {
                        self.displayOverWriteAlert({ (alert) in
                            self.launchPostingModal(location.objectID)
                        })
                        
                    } else {
                        self.launchPostingModal()
                    }
                })
            })
        }
    }
    
    //MARK: Data Source
    func studentLocationUpdateError() {
        displayErrorAlert(AppConstant.Errors.CouldNotUpdateStudentLocations)
    }

    //MARK: Display Alert
    
    private func displayErrorAlert(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: AppConstant.AlertActions.Dismiss, style: .Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
        
    }
    
    private func displayOverWriteAlert(completeHandler:((UIAlertAction)->Void)? = nil) {
        let alertView = UIAlertController(title: AppConstant.Alert.OverwriteTitle, message: AppConstant.Alert.OverwriteMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(UIAlertAction(title: AppConstant.AlertActions.Overwrite, style: UIAlertActionStyle.Default, handler: completeHandler))
        alertView.addAction(UIAlertAction(title: AppConstant.AlertActions.Cancel, style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
        
    }
    
    //MARK: Lauch Posting View Controller
    private func launchPostingModal(objectID: String? = nil) {
        let reuseStoryboardID = "OTMPostingViewController"
        let postingVC = self.storyboard?.instantiateViewControllerWithIdentifier(reuseStoryboardID) as! PostingViewController
        if let objectID = objectID {
            postingVC.objectID = objectID
        }
        self.presentViewController(postingVC, animated: true, completion: nil)
    }
}
