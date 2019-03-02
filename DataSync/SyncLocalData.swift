//
//  SyncLocaldata.swift
//  BaseProject
//
//  Created by Admin on 9/27/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class SyncLocalData: NSObject {
    
    func syncDataFromPlistToCoreDataEntity (){
        if let path = Bundle.main.path(forResource: "Database", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                let dataArray = dict["Users"] as! [AnyObject]
                let success = processData(dataArray: dataArray)
                
                print("Data save \(success)")
            }
        }
    }
    
    func processData(dataArray : [AnyObject]) -> Bool {
        
        if(dataArray.count > 0){
            for itemInfo : NSDictionary in dataArray as! [NSDictionary]{
                
                if #available(iOS 10.0, *) {
                    _ = User.userDetails(withInfo: itemInfo, in: appDelegate.backgroundContext)
                }else {
                    _ = User.userDetails(withInfo: itemInfo, in: appDelegate.allManagedObjectContext)
                }
            }
        }
        let error: Error? = nil
        
        if #available(iOS 10.0, *) {
            if !(((try? appDelegate.backgroundContext.save()) != nil)) {
                print("\(String(describing: error?.localizedDescription))")
                print("appDelegate.backgroundContext.save ERROR")
            }
            else {
                if !(((try? appDelegate.viewContext.save()) != nil)) {
                    print("\(String(describing: error?.localizedDescription))")
                    print("appDelegate.viewContext.save ERROR")
                }
                else {
                    return true
                }
            }
        }else {
            
            if !(((try? appDelegate.allManagedObjectContext.save()) != nil)) {
                print("\(String(describing: error?.localizedDescription))")
                print("appDelegate.backgroundContext.save ERROR")
            }
            else {
                if !(((try? appDelegate.managedObjectContext.save()) != nil)) {
                    print("\(String(describing: error?.localizedDescription))")
                    print("appDelegate.viewContext.save ERROR")
                }
                else {
                    return true
                }
            }
        }
        
        return false
    }
}
