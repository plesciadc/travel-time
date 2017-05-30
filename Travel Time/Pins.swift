//
//  Pins.swift
//  Travel Time
//
//  Created by Daniel Plescia on 5/25/17.
//  Copyright © 2017 Daniel Plescia. All rights reserved.
//

import MapKit

class Pins: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
}
