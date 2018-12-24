//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 24/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    // get the delegate of the app object so we can get the methods for which the app is a delegate
    // (that's the UIApplicationDelegate implemented by the AppDelegate.swift class)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    //MARK: TableView Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }

    //MARK: Data manipulation methods
    func saveCategories() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        // Get the data from the database
        do {
            categories = try context.fetch(request)
        }
        catch {
            print("Error loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) {
            (action) in
            // what to do when user clicks add
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategories()
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
            destinatinVC.selectedCategory = categories[indexPath.row]
        }
        
    }
    
}
