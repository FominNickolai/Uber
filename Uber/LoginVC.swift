//
//  ViewController.swift
//  Uber
//
//  Created by Fomin Nickolai on 03.10.17.
//  Copyright © 2017 Fomin Nickolai. All rights reserved.
//

import UIKit
import FirebaseAuth

fileprivate struct SeguesIdentifier {
    static let riderSegue = "riderSegue"
    static let driverSegue = "driverSegue"
    private init() {}
}

fileprivate enum UserType: String {
    case Driver
    case Rider
}

class LoginVC: UIViewController {
    
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
            
            displayAlertController(withTitle: StringsConstants.alertControllerCredentialErrorTitle,
                                   andMessage: StringsConstants.alertControllerCredentialErrorMessage)
            
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
            
            topButton.setTitle(StringsConstants.logInButtonTitle, for: .normal)
            bottomButton.setTitle(StringsConstants.switchToSignUpButtonTitle, for: .normal)
            driverRiderStack.isHidden = true
            signUpMode = false
            
        } else {
            
            topButton.setTitle(StringsConstants.SignUpButtonTitle, for: .normal)
            bottomButton.setTitle(StringsConstants.switchToLogInButtonTitle, for: .normal)
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
                
                if self.riderDriverSwitch.isOn {
                    //Driver
                    self.updateUserDisplayName(withUserType: .Driver, andPerformSegueWithIdentifier: SeguesIdentifier.driverSegue)
                    
                } else {
                    //Rider
                    self.updateUserDisplayName(withUserType: .Rider, andPerformSegueWithIdentifier: SeguesIdentifier.riderSegue)
                }
                
            }
            
        })
        
    }
    
    /// Method updates user display name
    ///
    /// - Parameters:
    ///   - userType: Type of User Rider or Driver
    ///   - identifier: Segue Identifier
    fileprivate func updateUserDisplayName(withUserType userType: UserType, andPerformSegueWithIdentifier identifier: String) {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = userType.rawValue
        request?.commitChanges(completion: nil)
        self.performSegue(withIdentifier: identifier, sender: nil)
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
                
                switch user?.displayName {
                case UserType.Driver.rawValue?:
                    //Driver
                    self.performSegue(withIdentifier: SeguesIdentifier.driverSegue, sender: nil)
                case UserType.Rider.rawValue?:
                    //Rider
                    self.performSegue(withIdentifier: SeguesIdentifier.riderSegue, sender: nil)
                default:
                    break
                }
            }
            
        })
        
    }
}









