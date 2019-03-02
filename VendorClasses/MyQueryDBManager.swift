//
//  MyQueryDBManager.swift
//  Food Court
//
//  Created by Admin on 7/3/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class MyQueryDBManager: NSObject {
    
    var totalConnection : Int = 0
    var totalAsyncConnection : Int = 0
    var myDB : FMDatabase? = nil
        
    class func sharedManager() -> Any {
        var sharedMyManager: MyQueryDBManager? = nil
        
        if sharedMyManager == nil {
            sharedMyManager = MyQueryDBManager ()
        }
        
        return sharedMyManager!
    }
    
    override init() {
        super.init()
        
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let uniquePath = NSURL(fileURLWithPath: destPath).appendingPathComponent("\(coreDataFileName).sqlite")
        
        totalConnection = 0
        totalAsyncConnection = 0
        
        myDB = FMDatabase(path: uniquePath?.path)
    }
    
    func openDB() -> DarwinBoolean {
        if totalConnection == 0 {
            
            if !(myDB?.open())! {
                print("Cannot Open Database")
                return false
            }
        }
        
        totalConnection += 1
        return true
    }
    
    func closeDB() {
        totalConnection -= 1
        if totalConnection == 0 {
            myDB?.close()
        }
    }
    
    func isTableExists(_ tableName: String) -> DarwinBoolean {
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery("select DISTINCT tbl_name from sqlite_master where tbl_name='\(tableName)'", values: nil)
            while (s?.next())! {
                print("\(String(describing: s?.object(forColumnName: "tbl_name")))")
            }
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return false
    }
    
    func getTableColumns(_ tableName: String) -> [Any] {
        
        var array: [Any]? = []
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery("PRAGMA table_info('\(tableName)');", values: nil)
            var columns: [Any]? = []
            while (s?.next())! {
                //retrieve values for each record
                print("\(String(describing: s?.object(forColumnName: "name")))")
                if columns == nil {
                    columns = [s?.object(forColumnName: "name") ?? "...."]
                }
                else {
                    columns?.append(s?.object(forColumnName: "name") ?? "....")
                }
            }
            
            array = [Any](arrayLiteral: columns!)
            print("Columns \(String(describing: array))")
            return array!
        } catch {
            print("Error getTableColumns: \(error)")
        }
        
        return array!
    }
    
    func getRestaurantsWithSearchKey(searchKey: String) -> [Any] {
        var searchKey = searchKey
        searchKey = searchKey + ("%")
        searchKey = "%" + (searchKey)
        
        var array: [Any]? = []
        
        let qStr: String = "select * from restaurants where restaurants.name LIKE '\(searchKey)' order by restaurants.name"
        print("qStr : \(qStr)")
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery(qStr, values: nil)
            var results: [Any]? = []
            
            while (s?.next())! {
                if results == nil {
                    results = [s?.resultDictionary() as Any]
                }
                else {
                    results?.append(s?.resultDictionary() as Any)
                }
            }
            
            array = results!
            return array!
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return array!
    }
    
    func getCategoryList ()-> [Any] {
    
        var array: [Any]? = []
        
        let qStr: String = "select * from categories where active = 1 and deleted = 0 order by sort"
        print("qStr : \(qStr)")
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery(qStr, values: nil)
            var results: [Any]? = []
            
            while (s?.next())! {
                if results == nil {
                    results = [s?.resultDictionary() as Any]
                }
                else {
                    results?.append(s?.resultDictionary() as Any)
                }
            }
            
            array = results!
            return array!
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return array!
    }
    
    func getStoryListWithCategory(id : Int) -> [Any] {
        
        var array: [Any]? = []
        
        let qStr: String = "select stories.* from stories where stories.category_id = '\(id)' and stories.deleted = 0"
        print("qStr : \(qStr)")
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery(qStr, values: nil)
            var results: [Any]? = []
            
            while (s?.next())! {
                if results == nil {
                    results = [s?.resultDictionary() as Any]
                }
                else {
                    results?.append(s?.resultDictionary() as Any)
                }
            }
            
            array = results!
            return array!
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return array!
    }
    
    func getStoryDetails(id : Int) -> [Any] {
        
        var array: [Any]? = []
        
        let qStr: String = "select posts.* from posts where posts.story_id = '\(id)' and posts.deleted = 0"
        
        print("qStr : \(qStr)")
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery(qStr, values: nil)
            var results: [Any]? = []
            
            while (s?.next())! {
                if results == nil {
                    results = [s?.resultDictionary() as Any]
                }
                else {
                    results?.append(s?.resultDictionary() as Any)
                }
            }
            
            array = results!
            return array!
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return array!
    }
    
    func getStroyWithSearchKey(searchKey: String, id : Int) -> [Any] {
        var searchKey = searchKey
        searchKey = searchKey + ("%")
        searchKey = "%" + (searchKey)
        
        var array: [Any]? = []
        
        var qStr: String = "select * from stories where stories.name LIKE '\(searchKey)'and active = 1 and deleted = 0 order by stories.name"
        
        if id > 0{
            qStr = "select * from stories where category_id = '\(id)' and stories.name LIKE '\(searchKey)'and active = 1 and deleted = 0 order by stories.name"
        }
        
        print("qStr : \(qStr)")
        
        do {
            let s: FMResultSet? = try myDB?.executeQuery(qStr, values: nil)
            var results: [Any]? = []
            
            while (s?.next())! {
                if results == nil {
                    results = [s?.resultDictionary() as Any]
                }
                else {
                    results?.append(s?.resultDictionary() as Any)
                }
            }
            
            array = results!
            return array!
        } catch {
            print("Error isTableExists: \(error)")
        }
        
        return array!
    }
    
}

