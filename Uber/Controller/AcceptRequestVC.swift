//
//  AcceptRequestVC.swift
//  Uber
//
//  Created by Fomin Nickolai on 04.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import MapKit

class AcceptRequestVC: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    var requestLocation = CLLocationCoordinate2D()
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
        
        
        
    }
    

}
