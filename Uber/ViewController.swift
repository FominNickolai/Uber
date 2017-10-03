//
//  ViewController.swift
//  Uber
//
//  Created by Fomin Nickolai on 03.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var driverRiderStack: UIStackView!
    
    //MARK: - Properties
    var signUpMode = true
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: - @IBActions
    @IBAction func topTapped(_ sender: UIButton) {
        
        
        
    }
    
    @IBAction func bottomTapped(_ sender: UIButton) {
        
        switchBetweenLogInAndSignUp()
        
    }
    
    //MARK: - Methods
    
    /// Switch between Log In mode and Sign Up mode.
    func switchBetweenLogInAndSignUp() {
        
        if signUpMode {
            
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            driverRiderStack.isHidden = true
            signUpMode = false
            
        } else {
            
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            driverRiderStack.isHidden = false
            signUpMode = true
            
        }
        
    }
}









