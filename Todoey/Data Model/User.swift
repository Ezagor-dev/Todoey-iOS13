//
//  User.swift
//  AshList
//
//  Created by Ezagor on 30.06.2023.
//  Copyright © 2023 Ezagor. All rights reserved.
//

import RealmSwift
import Foundation

class User: Object {
    @objc dynamic var id = UUID().uuidString // Add a primary key property
    @objc dynamic var hasCompletedOnboarding = false
    
    override static func primaryKey() -> String? {
        return "id" // Specify the primary key property
    }
}




