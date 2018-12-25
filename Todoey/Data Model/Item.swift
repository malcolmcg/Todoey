//
//  Item.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 25/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    // Note: Category.self refers to the Category type
    // and "items" is the string name of the items property defined in the Category.swift file
    // This is the inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
