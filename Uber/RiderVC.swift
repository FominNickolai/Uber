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
    var dataBaseRef: DatabaseReference = Database.database().reference()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let user = Auth.auth().currentUser, let email = user.email {
            
            dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let userEmail = value?[DataBaseFieldsNames.email] as? String ?? ""
                
                if userEmail == email {
                    
                    self.isStillCallingUber(buttonTitle: StringsConstants.cancelUberButtonTitle, hasBeenCanceled: true)
                    
                }
                
            })
            
        }
        
    }
    
    //MARK: - @IBActions
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func callUberTapped(_ sender: UIButton) {
        
        if let user = Auth.auth().currentUser, let email = user.email {
            
            if uberHasBeenCalled {
                
                dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).removeValue()
                
                isStillCallingUber(buttonTitle: StringsConstants.callUberButtonTitle, hasBeenCanceled: false)
                
            } else {
                
                let rideRequestDictionary: [String: Any] = [
                    DataBaseFieldsNames.email: email,
                    DataBaseFieldsNames.latitude: userLocation.latitude,
                    DataBaseFieldsNames.longitude: userLocation.longitude]
                
                dataBaseRef.child(DataBaseFieldsNames.rideRequests).child(user.uid).setValue(rideRequestDictionary)
                
                isStillCallingUber(buttonTitle: StringsConstants.cancelUberButtonTitle, hasBeenCanceled: true)
                
            }
            
        }
        
    }
    
    
    /// Method change current state of Uber Call.
    ///
    /// - Parameters:
    ///   - title: Call Uber Button title
    ///   - canceled: If Uber Call is canceled
    func isStillCallingUber(buttonTitle title: String, hasBeenCanceled canceled: Bool) {
        
        uberHasBeenCalled = canceled
        callAnUberButton.setTitle(title, for: .normal)
        
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
            annotation.title = StringsConstants.annotationTitle
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
}
