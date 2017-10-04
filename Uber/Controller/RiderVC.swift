//
//  RiderVC.swift
//  Uber
//
//  Created by Fomin Nickolai on 03.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class RiderVC: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callAnUberButton: UIButton!
    
    //MARK: - Properties
    var locationManager = CLLocationManager()
    var dataBaseRef: DatabaseReference = Database.database().reference()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let user = Auth.auth().currentUser, let email = user.email {
            
            dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).observe(.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let userEmail = value?[DataBaseFieldsNames.email] as? String ?? ""
                
                if userEmail == email {
                    
                    if let driverLatitude = value?[DataBaseFieldsNames.driverLatitude] as? Double, let driverLongitude = value?[DataBaseFieldsNames.driverLongitude] as? Double {
                        
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLatitude, longitude: driverLongitude)
                        self.driverOnTheWay = true
                        self.uberHasBeenCalled = true
                        self.displayDriverAndRider()
                        
                        if let user = Auth.auth().currentUser {
                            
                            self.dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).observe(.childChanged, with: { (snapshot) in
                                
                                let value = snapshot.value as? NSDictionary
                                
                                if let driverLatitude = value?[DataBaseFieldsNames.driverLatitude] as? Double, let driverLongitude = value?[DataBaseFieldsNames.driverLongitude] as? Double {
                                    
                                    self.driverLocation = CLLocationCoordinate2D(latitude: driverLatitude, longitude: driverLongitude)
                                    self.displayDriverAndRider()
                                    
                                }
                                
                            })
                        }
                        
                    } else {
                        
                        self.isStillCallingUber(buttonTitle: StringsConstants.cancelUberButtonTitle, hasBeenCalled: true)
                    }
                  
                }
                
            })
            
        }
        
    }
    
    deinit {
        print("Deinit RiderVC")
    }
    
    //MARK: - @IBActions
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
        
        if !driverOnTheWay {
            
            if let user = Auth.auth().currentUser, let email = user.email {
                
                if uberHasBeenCalled {
                    
                    dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).removeValue()
                    
                    isStillCallingUber(buttonTitle: StringsConstants.callUberButtonTitle, hasBeenCalled: false)
                    
                } else {
                    
                    let rideRequestDictionary: [String: Any] = [
                        DataBaseFieldsNames.email: email,
                        DataBaseFieldsNames.latitude: userLocation.latitude,
                        DataBaseFieldsNames.longitude: userLocation.longitude]
                    
                    dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).setValue(rideRequestDictionary)
                    
                    isStillCallingUber(buttonTitle: StringsConstants.cancelUberButtonTitle, hasBeenCalled: true)
                    
                }
                
            }
        }
       
    }
    
    
    /// Method change current state of Uber Call.
    ///
    /// - Parameters:
    ///   - title: Call Uber Button title
    ///   - canceled: If Uber Call is canceled
    func isStillCallingUber(buttonTitle title: String, hasBeenCalled called: Bool) {
        
        uberHasBeenCalled = called
        callAnUberButton.setTitle(title, for: .normal)
        
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        callAnUberButton.setTitle("Your Driver is \(roundedDistance)km away!", for: .normal)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let latitudeDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let longitudeDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        mapView.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your Location"
        mapView.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Driver Location"
        mapView.addAnnotation(driverAnnotation)
    }
    

}

//MARK: - CLLocationManagerDelegate
extension RiderVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord =  manager.location?.coordinate {
        
            let center =  CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            userLocation = center
            
            if uberHasBeenCalled && driverOnTheWay {
                
                displayDriverAndRider()
     
            } else {
                
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                mapView.setRegion(region, animated: true)
                mapView.removeAnnotations(mapView.annotations)
                
                //Annotation Create and Add to mapView
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = StringsConstants.annotationTitle
                mapView.addAnnotation(annotation)
                
            }
            
        }
        
    }
    
}
