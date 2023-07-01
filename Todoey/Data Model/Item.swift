//
//  Item.swift
//  Todoey
//
//  Created by Ezagor on 22.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var isPinned: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    @objc dynamic var lastUpdate: Date? // Add this property
        
        override static func ignoredProperties() -> [String] {
            return ["lastUpdate"]
        }
}
