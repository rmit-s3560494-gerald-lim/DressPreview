//
//  User+CoreDataProperties.swift
//  
//
//  Created by Kunga Kartung on 21/9/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var favourites: [String]?

}
