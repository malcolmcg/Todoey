//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 24/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

// Note, we have included pod SwipeCellKit
class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()

    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight = 80.0  // Increases the height of the cell to accomodate the delete-icon image height
    }
    
    //MARK: TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var theCount : Int = categories?.count ?? 1  // This is the nil coalescing operator, but categories?.count can be 0 and we need to force 1
        if theCount < 1 {
            theCount = 1
        }

        return theCount
//        return categories?.count ?? 1  // This is the nil coalescing operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Note: in order for the below line to work, in Main.storyboard it is necessary to set the class
        // of the Category view's prototype cell to be SwipeTableViewCell - inherits UITableViewCell
        // and the module to be SwipeCellKit - these come from the SwipeCellKit pod
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell  // Cast to a swipeable cell from pod SwipeCellKit
        cell.delegate = self //
        
        if categories?.count == 0 {
            cell.textLabel?.text = "No categories added yet"
        }
        else {
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        }
        return cell
    }

    //MARK: Data manipulation methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        // Get all the Category objects from Realm, the .self means the type of Category
        categories = realm.objects(Category.self) // retrieve all categories from realm
        tableView.reloadData()
    }
    
    //MARK: Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {
            (action) in
            // what to do when user clicks add
            
            let newCategory = Category()  // Realm is auto updating, so no appending needed to be done as with CoreData
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        
        alert.addTextField { (field) in
            field.placeholder = "Add a new category"
            textField = field
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // We know the destination so no need to check the segue identifier
        let destinatinVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinatinVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
}


//MARK: - Swipe Cell Delegate Methods
extension CategoryViewController: SwipeTableViewCellDelegate {

    // Note:
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let categoryForDeletion = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(categoryForDeletion)
                    }
                }
                catch {
                    print("Error deleting category \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")  // Name is case-sensitive
        
        return [deleteAction]
    }
    
    // Not working as it should... need to review at https://github.com/SwipeCellKit/SwipeCellKit
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive  // Will delete data
//        options.transitionStyle = .border
        return options
    }
}

