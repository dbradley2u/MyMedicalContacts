//
//  MapViewController.swift
//  MyMedicalContacts
//
//  Created by Denise Bradley on 3/30/16.
//  Copyright © 2016 Denise Bradley. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var currentBundle : String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
        print(currentBundle)
        
        mapView.delegate = self
        
        if currentBundle.hasSuffix("MapPinSatellite")
        {
            mapView.mapType = MKMapType.Satellite
        }
        
        let centerPoint = CLLocationCoordinate2D(latitude: 52.011937, longitude: -3.713379)
        let coordinateSpan = MKCoordinateSpanMake(3.5, 3.5)
        let coordinateRegion = MKCoordinateRegionMake(centerPoint, coordinateSpan)
        
        mapView.setRegion(coordinateRegion, animated: false)
        mapView.regionThatFits(coordinateRegion)

        var annotation1 = MyPin(title: "Full Name",
            subtitle: "Street Adress",
            coordinate: CLLocationCoordinate2DMake(51.587736, -3.90152))
        
        
        mapView.addAnnotation(annotation1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


