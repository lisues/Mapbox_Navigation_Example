//
//  myMapboxUtility.swift
//  myMyboxRoutes
//
//  Created by Lisue J She on 11/13/17.
//  Copyright © 2017 Robert Alavi. All rights reserved.
//

import Mapbox

class MyMapboxUtility {
    
    //CLLocationCoordinate2D coordinate
    func getAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> MGLPointAnnotation {
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = "San Francisco"
        annotation.subtitle = "Default Title"
        
        return annotation
    }
    
    
    static let sharedInstance = MyMapboxUtility ()
}
