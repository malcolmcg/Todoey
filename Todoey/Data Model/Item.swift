//
//  Item.swift
//  Todoey
//
//  Created by Malcolm Shuttleworth on 23/12/2018.
//  Copyright © 2018 Malcolm Shuttleworth. All rights reserved.
//

import Foundation

// Since Swift 4, Codable is both Encodable and Decodable
class Item: Codable {
    var title: String = ""
    var done: Bool = false
}
