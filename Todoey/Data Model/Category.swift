//
//  Item.swift
//  Todoey
//
//  Created by Ezagor on 22.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    @objc dynamic var isPinned: Bool = false
    let items = List<Item>()
    
}
