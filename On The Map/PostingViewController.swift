//
//  PostingViewController.swift
//  On The Map
//
//  Created by Yang Ji on 9/2/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController {
    
    //MARK: LoginState
    
    private enum PostingState {
        case InputLocation, InputLink
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var PostingMapView: MKMapView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var PromptLabel: UILabel!
    @IBOutlet weak var inputLocationTextField: UITextField!
    @IBOutlet weak var inputLinkTextField: UITextField!
    @IBOutlet weak var findMapButton: UIButton!

    //MARK: Properties
    
    private let omtDataSource : SharedData = SharedData.sharedDataSource()
    private let UdaictyClient : udacityClient = udacityClient.sharedClient()
    private let ParseClient : parseClient = parseClient.sharedClient()
    var objectID: String? = nil
    private var placemark: CLPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI(.InputLocation)
    }
    
    @IBAction func findMapButtonPressed(sender: UIButton) {
        if findMapButton.currentTitle == "Find on Map" {
            configureUI(.InputLink)
            //check for empty string
            if inputLocationTextField.text!.isEmpty {
                displayAlert(AppConstant.Errors.LocationStringEmpty)
            }
            //add placemark
            self.addPlacemark()
            
        } else {//"Submit" button to posting a mediaURL
            
            //check if empty string
            if inputLinkTextField.text!.isEmpty {
                displayAlert(AppConstant.Errors.LinkStringEmpty)
            }
            // check if student and placemark initialized
            guard let student = omtDataSource.currentStudent,
                let placemark = placemark,
                let postedLocation = placemark.location else {
                    displayAlert(AppConstant.Errors.StudentAndPlacemarkEmpty)
                    return
            }
            postingMediaLink(student, placemark: placemark, postedLocation: postedLocation)
            
        }
        
        
    }
    
    private func addPlacemark() {
        let delayInSeconds = 1.5
        let delay = delayInSeconds * Double(NSEC_PER_SEC)
        let poptime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(poptime, dispatch_get_main_queue(), {
            let geocoder = CLGeocoder()
            do {
                geocoder.geocodeAddressString(self.inputLocationTextField.text!, completionHandler: { (results, error) in
                    if error != nil {
                        self.displayAlert(AppConstant.Errors.CouldNotGeocode)
                    } else if results!.isEmpty {
                        self.displayAlert(AppConstant.Errors.NoLocationFound)
                    } else {
                        self.placemark = results![0]
                        //self.configureUI(.InputLink)
                        self.PostingMapView.showAnnotations([MKPlacemark(placemark: self.placemark!)], animated: true)
                    }
                })
            }
        })
    }
    
    //MARK: Posting a Media
    private func postingMediaLink(student: Student, placemark: CLPlacemark, postedLocation: CLLocation) {
        // define request handler
        let handlerRequest : ((NSError?, String) -> Void) = { (error, mediaURL) in
            if error != nil {
                self.displayAlert(AppConstant.Errors.PostStudentLocationFailed) { (alert) in
                    self.dismissVC()
                }
            } else {
                self.omtDataSource.currentStudent!.mediaURL = mediaURL
                self.omtDataSource.refreshStudentLocations()
                self.dismissVC()

            }
        }
        
        // init new posting
        let location = Location(latitude: postedLocation.coordinate.latitude, longtitdue: postedLocation.coordinate.longitude, mapString: inputLocationTextField.text!)
        let mediaURL = inputLinkTextField.text!
        
        if let objectID = objectID {
            let studentlocation = StudentLocation(objectID: objectID, student: student, location: location)
            ParseClient.updateStudentLocationWithObjectID(objectID, mediaURL: mediaURL, studentLocation: studentlocation, completionHandler: { (success, error) in
                if success {
                    print("success posting an existing student")
                }
                handlerRequest(error, mediaURL)
            })
        } else {
            let newstudentlocation = StudentLocation(student: student, location: location)
            ParseClient.postStudentLocation(mediaURL, studentLocation: newstudentlocation, completionHandler: { (success, error) in
                handlerRequest(error, mediaURL)
            })
        }
    }
    
    // MARK: Display Alert
    
    private func displayAlert(message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: AppConstant.AlertActions.Dismiss, style: .Default, handler: completionHandler))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Configure UI
    
    private func dismissVC() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func configureUI(state: PostingState) {
        
        UIView.animateWithDuration(1.0) { 
            switch(state) {
            case .InputLocation:
                self.inputLinkTextField.hidden = true
                self.inputLocationTextField.hidden = false
                self.findMapButton.setTitle("Find on Map", forState: .Normal)
                self.PromptLabel.hidden = false
                self.middleView.backgroundColor = UIColor(red: 0.275, green: 0.490, blue: 0.666, alpha: 1.0)
            case .InputLink:
                self.inputLinkTextField.hidden = false
                self.inputLocationTextField.hidden = true
                self.PromptLabel.hidden = true
                self.findMapButton.setTitle("Submit", forState: .Normal)
                self.middleView.backgroundColor = UIColor.clearColor()
            }
            
        }
    }


}
