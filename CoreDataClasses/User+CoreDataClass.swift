//
//  User+CoreDataClass.swift
//  BaseProject
//
//  Created by Admin on 9/27/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import Foundation
import CoreData


public class User: NSManagedObject {
    
    class func userDetails(withInfo userDetailsInfo: NSDictionary, in managedObjectContext: NSManagedObjectContext) -> User {
        var optionlevel: User? = nil
        
        //print("restaurantDetailsInfo : \(restaurantDetailsInfo)")
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "user_id = %d", (userDetailsInfo.value(forKey: "id")) as! Int)
        
        if request.predicate == nil {
            return optionlevel!
        }
        
        let matches: [Any] = try! managedObjectContext.fetch(request)
        
        if (matches.count > 1) {
            // handle error
        }
        else if matches.count == 0 {
            
            print("Saving....")
            
            optionlevel = (NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as! User)
            
            for key: NSString in (userDetailsInfo.allKeys as! [NSString]) {
                
                if (key == "id"){
                    optionlevel?.setValue(userDetailsInfo.value(forKey: key as String), forKey: "user_id")
                }
                else{
                    optionlevel?.setValue(userDetailsInfo.value(forKey: key as String), forKey: key as String)
                }
            }
        }
        else{
            
            print("Updating....")
            
            optionlevel = (matches[matches.count - 1] as! User)
            
            for key: NSString in (userDetailsInfo.allKeys as! [NSString]) {
                
                if (key == "id"){
                    optionlevel?.setValue(userDetailsInfo.value(forKey: key as String), forKey: "user_id")
                }
                else{
                    optionlevel?.setValue(userDetailsInfo.value(forKey: key as String), forKey: key as String)
                }
            }
        }
        
        return optionlevel!
    }
}
