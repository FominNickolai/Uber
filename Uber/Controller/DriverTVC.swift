//
//  DriverVC.swift
//  Uber
//
//  Created by Fomin Nickolai on 04.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit

fileprivate struct SeguesIdentifier {
    static let acceptSegue = "acceptSegue"
    private init() {}
}

class DriverTVC: UITableViewController {
    
    //MARK: - @IBOutlets
    
    //MARK: - Properties
    var dataBaseRef: DatabaseReference = Database.database().reference()
    var rideRequests = [DataSnapshot]()
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    var timer: Timer?
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        dataBaseRef.child(DataBaseFieldsNames.rideRequests).observe(.childAdded) { (snapshot) in
            
            if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                if let driverLatitude = rideRequestDictionary[DataBaseFieldsNames.driverLatitude] as? Double, let driverLongitude = rideRequestDictionary[DataBaseFieldsNames.driverLongitude] as? Double {

                } else {
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
            }       
            
        }
        
        startTimerForUpdatingRidersLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimerForUpdatingRidersLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }
    
    deinit {
        print("Deinit DriverTVC")
    }

    //MARK: - @IBActions
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Methods
    /// Update riders location
    func startTimerForUpdatingRidersLocation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
            
            if let email = rideRequestDictionary[DataBaseFieldsNames.email] as? String {
                
                if let lat = rideRequestDictionary[DataBaseFieldsNames.latitude] as? Double, let lon = rideRequestDictionary[DataBaseFieldsNames.longitude] as? Double {
                    
                    let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                    
                    let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                    let roundedDistance = round(distance * 100) / 100
                    
                    cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                }              
                
            }
            
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: SeguesIdentifier.acceptSegue, sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SeguesIdentifier.acceptSegue {
            
            guard let acceptVC = segue.destination as? AcceptRequestVC else { return }
            guard let snapshot = sender as? DataSnapshot else { return }
            
            if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                
                if let email = rideRequestDictionary[DataBaseFieldsNames.email] as? String {
                    
                    if let lat = rideRequestDictionary[DataBaseFieldsNames.latitude] as? Double, let lon = rideRequestDictionary[DataBaseFieldsNames.longitude] as? Double {
                        
                        acceptVC.requestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        acceptVC.requestEmail = email
                        acceptVC.driverLocation = driverLocation
                    }
                }
            }
            
            
            
        }
        
    }
}

//MARK: - CLLocationManagerDelegate
extension DriverTVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord =  manager.location?.coordinate {
            
            driverLocation = coord
        
        }
        
    }
    
}













