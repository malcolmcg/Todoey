//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 24/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import RealmSwift

// Note, we have included pod SwipeCellKit
class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
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

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
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
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryForDeletion)
                }
            }
            catch {
                print("Error deleting category \(error)")
            }
            
            tableView.reloadData()
        }
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

