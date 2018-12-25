//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 25/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import UIKit
import SwipeCellKit

// Note: The prototype cells in the subclasses MUST have the following attributes set:
// 1. Their Class set to SwipeTableViewCell and
// 2. Their Module set to SwipeCellKit
class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0  // Increases the height of the cell to accomodate the delete-icon image height
    }

    // TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell  // Cast to a swipeable cell from pod SwipeCellKit
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            print("Delete Cell")
            
            self.updateModel(at: indexPath)
//            self.tableView.reloadData()
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

    func updateModel(at indexPath: IndexPath) {
        print("Item deleted in super class")
    }
}
