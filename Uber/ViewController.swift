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
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            
            displayAlertController(withTitle: "Missing Information", andMessage: "You must provide both a email and password")
            
        } else {
            
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            
            if signUpMode {
                //Sign Up
    
                createUserInFirebase(withEmail: email, andPassword: password)
                
            } else {
                //Log In
                
                signInToFirebase(withEmail: email, andPassword: password)
                
            }
            
        }
        
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
    
    /// Display Alert to the User if any error.
    ///
    /// - Parameters:
    ///   - title: Alert Title
    ///   - message: Alert Message
    func displayAlertController(withTitle title: String, andMessage message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    /// Create User in Firebase
    ///
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    func createUserInFirebase(withEmail email: String, andPassword password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                
                self.displayAlertController(withTitle: "Error", andMessage: error.localizedDescription)
                
            } else {
                
                print("Sign Up Success")
                
            }
            
        })
        
    }
    
    /// Sign In to Firebase with email and password
    ///
    /// - Parameters:
    ///   - email: User email
    ///   - password: User password
    func signInToFirebase(withEmail email: String, andPassword password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                
                self.displayAlertController(withTitle: "Error", andMessage: error.localizedDescription)
                
            } else {
                
                print("Sign In Success")
                
            }
            
        })
        
    }
}









