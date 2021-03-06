//
//  LeftMenuViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 1/31/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var listTableView: UITableView!
    var dataArray = [NSDictionary]()
    
    @IBOutlet var btnRemoveAdds:UIButton!
    
    func reloadData(){
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        self.dataArray = mqdbm.getCategoryList() as! [NSDictionary]
        //print("self.dataArray = \(String(describing: self.dataArray))")
        
        mqdbm.closeDB()
        
        listTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootAction()

        self.listTableView.delegate = self
        self.listTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    // MARK: - Button Action
    
    @IBAction func rootAction(){
        
        /*if (btnHome?.isSelected)!{
         print("already selected")
         return
         }
         */
        //btnRemoveAdds.isSelected = false
        
        if(appDelegate.rootNaviCon == nil){
            
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "CategoryViewController") as? CategoryViewController
            
            appDelegate.rootNaviCon = UINavigationController(rootViewController: rvc!)
            appDelegate.rootNaviCon?.navigationBar.isHidden = true
            appDelegate.rootNaviCon?.toolbar.isHidden = true
            appDelegate.currentNaviCon = (appDelegate.rootNaviCon)!
            
            appDelegate.window?.addSubview((appDelegate.rootNaviCon?.view)!)
            ((appDelegate.rootNaviCon?.view)!).alpha = 1;
            ((appDelegate.rootNaviCon?.view)!).frame = CGRect(x:0.0, y:0.0, width:ScreenSize.SCREEN_WIDTH, height:ScreenSize.SCREEN_HEIGHT)
        }
        else{
            appDelegate.currentNaviCon = (appDelegate.rootNaviCon)!
            appDelegate.window?.bringSubview(toFront: (appDelegate.currentNaviCon?.view)!)
        }
        
        appDelegate.drawerController?.mainViewController = appDelegate.currentNaviCon
        appDelegate.currentNaviCon?.navigationBar.isHidden = true
        appDelegate.currentNaviCon?.toolbar.isHidden = true
        
        self.didTapCloseButton()
    }
    
    @IBAction func removeAddsAction(){
        
        if (btnRemoveAdds?.isSelected)!{
            print("already selected")
            return
        }
        
        btnRemoveAdds?.isSelected = true
        
        appDelegate.previousNaviCon = appDelegate.currentNaviCon
        
        print("\(String(describing: appDelegate.currentNaviCon?.title))")
        
        if(appDelegate.removeAddsNaviCon == nil){
            
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let ravc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "RemoveAdsViewController") as? RemoveAdsViewController
            
            appDelegate.removeAddsNaviCon = UINavigationController(rootViewController: ravc!)
            appDelegate.removeAddsNaviCon?.navigationBar.isHidden = true
            appDelegate.removeAddsNaviCon?.toolbar.isHidden = true
            appDelegate.currentNaviCon = (appDelegate.removeAddsNaviCon)!
            
            appDelegate.window?.addSubview((appDelegate.removeAddsNaviCon?.view)!)
            ((appDelegate.removeAddsNaviCon?.view)!).alpha = 1;
            ((appDelegate.removeAddsNaviCon?.view)!).frame = CGRect(x:0.0, y:0.0, width:ScreenSize.SCREEN_WIDTH, height:ScreenSize.SCREEN_HEIGHT)
        }
        else{
            appDelegate.currentNaviCon = (appDelegate.removeAddsNaviCon)!
            appDelegate.window?.bringSubview(toFront: (appDelegate.currentNaviCon?.view)!)
        }
        
        appDelegate.drawerController?.mainViewController = appDelegate.currentNaviCon
        appDelegate.currentNaviCon?.navigationBar.isHidden = true
        appDelegate.currentNaviCon?.toolbar.isHidden = true
        
        self.didTapCloseButton()
    }
    
    func settingShow(){
        
        appDelegate.previousNaviCon = appDelegate.currentNaviCon
        
        if(appDelegate.settingNaviCon == nil){
        
            let svc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController
            
            appDelegate.settingNaviCon = UINavigationController(rootViewController: svc!)
            appDelegate.settingNaviCon?.navigationBar.isHidden = true
            appDelegate.settingNaviCon?.toolbar.isHidden = true
            appDelegate.currentNaviCon = (appDelegate.settingNaviCon)!
            
            appDelegate.window?.addSubview((appDelegate.settingNaviCon?.view)!)
            ((appDelegate.settingNaviCon?.view)!).alpha = 1;
            ((appDelegate.settingNaviCon?.view)!).frame = CGRect(x:0.0, y:0.0, width:ScreenSize.SCREEN_WIDTH, height:ScreenSize.SCREEN_HEIGHT)
        }
        else{
            appDelegate.currentNaviCon = (appDelegate.settingNaviCon)!
            appDelegate.window?.bringSubview(toFront: (appDelegate.currentNaviCon?.view)!)
        }
        
        appDelegate.drawerController?.mainViewController = appDelegate.currentNaviCon
        appDelegate.currentNaviCon?.navigationBar.isHidden = true
        appDelegate.currentNaviCon?.toolbar.isHidden = true
        
        self.didTapCloseButton()
    }
    
    @IBAction func settingAction(){
        print("settingAction")
        appDelegate.isSetting_flag = 0
        self.settingShow()
    }
    
    func didTapCloseButton() {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
    }
    
    // MARK: - Table Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        let info = dataArray[indexPath.row]
        cell.lblTitle?.text = info.object(forKey: "name") as? String
        
        let cid = info.value(forKey: "id") as! Int
        
        if paid_categories.contains(cid){
            
            if cid == 2 && ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                cell.imgLock?.alpha = 0
                cell.imgIcon?.alpha = 1
            }
            else if cid == 7 && ((prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                cell.imgLock?.alpha = 0
                cell.imgIcon?.alpha = 1
            }
            else if cid == 11 && ((prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                cell.imgLock?.alpha = 0
                cell.imgIcon?.alpha = 1
            }
            else{
                cell.imgLock?.alpha = 1
                cell.imgIcon?.alpha = 0
            }
        }
        else{
            cell.imgLock?.alpha = 0
            cell.imgIcon?.alpha = 1
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        
        let info = dataArray[indexPath.row]
        let cid = info.value(forKey: "id") as! Int
        
        if paid_categories.contains(cid){
            if cid == 2 && ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: info)
            }
            else if cid == 7 && ((prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: info)
            }
            else if cid == 11 && ((prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: info)
            }
            else{
                let alert = UIAlertController(title: "", message: "Do you want to buy this chapter with 0.99$", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "Buy", style: .default, handler: { action in
                    
                    #if (arch(i386) || arch(x86_64)) && os(iOS)
                    print("It's an iOS Simulator")
                    
                    var key = ""
                    
                    if cid == 2{
                        key = product_adventure
                    }
                    else if cid == 7 {
                        key = product_flashFiction
                    }
                    else if cid == 11 {
                        key = product_scifi
                    }
                    
                    prefs.set("purchased", forKey: key)
                    prefs.synchronize()
                    self.listTableView.reloadData()
                    
                    #else
                    print("It's a device")
                    //[appDelegate showLoadingPurchase];
                    //MKStoreManager.shared().buyUnit("Chapter \(chapter.cid())")
                    #endif
                    
                    alert.dismiss(animated: true)
                })
                let noButton = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    alert.dismiss(animated: true)
                })
                
                alert.addAction(yesButton)
                alert.addAction(noButton)
                present(alert, animated: true)
            }
        }
        else{
            self.goNext(withInfo: info)
        }
    }
    
    func goNext(withInfo : NSDictionary){
        var storyboard = UIStoryboard.init(name: "Main-iPhone5", bundle: nil)
        
        if DeviceType.IS_IPHONE_6{
            storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        }
        else if DeviceType.IS_IPHONE_6P{
            storyboard = UIStoryboard.init(name: "Main-iPhone6P", bundle: nil)
        }
        else if DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XR{
            storyboard = UIStoryboard.init(name: "Main-iPhoneX", bundle: nil)
        }
        
        let hvc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        hvc?.storyInfo = withInfo
        appDelegate.currentNaviCon?.pushViewController(hvc!, animated: true)
        
        self.didTapCloseButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
