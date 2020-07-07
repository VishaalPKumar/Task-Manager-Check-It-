//
//  AppManager.swift
//  Task Manager
//
//  Created by Vishaal Kumar on 6/10/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//


import UIKit
import Firebase

class AppManager {
    static let shared = AppManager()
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private init() { }
    var appContainer: WelcomeViewController!

    
    func showApp() {
        
        if Auth.auth().currentUser != nil {
            appContainer.performSegue(withIdentifier: K.startMainSegue, sender: appContainer)
        }
       
    }
    

    
    
}
