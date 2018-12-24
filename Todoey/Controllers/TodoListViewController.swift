//
//  ViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 23/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {  // a Swift keyword that is the C# property setter
            loadItems()
        }
    }
    
    // The path below can be examined in Finder and we can watch the contents being changed
    // as we run the app.
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    // get the delegate of the app object so we can get the methods for which the app is a delegate
    // (that's the UIApplicationDelegate implemented by the AppDelegate.swift class)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // This prints the approximate location of where the data is being stored with CoreData,
        // however it's not under the Documents/* whatever, but
        // under Library/Application Support/DataModel.sqlite
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }

    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Can update using...
        // itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        // Can delete using... (make sure the order is correct, as shown below).
        //context.delete(itemArray[indexPath.row])  // we must still call context.save
        //itemArray.remove(at: indexPath.row)

        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            // what to do when user clicks add
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model manipulation methods
    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }

        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        
        // Get the data from the database
        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        // for predicate syntax, see here:
        // https://academy.realm.io/posts/nspredicate-cheatsheet/
        // https://nshipster.com/nspredicate/
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Tests for if search bar cleared
        if searchBar.text?.count == 0 {
            loadItems()
            
            // DispatchQueue object manages the allocation/execution of work items
            // A bit like execute on main thread in Xamarin/Windows
            DispatchQueue.main.async {
                // execute this code on the main thread
                searchBar.resignFirstResponder() // Closes keyboard, deactivates control
            }
        }
    }

}
