//
//  RiderVC.swift
//  Uber
//
//  Created by Fomin Nickolai on 03.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class RiderVC: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    //MARK: - Properties
    var locationManager = CLLocationManager()
    var dataBaseRef: DatabaseReference?
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - @IBActions
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        
        
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
        
        if let user = Auth.auth().currentUser, let email = user.email {
            
            dataBaseRef = Database.database().reference()
            
            if uberHasBeenCalled {
                
                dataBaseRef?.child(DataBaseFieldsNames.rideRequests).child(user.uid).removeValue()
                
                uberHasBeenCalled = false
                
                callAnUberButton.setTitle("Call an Uber", for: .normal)
                
            } else {
                
                let rideRequestDictionary: [String: Any] = [
                    DataBaseFieldsNames.email: email,
                    DataBaseFieldsNames.latitude: userLocation.latitude,
                    DataBaseFieldsNames.longitude: userLocation.longitude]
                
                dataBaseRef?.child(DataBaseFieldsNames.rideRequests).child(user.uid).setValue(rideRequestDictionary)
                
                uberHasBeenCalled = true
                
                callAnUberButton.setTitle("Cancel Uber", for: .normal)
                
            }
            
        }
        
    }
 

}

//MARK: - CLLocationManagerDelegate
extension RiderVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord =  manager.location?.coordinate {
        
            let center =  CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapView.setRegion(region, animated: true)
            mapView.removeAnnotations(mapView.annotations)
            
            //Annotation Create and Add to mapView
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
}
