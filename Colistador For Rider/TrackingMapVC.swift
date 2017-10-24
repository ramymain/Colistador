//
//  TrackingMapVC.swift
//  Colistador For Customer
//
//  Created by Ramy Ferjani on 11/09/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class TrackingMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ColistadorController  {
    
    @IBOutlet weak var map: MKMapView!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var driverLocation: CLLocationCoordinate2D?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        
        ColistadorHandler.Instance.delegate = self;
        ColistadorHandler.Instance.observerMessagesForDriver();
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func updateDriversLocation(lat: Double, long: Double) { //Mettre a jour la localisation du livreur
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
        
        let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        map.removeAnnotations(map.annotations);
        if self.driverLocation != nil {
            let packageAnnotation = MKPointAnnotation();
            packageAnnotation.coordinate = self.driverLocation!;
            packageAnnotation.title = "Driver's Location";
            self.map.addAnnotation(packageAnnotation);
            
            let directionRequest = MKDirectionsRequest();
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: self.userLocation!));
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.driverLocation!));
            directionRequest.transportType = .automobile;
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: {
                response, error in
                guard let response = response else {
                    if error != nil {
                        print("Something Went Wrong")
                    }
                    return
                }
                let route = response.routes[0]
                self.map.add(route.polyline, level: .aboveRoads)
                
                let rekt = route.polyline.boundingMapRect
                self.map.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
            })
            
        }
        
        let annotation = MKPointAnnotation();
        annotation.coordinate = userLocation!;
        annotation.title = "Your Location";
        map.addAnnotation(annotation);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Gerer la localisation du clint
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            map.removeAnnotations(map.annotations);
            if self.driverLocation != nil {
                let packageAnnotation = MKPointAnnotation();
                packageAnnotation.coordinate = self.driverLocation!;
                packageAnnotation.title = "Driver's Location";
                self.map.addAnnotation(packageAnnotation);
                
                let directionRequest = MKDirectionsRequest();
                directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: self.userLocation!));
                directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.driverLocation!));
                directionRequest.transportType = .automobile;
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate(completionHandler: {
                    response, error in
                    guard let response = response else {
                        if error != nil {
                            print("Something Went Wrong")
                        }
                        return
                    }
                    let route = response.routes[0]
                    self.map.add(route.polyline, level: .aboveRoads)
                    
                    let rekt = route.polyline.boundingMapRect
                    self.map.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
                })
                
            }
            
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Your Location";
            map.addAnnotation(annotation);
        }
    }
    
}
