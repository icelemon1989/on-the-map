//
//  Location.swift
//  On The Map
//
//  Created by Yang Ji on 8/25/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import MapKit

struct Location {
    
    //MARK: Property
    
    let latitude : Double
    let longtitdue : Double
    let mapString : String
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longtitdue)
    }
}
