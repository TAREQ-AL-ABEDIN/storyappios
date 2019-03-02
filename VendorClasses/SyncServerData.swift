//
//  DataSync.swift
//  Food Court
//
//  Created by Admin on 7/4/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class SyncServerData: NSObject {
    
    var currentPage: Int = 0
    var lastPage: Int = 0
    var is_running : Bool = false
    
    static let sharedInstance: SyncServerData = {
        let instance = SyncServerData()
        return instance
    }()
    
    override init() {
        super.init()
        is_running = false
    }
    
    func requestToServerForData (){
        
        var page_no : NSString = "1"
        if(prefs.value(forKey: "authors_currentPage") != nil){
            page_no = prefs.value(forKey: "authors_currentPage") as! NSString
        }
        
        let serverUrl = "\(baseUrl)/book/booklist"
        let postString = "authentication=\(authkey)&page_no=\(page_no)"
        print("GetAuthorsData serverUrl: \(serverUrl)")
        
        let request = NSMutableURLRequest(url: URL(string: serverUrl)!)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        var resultDic: NSDictionary? = nil;
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            if error == nil {
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                print("*** Response responseString:\(responseString! as NSString))")
                
                if (statusCode == 200) {
                    
                    do {
                        resultDic = try! JSONSerialization.jsonObject(with: data!) as? NSDictionary
                        
                        if resultDic == nil{
                            return
                        }
                        
                        if((resultDic?.value(forKey: "error")) != nil && (resultDic?.value(forKey: "error")) as! Int == 0){
                            print("AuthorsData:\(String(describing: resultDic))")
                            
                            self.currentPage = (resultDic?.value(forKey: "current_page")) as! Int
                            self.lastPage = (resultDic?.value(forKey: "last_page")) as! Int
                            
                            let success = self.processDataAsync((resultDic?.value(forKey: "data") as! NSDictionary))
                            print("Saveing : \(success)")
                        }
                        else{
                            print("ERRRRRRROOOOORRRR")
                        }
                    } catch {
                        print("Error deserializing JSON: \(error)")
                    }
                }
                else{
                    print("Invalid Request")
                }
    
            }
        }
        
        
        task.resume()
    }
    
    func processDataAsync(_ dataDic: NSDictionary?) -> Bool {
        
        var success: Bool = false
        
        for resultDic: NSDictionary in (dataDic?.value(forKey: "book") as! Array<NSDictionary>) {

            let resultKeys = resultDic.allKeys
            
            print("resultKeys : \(String(describing: resultKeys))")
            
            appDelegate.myServerSyncDB?.inTransaction{ (db, rollback) in
                
                for infoKey in resultKeys {
                    print("table info->\("select DISTINCT tbl_name from sqlite_master where tbl_name='\(infoKey)'")")
                    var is_table_exist: Int = 0
                    
                    print("resultKeys : \(String(describing: resultKeys))")
                    
                    do {
                        let s: FMResultSet? = try db?.executeQuery("select DISTINCT tbl_name from sqlite_master where tbl_name='\(infoKey)'", values: nil)
                        
                        while (s?.next())! {
                            is_table_exist = 1
                        }
                    } catch {
                        print("Error tbl_name: \(error)")
                    }
                    
                    print("is_table_exist : \(is_table_exist)")
                    
                    if is_table_exist == 1 {
                        
                        do {
                            let s1: FMResultSet? = try db?.executeQuery("PRAGMA table_info('\(infoKey)')", values: nil)
                            var columns: [String]? = nil
                            var columnsType: [String]? = nil
                            
                            while (s1?.next())! {
                                if columns == nil {
                                    columns = [s1?.object(forColumnName: "name") as! String]
                                    columnsType = [s1?.object(forColumnName: "type") as! String]
                                }
                                else {
                                    
                                    columns?.append((s1!.object(forColumnName: "name") as! String))
                                    columnsType?.append((s1!.object(forColumnName: "type") as! String))
                                }
                            }
                            
                            print("columns : \(String(describing: columns))")
                            print("columnsType : \(String(describing: columnsType))")
                            
                            var updateValues = [Any]()
                            
                            if !(resultDic[infoKey] is [Any]) {
                                var itemDic: [AnyHashable: Any]? = (resultDic[infoKey] as? [AnyHashable: Any])
                                var columnString: String = ""
                                var valueQuestionString: String = ""
                                updateValues.removeAll()
                                
                                for i:Int in 0..<(columns?.count)! {
                                    let columnName: String? = (columns?[i])
                                    let columnType: String? = (columnsType?[i])
                                    if itemDic?[columnName!] != nil {
                                        if itemDic?[columnName!] != nil && columnType?.caseInsensitiveCompare("BOOL") == .orderedSame {
                                            let boolCheck = (itemDic?[columnName!] as? NSNumber)
                                            if boolCheck != nil && !((boolCheck? .isKind(of: NSNull.self))!) && CInt(boolCheck!) == 1 {
                                                updateValues.append("\("true")")
                                            }
                                            else {
                                                updateValues.append("\("false")")
                                            }
                                        }
                                        else {
                                            updateValues.append("\(itemDic?[columnName!] ?? "")")
                                        }
                                        if valueQuestionString.characters.count > 0 {
                                            valueQuestionString = valueQuestionString + (",")
                                            columnString = columnString + (",")
                                        }
                                        
                                        valueQuestionString = valueQuestionString + ("?")
                                        columnString = columnString + (columnName)!
                                    }
                                }
                                
                                print("valueQuestionString:\(valueQuestionString)")
                                print("columnString:\(columnString)")
                                
                                let updateSql: String = "INSERT OR REPLACE INTO \(infoKey) (\(columnString)) VALUES (\(valueQuestionString))"
                                print("updateSql:\(updateSql)")
                                print("updateValues:\(updateValues)")
                                
                                success = ((try? db?.executeUpdate(updateSql, values: updateValues)) != nil)
                                print("success:\(success) for Table:\(infoKey) for id:\(String(describing: itemDic?["id"]))")
                                
                            }
                            else{
                                
                                let infos:Array<NSDictionary> = resultDic.value(forKey: infoKey as! String) as! Array<NSDictionary>
                                print("infos : \(infos as NSArray)")
                                
                                for itemDic in infos {
                                    
                                    var columnString: String = ""
                                    var valueQuestionString: String = ""
                                    updateValues.removeAll()
                                    
                                    for i:Int in 0..<(columns?.count)! {
                                        let columnName: String? = (columns?[i])
                                        let columnType: String? = (columnsType?[i])
                                        
                                        print("itemDic : \(itemDic as NSDictionary)")
                                        print("columnName : \(columnName! as NSString)")
                                        
                                        if itemDic[columnName!] != nil {
                                            if itemDic[columnName!] != nil && columnType?.caseInsensitiveCompare("BOOL") == .orderedSame {
                                                let boolCheck = (itemDic[columnName!] as? NSNumber)
                                                if boolCheck != nil && !((boolCheck? .isKind(of: NSNull.self))!) && CInt(boolCheck!) == 1 {
                                                    updateValues.append("\("true")")
                                                }
                                                else {
                                                    updateValues.append("\("false")")
                                                }
                                            }
                                            else {
                                                updateValues.append("\(itemDic[columnName!] ?? "")")
                                            }
                                            
                                            if valueQuestionString.characters.count > 0 {
                                                valueQuestionString = valueQuestionString + (",")
                                                columnString = columnString + (",")
                                            }
                                            
                                            valueQuestionString = valueQuestionString + ("?")
                                            columnString = columnString + (columnName)!
                                        }
                                    }
                                    
                                    print("valueQuestionString:\(valueQuestionString)")
                                    print("columnString:\(columnString)")
                                    
                                    let updateSql: String = "INSERT OR REPLACE INTO \(infoKey) (\(columnString)) VALUES (\(valueQuestionString))"
                                    print("updateSql:\(updateSql)")
                                    //print("columnString:\(columnString)")
                                    //print("valueQuestionString:\(valueQuestionString)")
                                    print("updateValues:\(updateValues)")
                                    
                                    success = ((try? db?.executeUpdate(updateSql, values: updateValues)) != nil)
                                    print("success:\(success) for Table:\(infoKey) for id:\(String(describing: itemDic["id"]))")
                                }
                            }
                            
                        } catch {
                            print("Error table_info: \(error)")
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async(execute: {
            if let topController = appDelegate.window?.visibleViewController() {
                print("topController : \(topController)")
                
                if (topController.isKind(of: HomeViewController.self)){
                    //(topController as! HomeViewController).reloadData()
                }
            }
        })
        
        return success
    }
}

