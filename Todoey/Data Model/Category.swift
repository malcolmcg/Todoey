//
//  Category.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 25/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    
    // Note: If you change the name "items" below then change it in the Item.swift file also
    // This is the forward relationship for SQL 1 to many relationship
    let items = List<Item>()  // List comes from Realm, this is the category -> items relationship
}
