//
//  ItemTableViewController.swift
//  Task Manager
//
//  Created by Vishaal Kumar on 6/5/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class ItemTableViewController: UITableViewController {
    
    var categoryTitle: String = ""
    var itemArray: [Item] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(categoryTitle)"
        
        loadItems()
        
        tableView.rowHeight = 80.0
        
    }
    
    func generateItemString() -> String {
        var output: String = ""
        for item in itemArray {
            output = "\(output) \n\(item.title)"
        }
        return output
    }
    
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let sharedString: String = generateItemString()
        let activityController = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error) in
            if completed {
                print("completed")
            } else {
                print("cancelled")
            }
        }
        present(activityController, animated: true) {
            print("presented")
        }
    }
    
    // MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableConstants.itemCellIdentifier, for: indexPath) as! SwipeTableViewCell
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        //Ternary operator ->
        //value = condition ? valueTrue : valueFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        cell.delegate = self
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        editItemStateFirebase(itemArray[indexPath.row])
        DispatchQueue.main.async {
            tableView.reloadData()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Code for when add item is pressed
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            self.addNewItemToFirebase(newItem: newItem)
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - FireBase Methods
    
    func loadItems() {
        if let currentUser = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).document(currentUser).collection(categoryTitle)
                .order(by: K.FStore.dateField)
                .addSnapshotListener { (querySnapshot, error) in
                    
                    self.itemArray = []
                    
                    if let e = error {
                        print("There was an issue retrieving data from Firestore. \(e)")
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                
                                let data = doc.data()
                                if let itemName = data[K.FStore.itemNameField] as? String, let itemState = data[K.FStore.itemStateField] as? Bool {
                                    let newItem = Item()
                                    newItem.title = itemName
                                    newItem.done = itemState
                                    self.itemArray.append(newItem)
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        let indexPath = IndexPath(row: self.itemArray.count - 1, section: 0)
                                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func addNewItemToFirebase(newItem:Item) {
        
        if let currentUser = Auth.auth().currentUser?.email {
            let userRef = db.collection(K.FStore.collectionName).document(currentUser)
            userRef.collection(categoryTitle).addDocument(data: [
                K.FStore.itemNameField: newItem.title,
                K.FStore.itemStateField: newItem.done,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                }
            }
        }
    }
    
    func editItemStateFirebase(_ item: Item) {
        if let currentUser = Auth.auth().currentUser?.email {
            db.collection("users")
                .document(currentUser)
                .collection(categoryTitle)
                .whereField("title", isEqualTo: item.title)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(err)
                    } else {
                        
                        if let document = querySnapshot?.documents.first {
                            print(document)
                            document.reference.updateData([
                                "done": item.done
                            ])
                        }
                    }
            }
        }
    }
    
    func deleteItemInFirebase(_ item: Item) {
        if let currentUser = Auth.auth().currentUser?.email {
            db.collection("users")
                .document(currentUser)
                .collection(categoryTitle)
                .whereField("title", isEqualTo: item.title)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print(err)
                    } else {
                        
                        if let document = querySnapshot?.documents.first {
                            document.reference.delete()
                        }
                    }
            }
        }
    }
}

//MARK: - SwipeTableViewCell Delegate

extension ItemTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item Deleted")
            self.deleteItemInFirebase(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
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

