//
//  ViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 23/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var todoItems : Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    //var itemArray = Results<Item>?

    var selectedCategory: Category? {
        didSet {  // a Swift keyword that is the C# property setter
            loadItems()  // only called if selected category is not set to nil because of the ? above
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // This prints the approximate location of where the data is being stored with CoreData,
        // however it's not under the Documents/* whatever, but
        // under Library/Application Support/DataModel.sqlite
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.separatorStyle = .none
        
        // Note: At this point navigationController may still be nil!!!!!
        // So we set the navigationController's background in viewWillAppear (below)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Note: This method is called AFTER viewDidLoad and the navigation controller is available
        
        title = selectedCategory?.name  // Sets the title of the view controller
        
        // guard effectively ensures the statement works and if it doesn't then the else is executed.
        guard let colourHex = selectedCategory?.colour else {fatalError("")}
        updateNavBar(withHexCode: colourHex)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")  // Constant used in a few places!!!!!
    }
    
    //MARK: - Nav Bar setup methods
    func updateNavBar(withHexCode colourHexCode: String) {
        
        // guard effectively ensures the statement works and if it doesn't then the else is executed.
        
        /*
         guard let vs. if let:
         1. You should use guard let if you find yourself using lots of indented if lets (i.e. a stack of if lets)
         2. You should use if let when there is a fair chance something will fail.
         3. You should use guard let when there is little chance of something failing.
         */
        guard let navBar = navigationController?.navigationBar else {
            // print and stop execution
            fatalError("Navigation Controller does not exist")
        }
        
        // For navigation bar stuff, see here: https://developer.apple.com/documentation/uikit/uinavigationbar
        guard let navBarColour = UIColor(hexString: colourHexCode) else {fatalError("")}
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        
        // The below line also affects other items in the navbar (like the
        // colour of the "+" button)... so long as their colour is set to default.
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var theCount = todoItems?.count ?? 1  // todoItems?.count can be 0
        theCount = max(theCount, 1)
        return theCount
        
        //return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
//        if let item = todoItems?[indexPath.row] {
//            cell.textLabel?.text = item.title
//            cell.accessoryType = item.done ? .checkmark : .none
//        }
//        else {
//            cell.textLabel?.text = "No items added"
//        }
        
        if todoItems?.count == 0 {
            cell.textLabel?.text = "No items added"
        }
        else {
            if let item = todoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                
//                if let colour = FlatSkyBlue().darken(byPercentage:  // Just pick any colour
                // Base the initial colour on the selected category which cannot be nil, but we
                // must chain in case the colour (a string) is rubbish.
                if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:
                    CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                    cell.backgroundColor = colour
                    cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                }
                cell.accessoryType = item.done ? .checkmark : .none
            }
        }
        
        return cell
    }

    //MARK - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Can update using...
        // itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        // Can delete using... (make sure the order is correct, as shown below).
        //context.delete(itemArray[indexPath.row])  // we must still call context.save
        //itemArray.remove(at: indexPath.row)

        
//        todoItems?[indexPath.row].done = !(todoItems[indexPath.row].done)
//        saveItems()
        
/* Code for deleting an item...
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            }
            catch {
                print("Error saving delete \(error)")
            }
        }
*/
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            // what to do when user clicks add
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        // newItem.done = false  // specified in the Category model
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)  // We have to sort the relationship
                    }
                }
                catch {
                    print("Error saving new item \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            }
            catch {
                print("Error deleting item \(error)")
            }
            
            tableView.reloadData()
        }
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        // Sort items by descending date created
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
/*
        // filter (above) takes a predicate.
        // for predicate syntax, see here:
        // https://academy.realm.io/posts/nspredicate-cheatsheet/
        // https://nshipster.com/nspredicate/
*/
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
