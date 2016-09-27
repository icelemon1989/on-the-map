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
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!

    //MARK: Properties
    
    private let omtDataSource : SharedData = SharedData.sharedDataSource()
    private let UdaictyClient : udacityClient = udacityClient.sharedClient()
    private let ParseClient : parseClient = parseClient.sharedClient()
    var objectID: String? = nil
    private var placemark: CLPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        configureUI(.InputLocation)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissVC()
    }
    
    
    @IBAction func findMapButtonPressed(sender: UIButton) {
        if findMapButton.currentTitle == "Find on Map" {
            //check for empty string
            if inputLocationTextField.text!.isEmpty {
                displayAlert(AppConstant.Errors.LocationStringEmpty)
            }
            
            // start activity indicator
            startActivity()
            
            //add placemark
            self.addPlacemark()
            
        } else {//"Submit" button to posting a mediaURL
            
            activityIndecator.hidden = false
            activityIndecator.startAnimating()
            
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
                        self.configureUI(.InputLink)
                        self.PostingMapView.showAnnotations([MKPlacemark(placemark: self.placemark!)], animated: true)
                    }
                })
            }
        })
    }
    
    //MARK: Posting a Media
    private func postingMediaLink(student: Student, placemark: CLPlacemark, postedLocation: CLLocation) {
         //define request handler
        let handlerRequest : ((NSError?, String) -> Void) = { (error, mediaURL) in
            if error != nil {
                print("error in handlerrequest is \(error)")
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
        print("inputLinkTextFiew.text media: \(mediaURL)")
        
        if let objectID = objectID {
            let studentlocation = StudentLocation(objectID: objectID, student: student, location: location)
            hackyPUT(mediaURL, studentLocation: studentlocation, objectID: objectID, completeHandler: { (success, error) in
                handlerRequest(error, mediaURL)
            })
//            ParseClient.updateStudentLocationWithObjectID(objectID, mediaURL: mediaURL, studentLocation: studentlocation, completionHandler: { (success, error) in
//                handlerRequest(error, mediaURL)
//            })
        } else {
            let newstudentlocation = StudentLocation(objectID: "", student: student, location: location)
            print("newstudentlocation is \(newstudentlocation)")
           
//            ParseClient.postStudentLocation(mediaURL, studentLocation: newstudentlocation, completionHandler: { (success, error) in
//                handlerRequest(error, mediaURL)
//            })
            hackyPost(mediaURL, studentLocation: newstudentlocation, completeHandler: { (success, error) in
                handlerRequest(error, mediaURL)
            })
        }
    }
    private func hackyPUT(mediaURL: String, studentLocation: StudentLocation, objectID: String, completeHandler: (success: Bool, error: NSError?)->Void) {
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
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            completeHandler(success: true, error: nil)
        }
        task.resume()
    }
    
    private func hackyPost(mediaURL: String, studentLocation: StudentLocation, completeHandler:(success: Bool, error: NSError?)->Void) {
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
            completeHandler(success: true, error: error)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }


    // MARK: Display Alert

    private func displayAlert(message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        performUIUpdatesOnMain {
            self.stopActivity()
            let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: AppConstant.AlertActions.Dismiss, style: .Default, handler: completionHandler))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: setup UI
    
    private func setupUI() {
        
        inputLocationTextField.delegate = self
        inputLinkTextField.delegate = self
        
        activityIndecator.hidden = true
        activityIndecator.stopAnimating()
    }
    
    // MARK: Configure UI
    
    private func dismissVC() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func configureUI(state: PostingState) {
        stopActivity()
        
        UIView.animateWithDuration(1.0) { 
            switch(state) {
            case .InputLocation:
                self.inputLinkTextField.hidden = true
                self.inputLocationTextField.hidden = false
                self.findMapButton.setTitle("Find on Map", forState: .Normal)
                self.PromptLabel.hidden = false
                self.middleView.backgroundColor = UIColor(red: 0.275, green: 0.490, blue: 0.666, alpha: 1.0)
                self.bottomView.backgroundColor = UIColor(red: 0.917, green: 0.917, blue: 0.917, alpha: 1.0)
            case .InputLink:
                self.inputLinkTextField.hidden = false
                self.inputLocationTextField.hidden = true
                self.PromptLabel.hidden = true
                self.findMapButton.setTitle("Submit", forState: .Normal)
                self.middleView.backgroundColor = UIColor.clearColor()
                self.bottomView.backgroundColor = UIColor.clearColor()
            }
            
        }
    }
    
    //MARK: Activity Indicator
    private func startActivity() {
        activityIndecator.hidden = false
        activityIndecator.startAnimating()
        setFindingUIEnabled(false)
        setFindingUIAlpha(0.5)
    }
    
    private func stopActivity() {
        activityIndecator.hidden = true
        activityIndecator.stopAnimating()
        setFindingUIAlpha(1)
        setFindingUIEnabled(true)
    }
    
    private func setFindingUIEnabled(enabled: Bool) {
        inputLocationTextField.enabled = enabled
        findMapButton.enabled = enabled
        cancelButton.enabled = enabled
        PromptLabel.enabled = enabled
    }
    
    private func setFindingUIAlpha(alpha: CGFloat) {
        inputLocationTextField.alpha = alpha
        findMapButton.alpha = alpha
        cancelButton.alpha = alpha
        PromptLabel.alpha = alpha
    }


}

// MARK: PostingViewController: UITextFieldDelegate

extension PostingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
