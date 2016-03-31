//
//  MyPin.swift
//  MyMedicalContacts
//
//  Created by Denise Bradley on 3/30/16.
//  Copyright © 2016 Denise Bradley. All rights reserved.
//

import UIKit
import MapKit

class MyPin: MKPointAnnotation {
    
    init(title : String, subtitle : String, coordinate : CLLocationCoordinate2D) {
        super.init()
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }

}
