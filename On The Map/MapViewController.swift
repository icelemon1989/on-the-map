//
//  MapViewController.swift
//  On The Map
//
//  Created by Yang Ji on 8/23/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    
    private let parseClient = ParseClient.sharedClient()
    private let sharedData = SharedData.sharedDataSource()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.studentLocationsDidUpdate), name: "\(ParseClient.Methods.StudentLocation)\(ParseClient.Notifications.LocationsUpdated)", object: nil)
        sharedData.refreshStudentLocations()
    }
    
    //MARK: Data Source
    func studentLocationsDidUpdate() {
        
        var annotations = [MKPointAnnotation]()
        
        for studentlocation in sharedData.studentLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = studentlocation.location.coordinate
            annotation.title = studentlocation.student.FullName
            annotation.subtitle = studentlocation.student.mediaURL
            annotations.append(annotation)
        }
        
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
    
    //MARK: Display Alert
    
    private func dispalyAlert(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: AppConstant.AlertActions.Cancel, style: UIAlertActionStyle.Cancel, handler: nil)
        alertView.addAction(alertAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }

}

extension MapViewController: MKMapViewDelegate {
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "OnTheMapPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let mediaURL = NSURL(string: ((view.annotation?.subtitle)!)!) {
                if UIApplication.sharedApplication().canOpenURL(mediaURL) {
                    UIApplication.sharedApplication().openURL(mediaURL)
                } else {
                    dispalyAlert(AppConstant.Errors.CannotOpenURL)
                    print("No Media URL")
                }
            }
        }
    }
}
