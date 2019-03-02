//
//  User+CoreDataProperties.swift
//  BaseProject
//
//  Created by Admin on 9/27/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var user_id: Int16
    @NSManaged public var name: String?
    @NSManaged public var created_at: NSDate?
}
