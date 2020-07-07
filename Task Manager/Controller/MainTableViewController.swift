//
//  MainTableViewController.swift
//  Finance Tracker
//
//  Created by Vishaal Kumar on 6/4/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit
import ChameleonFramework


class MainTableViewController: UITableViewController {
    
    var categoriesName: [String] = []
    let db = Firestore.firestore()
    
    var selectedCategory: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        title = "🗂 Categories"
        navigationItem.hidesBackButton = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(hexString: "#1D9BF6")
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
        navBar.tintColor = UIColor.white

    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesName.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableConstants.categoryCellIdentifier, for: indexPath) as! SwipeTableViewCell
        
        let category = categoriesName[indexPath.row]
        cell.textLabel?.text = category
        let cellBackgroundColor = UIColor.randomFlat()
        let cellTextColor = UIColor(contrastingBlackOrWhiteColorOn: cellBackgroundColor, isFlat:true)

        cell.backgroundColor = cellBackgroundColor
        cell.textLabel?.textColor = cellTextColor
        cell.delegate = self
        return cell
    }
    
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        //TODO- Add segue to item page
        selectedCategory = categoriesName[indexPath.row]
        performSegue(withIdentifier: K.itemsSegue, sender: self)
        
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //Code for when add item is pressed
            let newCategory = Category()
            newCategory.title = textField.text!
            self.categoriesName.append(newCategory.title)
            self.addNewCategoryToFirebase(newCategory)
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Firebase methods
    
    func loadCategories() {
        if let currentUser = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).document(currentUser)
                .addSnapshotListener { (querySnapshot, error) in
                    
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocument = querySnapshot?.data() {
                            if let categories = snapshotDocument["categories"] as? [String] {
                                self.categoriesName = categories
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
        }
    }
    
    func addNewCategoryToFirebase(_ newCategory: Category) {
        if let currentUser = Auth.auth().currentUser?.email {
            let userRef = db.collection(K.FStore.collectionName).document(currentUser)
            userRef.collection(newCategory.title).document().setData(["test": true])
            userRef.updateData(["categories": categoriesName])
        }
    }
    
    func updateCategoryInFirebase() {
        if let currentUser = Auth.auth().currentUser?.email {
            let userRef = db.collection(K.FStore.collectionName).document(currentUser)
            userRef.updateData(["categories": categoriesName])
        }
    }
    
    func deleteCollectionInFirebase(_ collection: CollectionReference) {
        
        collection.getDocuments { (snapshot, error) in
            if let err = error {
                print(err)
            } else {
                for doc in snapshot!.documents {
                    collection.document("\(doc.documentID)").delete()
                }
            }
        }
    }


    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: K.logoutSegue, sender: self)
    }
    


// MARK: - Navigation


override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destinationVC = segue.destination as? ItemTableViewController {
    destinationVC.categoryTitle = selectedCategory
    }
}

}

//MARK: - SwipeTableViewCell Delegate

extension MainTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item Deleted")
            if let currentUser = Auth.auth().currentUser?.email {
                let userRef = self.db.collection(K.FStore.collectionName).document(currentUser)
                let collection = userRef.collection(self.categoriesName[indexPath.row])
                self.deleteCollectionInFirebase(collection)
                self.categoriesName.remove(at: indexPath.row)
                self.updateCategoryInFirebase()
            }
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
