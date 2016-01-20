//
//  DistrictAnnotation.swift
//  SF Aware
//
//  Created by Akanki on 1/19/16.
//  Copyright © 2016 Akanki. All rights reserved.
//

import Foundation
import MapKit

class DistrictAnnotation: NSObject, MKAnnotation{
    
    let coordinate: CLLocationCoordinate2D
    
    //used as District Name
    let title: String?
    
    //used as Number of Crimes
    let subtitle:String?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        super.init()
    }
    
   
    
}
