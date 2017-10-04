//
//  AcceptRequestVC.swift
//  Uber
//
//  Created by Fomin Nickolai on 04.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestVC: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    var dataBaseRef: DatabaseReference = Database.database().reference()
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
        
        let annotaion = MKPointAnnotation()
        annotaion.coordinate = requestLocation
        annotaion.title = requestEmail
        mapView.addAnnotation(annotaion)
        
    }
    
    deinit {
        print("Deinit AcceptRequestVC")
    }

    //MARK: - @IBActions
    @IBAction func acceptRequestTapped(_ sender: UIButton) {
        //Update the ride Request
        dataBaseRef.child(DataBaseFieldsNames.rideRequests).queryOrdered(byChild: DataBaseFieldsNames.email).queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            
            snapshot.ref.updateChildValues([DataBaseFieldsNames.driverLatitude: self.driverLocation.latitude, DataBaseFieldsNames.driverLongitude: self.driverLocation.longitude])
            
            self.dataBaseRef.child(DataBaseFieldsNames.rideRequests).removeAllObservers()
        }
        
        //Give Directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            
            if let placemarks = placemarks {
                if !placemarks.isEmpty {
                    let mkPlaceMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: mkPlaceMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
            
        }
        
    }
    

}












