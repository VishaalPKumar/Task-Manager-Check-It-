//
//  LoginViewController.swift
//  Finance Tracker
//
//  Created by Vishaal Kumar on 6/4/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftEntryKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
        title = "Log In"
    }

    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        
        let ac = UIAlertController(title: "Enter email address", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            let email = answer.text!
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if error != nil {
                    print(error!)
                }
            }
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        

        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                
                Auth.auth().currentUser?.reload(completion: { (error) in
                    if error != nil {
                        self.errorLabel.text = error!.localizedDescription
                        self.errorLabel.alpha = 1
                    }
                })
                
                if Auth.auth().currentUser?.isEmailVerified ?? true {
                        self.performSegue(withIdentifier: K.loginSegue, sender: self)
                } else {

                    let alert = UIAlertController(title: "Email Verification Required", message: "Please check your inbox in order to verify your account and proceed", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

                    self.present(alert, animated: true)
                }
                
            
            }
        }
    }
    
}
