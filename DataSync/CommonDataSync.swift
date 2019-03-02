//
//  DataSync.swift
//  Food Court
//
//  Created by Admin on 7/4/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class CommonDataSync: NSObject {
    
    var is_running : Bool = false
    
    static let sharedInstance: CommonDataSync = {
        let instance = CommonDataSync()
        return instance
    }()
    
    override init() {
        super.init()
        is_running = false
    }

    
    func requestForCommonData(){
        
        appDelegate.loadingView.alpha = 1.0
        appDelegate.window?.bringSubview(toFront: (appDelegate.loadingView)!)
        
        let serverUrl = "\(baseUrl)/commonSync"
        let postString = "authentication=\(authkey)"
        
        print("requestForCommonData serverUrl: \(serverUrl) + &\(postString)")
        
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
                
                if (statusCode == 200){
                    
                    do {
                        resultDic = try! JSONSerialization.jsonObject(with: data!) as? NSDictionary
                        
                        if resultDic == nil{
                            return
                        }
                        
                        if((resultDic?.value(forKey: "error")) != nil && (resultDic?.value(forKey: "error")) as! Int == 0){
                            print("commonSync Data:\(String(describing: resultDic))")
                            
                            let success = self.processDataAsync(resultDic)
                            print("Saving : \(success)")
                        }
                        else{
                            DispatchQueue.main.async(execute: {
                                appDelegate.showAlert(message: resultDic?.value(forKey: "errorMsg") as! String, vc: appDelegate.currentNaviCon!)
                                appDelegate.loadingView.alpha = 0.0
                            })
                        }
                    }
                }
                else{
                    print("Invalid Request")
                    DispatchQueue.main.async(execute: {
                        appDelegate.loadingView.alpha = 0.0
                    })
                }
            }
        }
        
        
        task.resume()
    }
    
    func processDataAsync(_ dataDic: NSDictionary?) -> Bool {
        
        var success: Bool = false
        let resultDic: NSDictionary = dataDic?.value(forKey: "data") as! NSDictionary
        let resultKeys : [String] = resultDic.allKeys as! [String]
        
        print("resultKeys : \(String(describing: resultKeys))")
        
        appDelegate.myServerSyncDB?.inTransaction{ (db, rollback) in
            
            for infoKey in resultKeys {
                
                let table_name = infoKey
                
                /*if infoKey == "xid"{
                    table_name = "xID"
                }*/
                
                print("table info->\("select DISTINCT tbl_name from sqlite_master where tbl_name='\(table_name)'")")
                var is_table_exist: Int = 0
                
                print("resultKeys : \(String(describing: resultKeys))")
                
                do {
                    let s: FMResultSet? = try db?.executeQuery("select DISTINCT tbl_name from sqlite_master where tbl_name='\(table_name)'", values: nil)
                    
                    while (s?.next())! {
                        is_table_exist = 1
                    }
                } catch {
                    print("Error tbl_name: \(error)")
                }
                
                print("is_table_exist : \(is_table_exist)")
                
                if is_table_exist == 1 {
                    
                    do {
                        let s1: FMResultSet? = try db?.executeQuery("PRAGMA table_info('\(table_name)')", values: nil)
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
                            
                            /*if (infoKey == "users" && itemDic!["password"] == nil && appDelegate?.current_password != nil){
                             itemDic!["password"] = appDelegate?.current_password
                             }*/
                            
                            var columnString: String = ""
                            var valueQuestionString: String = ""
                            updateValues.removeAll()
                            
                            for i:Int in 0..<(columns?.count)! {
                                let columnName: String? = (columns?[i])
                                let columnType: String? = (columnsType?[i])
                                
                                /*if (infoKey == "users" && columnName == "password"){
                                 continue
                                 }*/
                                
                                if itemDic?[columnName!] != nil {
                                    if itemDic![columnName!] != nil && columnType?.caseInsensitiveCompare("BOOL") == .orderedSame {
                                        let boolCheck = (itemDic![columnName!] as? NSNumber)
                                        if boolCheck != nil && !((boolCheck? .isKind(of: NSNull.self))!) && boolCheck?.intValue == 1 {
                                            updateValues.append("\("true")")
                                        }
                                        else {
                                            updateValues.append("\("false")")
                                        }
                                    }
                                    else if itemDic![columnName!] != nil && columnType?.caseInsensitiveCompare("INTEGER") == .orderedSame {
                                        let value = (itemDic![columnName!] as? NSNumber)
                                        if value != nil && !((value? .isKind(of: NSNull.self))!) {
                                            updateValues.append(value ?? 0)
                                        }
                                        else{
                                            updateValues.append(0)
                                        }
                                        
                                    }
                                    else {
                                        
                                        if itemDic![columnName!] != nil && !(((itemDic![columnName!] as AnyObject).isKind(of: NSNull.self))) {
                                            updateValues.append(self.getValue(value: (itemDic![columnName!] as! String)))
                                        }
                                        else{
                                            updateValues.append("")
                                        }
                                    }
                                    
                                    if valueQuestionString.count > 0 {
                                        valueQuestionString = valueQuestionString + (",")
                                        columnString = columnString + (",")
                                    }
                                    
                                    valueQuestionString = valueQuestionString + ("?")
                                    columnString = columnString + (columnName)!
                                }
                            }
                            
                            print("valueQuestionString:\(valueQuestionString)")
                            print("columnString:\(columnString)")
                            
                            let updateSql: String = "INSERT OR REPLACE INTO \(table_name) (\(columnString)) VALUES (\(valueQuestionString))"
                            print("updateSql:\(updateSql)")
                            print("updateValues:\(updateValues)")
                            
                            success = ((try? db?.executeUpdate(updateSql, values: updateValues)) != nil)
                            print("success:\(success) for Table:\(table_name) for id:\(String(describing: itemDic?["id"]))")
                            
                        }
                        else{
                            
                            let infos:Array<NSDictionary> = resultDic.value(forKey: infoKey ) as! Array<NSDictionary>
                            //print("infos : \(infos as NSArray)")
                            
                            for itemDic in infos {
                                
                                //print("itemDic : \(itemDic)")
                                
                                var columnString: String = ""
                                var valueQuestionString: String = ""
                                updateValues.removeAll()
                                
                                for i:Int in 0..<(columns?.count)! {
                                    let columnName: String? = (columns?[i])
                                    let columnType: String? = (columnsType?[i])
                                    
                                    //print("itemDic : \(itemDic as NSDictionary)")
                                    print("columnName : \(columnName! as NSString)")
                                    print("columnType : \(columnType! as NSString)")
                                    
                                    if itemDic[columnName!] != nil {
                                        if itemDic[columnName!] != nil && columnType?.caseInsensitiveCompare("BOOL") == .orderedSame {
                                            let boolCheck = (itemDic[columnName!] as? NSNumber)
                                            if boolCheck != nil && !((boolCheck? .isKind(of: NSNull.self))!) && boolCheck?.intValue == 1 {
                                                updateValues.append("\("true")")
                                            }
                                            else {
                                                updateValues.append("\("false")")
                                            }
                                        }
                                        else if itemDic[columnName!] != nil && columnType?.caseInsensitiveCompare("INTEGER") == .orderedSame {
                                            let value = (itemDic[columnName!] as? NSNumber)
                                            if value != nil && !((value? .isKind(of: NSNull.self))!) {
                                                updateValues.append(value ?? 0)
                                            }
                                            else{
                                                updateValues.append(0)
                                            }
                                            
                                        }
                                        else {
                                            
                                            if itemDic[columnName!] != nil && !(((itemDic[columnName!] as AnyObject).isKind(of: NSNull.self))) {
                                                updateValues.append(self.getValue(value: (itemDic[columnName!] as! String)))
                                            }
                                            else{
                                                updateValues.append("")
                                            }
                                        }
                                        
                                        if valueQuestionString.count > 0 {
                                            valueQuestionString = valueQuestionString + (",")
                                            columnString = columnString + (",")
                                        }
                                        
                                        valueQuestionString = valueQuestionString + ("?")
                                        columnString = columnString + (columnName)!
                                    }
                                }
                                
                                print("valueQuestionString:\(valueQuestionString)")
                                print("columnString:\(columnString)")
                                
                                let updateSql: String = "INSERT OR REPLACE INTO \(table_name) (\(columnString)) VALUES (\(valueQuestionString))"
                                print("updateSql:\(updateSql)")
                                //print("columnString:\(columnString)")
                                //print("valueQuestionString:\(valueQuestionString)")
                                print("updateValues:\(updateValues)")
                                
                                success = ((try? db?.executeUpdate(updateSql, values: updateValues)) != nil)
                                print("success:\(success) for Table:\(table_name) for id:\(String(describing: itemDic["id"]))")
                            }
                        }
                        
                    } catch {
                        print("Error table_info: \(error)")
                    }
                }
            }
        }
        
        DispatchQueue.main.async(execute: {
            appDelegate.loadingView.alpha = 0.0
            
            if let topController = appDelegate.currentNaviCon?.visibleViewController {
                
                if (topController.isKind(of: CategoryViewController.self)){
                    (topController as! CategoryViewController).reloadData()
                }
            }
        })
        
        return success
    }
    
    func getValue(value : String?) -> String{
        if (value != nil && !(value?.isEqual(NSNull()))! && !(value?.contains("null"))! && value!.count > 0){
            return value! as String
        }
        else{
            return ""
        }
    }
}


