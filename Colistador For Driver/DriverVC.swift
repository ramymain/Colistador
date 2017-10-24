
//
//  DriverVC.swift
//  Colistador For Driver
//
//  Created by Ramy Ferjani on 12/05/2017.
//  Copyright © 2017 Ramy Ferjani. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ColistadorController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var btn_quitt: UIButton!
    @IBOutlet var btn_livraison: UIButton!
    @IBOutlet weak var acceptDeliveryBtn: UIButton!
    @IBOutlet weak var openGoogleMapsBtn: UIButton!
    @IBOutlet weak var packageReceivedBtn: UIButton!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var packageLocation: CLLocationCoordinate2D?;
    private var deliveryLocation: CLLocationCoordinate2D?;
    private var trackingNumber: String?;
    private var address: String?;
    private var addressShop: String?;
    private var timer = Timer();
    
    private var acceptedDelivery = false;
    private var packageReceived = false;
    private var driverCanceledDelivery = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        border_btn();
        
        ColistadorHandler.Instance.delegate = self;
        ColistadorHandler.Instance.observerMessagesForDriver();
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.a
    }
    
    private func initializeLocationManager() {
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //Afficher la ou les localisation(s)
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude);
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            
            map.removeAnnotations(map.annotations);
            
            if self.packageLocation != nil {
                if self.acceptedDelivery {
                    if !self.packageReceived { //Si une commande est en cours et le colis non recupere affiche la localisation de l'entrepot
                        
                        let annotation = MKPointAnnotation();
                        annotation.coordinate = self.packageLocation!;
                        annotation.title = "Package Location";
                        self.map.addAnnotation(annotation);
                    }
                    else { //Si une commande est en cours et le colis recupere affiche la localisation de livraison
                        let annotation = MKPointAnnotation();
                        annotation.coordinate = self.deliveryLocation!;
                        annotation.title = "Delivery Location";
                        self.map.addAnnotation(annotation);
                    }
                    
                    let directionRequest = MKDirectionsRequest();
                    directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: self.userLocation!));
                    directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.packageLocation!));
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
                        print("test");
                    })
                    
                    
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Your Location";
            map.addAnnotation(annotation);
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { //Genere la map
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func acceptDelivery(shopLat: Double, shopLong: Double, deliveryLat: Double, deliveryLong: Double, address: String, addressShop: String, trackingNumber: String) { //Fonction pour accepter les commandes
        if !acceptedDelivery {
            colistadorRequest(title: "Colistador Request", message: "You have a request for a package from \(address) to \(addressShop)", requestAlive: true)
            packageLocation = CLLocationCoordinate2D(latitude: shopLat, longitude: shopLong);
            deliveryLocation = CLLocationCoordinate2D(latitude: deliveryLat, longitude: deliveryLong);
            self.trackingNumber = trackingNumber;
            self.address = address;
            self.addressShop = addressShop;
        }
    }
    
    func canceledDelivery() { //Fonction pour annuler les commandes
        if !driverCanceledDelivery {
            ColistadorHandler.Instance.cancelDeliveryForDriver();
            self.acceptedDelivery = false;
            self.acceptDeliveryBtn.isHidden = true;
            self.openGoogleMapsBtn.isHidden = true;
            self.packageReceivedBtn.isHidden = true;
            colistadorRequest(title: "Delivery Canceled", message: "The Delivery Has Been Canceled", requestAlive: false);
        }
    }
    
    func deliveryCanceled() { //Fonction pour gérer l'annulation depuis l'application de tracking
        acceptedDelivery = false;
        acceptDeliveryBtn.isHidden = true;
        self.openGoogleMapsBtn.isHidden = true;
        self.packageReceivedBtn.isHidden = true;
        timer.invalidate();
    }
    
    func updateDriverLocation() { //Mettre a jour la localisation du livreur
        ColistadorHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    
    @IBAction func cancelDelivery(_ sender: Any) {
        if acceptedDelivery {
            driverCanceledDelivery = true;
            acceptDeliveryBtn.isHidden = true;
            self.openGoogleMapsBtn.isHidden = true;
            self.packageReceivedBtn.isHidden = true;
            ColistadorHandler.Instance.cancelDeliveryForDriver();
            timer.invalidate();
            
        }
    }
    
    
    @IBAction func logOut(_ sender: Any) { //Fonction de deconnexion
        if AuthProvider.Instance.logOut() {
            if acceptedDelivery {
                acceptDeliveryBtn.isHidden = true;
                self.openGoogleMapsBtn.isHidden = true;
                self.packageReceivedBtn.isHidden = true;
                ColistadorHandler.Instance.cancelDeliveryForDriver();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            colistadorRequest(title: "Could Not Logout", message: "Please try again later", requestAlive: false);
        }
    }
    
    private func colistadorRequest(title: String, message: String, requestAlive: Bool) { //Fonction pour proposer une commande au livreur
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                self.acceptedDelivery = true;
                self.acceptDeliveryBtn.isHidden = false;
                self.openGoogleMapsBtn.isHidden = false;
                self.packageReceivedBtn.isHidden = false;
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(DriverVC.updateDriverLocation), userInfo: nil, repeats: true);
                
                ColistadorHandler.Instance.deliveryAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude), trackingNumber: self.trackingNumber!);
                
                
            });
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            alert.addAction(accept);
            alert.addAction(cancel);
        } else {
            let ok = UIAlertAction(title: "Ok", style: .default, handler: nil);
            alert.addAction(ok);
        }
        present(alert, animated: true, completion: nil);
        
    }
    
    
    @IBAction func packageReceived(_ sender: Any) { //Colis reçu
        self.packageReceived = true;
        
    }
    
    
    @IBAction func openGoogleMaps(_ sender: Any) {
        
        let regionDistance:CLLocationDistance = 10000
        
        if !self.packageReceived {
            let coordinates = CLLocationCoordinate2DMake((self.packageLocation?.latitude)!, (self.packageLocation?.longitude)!)
            
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = addressShop
            mapItem.openInMaps(launchOptions: options)
        } else {
            let coordinates = CLLocationCoordinate2DMake((self.deliveryLocation?.latitude)!, (self.deliveryLocation?.longitude)!)
            
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = address
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    
    @IBAction func btn_quit(_ sender: Any) {
        exit(0)
    }
    var showMenu = false
    
    @IBAction func btn_menu(_ sender: Any) {
        if(showMenu)
        {
            leadingConstraint.constant = -240
        }
        else{
            leadingConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations:{
                self.view.layoutIfNeeded()
            })
        }
        showMenu = !showMenu
    }
    func border_btn()
    {
        let myColor : UIColor = UIColor.black
        btn_quitt.layer.borderWidth = 0.8
        btn_quitt.layer.borderColor = myColor.cgColor
        btn_livraison.layer.borderWidth = 0.8
        btn_livraison.layer.borderColor = myColor.cgColor
    }
    
}
