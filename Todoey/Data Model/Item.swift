//
//  Item.swift
//  Todoey
//
//  Created by Ezagor on 12.06.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

class Item: Encodable {
    var title: String = ""
    var done: Bool = false
}
