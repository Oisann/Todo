//
//  Group.swift
//  Todo
//
//  Created by Trainee on 28/02/2018.
//  Copyright © 2018 Trainee. All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
class Group: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var items: NSMutableSet
    
    func setup(name: String) {
        self.name = name
    }
    
    func item(_ at: Int) -> Item {
        let desc = NSSortDescriptor(key: "name", ascending: false)
        return self.items.sortedArray(using: [desc])[at] as! Item
    }
}
