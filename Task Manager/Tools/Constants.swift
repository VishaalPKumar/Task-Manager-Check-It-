//
//  Constants.swift
//  Finance Tracker
//
//  Created by Vishaal Kumar on 6/3/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

struct K {
    static let appName = "Check It!"
    static let registerSegue = "RegisterToMain"
    static let loginSegue = "LoginToMain"
    static let itemsSegue = "CategoryToItems"
    static let homeSegue = "HelpToMain"
    static let logoutSegue = "ReturnHome"
    static let startWelcomeSegue = "WelcomeFirst"
    static let startMainSegue = "MainFirst"
    
    struct TableConstants {
        static let categoryCellIdentifier = "CategoryTableCell"
        static let itemCellIdentifier = "ToDoItemCell"
    }
    
    struct FStore {
        static let collectionName = "users"
        static let firstNameField = "firstname"
        static let lastNameField = "lastNameField"
        static let dateField = "date"
        static let itemsField = "items"
        static let itemNameField = "title"
        static let itemStateField = "done"
    }
    
}
