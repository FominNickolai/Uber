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

fileprivate struct SeguesIdentifier {
    static let rideRequestCell = "rideRequestCell"
    private init() {}
}

class DriverTVC: UITableViewController {
    
    //MARK: - @IBOutlets
    
    //MARK: - Properties
    var dataBaseRef: DatabaseReference = Database.database().reference()
    var rideRequests = [DataSnapshot]()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataBaseRef.child(DataBaseFieldsNames.rideRequests).observe(.childAdded) { (snapshot) in
            
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
            
        }
    }

    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SeguesIdentifier.rideRequestCell, for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
            
            if let email = rideRequestDictionary[DataBaseFieldsNames.email] as? String {
                
                cell.textLabel?.text = email
                
            }
            
        }
        
        return cell
    }
}















