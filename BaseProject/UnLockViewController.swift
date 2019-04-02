//
//  RemoveAdsViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/2/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class UnLockViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var lblRemoveAds:UILabel?
    @IBOutlet weak var lblPrice:UILabel?
    @IBOutlet weak var btnPrevious:UIButton?
    @IBOutlet weak var btnNext:UIButton?
    @IBOutlet weak var btnAllCategories:UIButton?
    @IBOutlet weak var myCollectionView:UICollectionView?
    
    var dataArray = [NSDictionary]()
    var selected_index = 0
    var is_all_selected = false
    
    func reloadData(){
        
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        let categories = mqdbm.getCategoryList() as! [NSDictionary]
        
        mqdbm.closeDB()
        
        for cat in categories{
            let cat_id = (cat as NSDictionary).value(forKey: "id") as! Int
            
            if paid_categories.contains(cat_id){
                   dataArray.append(cat)
            }
        }
        
        print("self.dataArray = \(String(describing: self.dataArray))")
        
        self.myCollectionView?.reloadData()
        focusToCurrentIndex()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myCollectionView?.dataSource = self
        self.myCollectionView?.delegate = self
        
        lblPrice?.text = "0.99$"
        self.reloadData()
    }

    // MARK: - Button Action
    
    @IBAction func nextAction(){
        
        if (selected_index < dataArray.count - 1){
            selected_index = selected_index + 1
            focusToCurrentIndex()
        }
    }
    
    @IBAction func previousAction(){
        if (selected_index > 0){
            selected_index = selected_index - 1
            focusToCurrentIndex()
        }
    }
    
    @IBAction func unlockAllCategories(){
        
        if (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased"){
            let alert = UIAlertController(title: "", message: "You have already purchased all categories", preferredStyle: .alert)
            
            let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true)
            })
            
            alert.addAction(yesButton)
            present(alert, animated: true)
            return
        }
        
        lblPrice?.text = "1.99$"
        is_all_selected = true
        myCollectionView?.reloadData()
        
        btnAllCategories?.setTitleColor(UIColor.white, for: .normal)
    }
    
    func focusToCurrentIndex(){
        let  indexPath = IndexPath(row: selected_index, section: 0)
        self.myCollectionView!.scrollToItem(at: indexPath, at: .right, animated: true)
        
        if selected_index == 0{
            btnPrevious?.isEnabled = false
            btnNext?.isEnabled = true
        }
        else if selected_index == (dataArray.count - 1){
            btnPrevious?.isEnabled = true
            btnNext?.isEnabled = false
        }
        else{
            btnPrevious?.isEnabled = true
            btnNext?.isEnabled = true
        }
    }
    
    @IBAction func backRootAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func purchaseAction(){
        
        if is_all_selected{
            
            if (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased"){
                let alert = UIAlertController(title: "", message: "You have already purchased all categories", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true)
                })
                
                alert.addAction(yesButton)
                present(alert, animated: true)
            }
            else{
                let alert = UIAlertController(title: "", message: "Do you want to buy all chapter with 1.99$", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "Buy", style: .default, handler: { action in
                    
                    #if (arch(i386) || arch(x86_64)) && os(iOS)
                    print("It's an iOS Simulator")
                    
                    prefs.set("purchased", forKey: product_allCategories)
                    prefs.synchronize()
                    
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
            
            if ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") && (prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") && (prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased")) || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased"){
                let alert = UIAlertController(title: "", message: "You have already purchased all categories", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true)
                })
                
                alert.addAction(yesButton)
                present(alert, animated: true)
                return
            }
            
            let info = self.dataArray[self.selected_index]
            let cid = info.value(forKey: "id") as! Int
            
            if cid == 2 && ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                showAlert()
                return
            }
            else if cid == 7 && ((prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                showAlert()
                return
            }
            else if cid == 11 && ((prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                showAlert()
                return
            }
            else{
                let alert = UIAlertController(title: "", message: "Do you want to buy this chapter with 0.99$", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "Buy", style: .default, handler: { action in
                    
                    
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
                    
                    #if (arch(i386) || arch(x86_64)) && os(iOS)
                    print("It's an iOS Simulator")
                    
                    prefs.set("purchased", forKey: key)
                    prefs.synchronize()
                    
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
        
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "", message: "You have already purchased this category", preferredStyle: .alert)
        
        let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true)
        })
        
        alert.addAction(yesButton)
        present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: 180.0, height: 30.0)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleCollectionViewCell", for: indexPath as IndexPath) as! SingleCollectionViewCell
        
        let info = dataArray[indexPath.row]
        cell.lblTitle?.text = info.object(forKey: "name") as? String
        
        if is_all_selected{
            cell.lblTitle?.textColor = UIColor.black
        }
        else{
            cell.lblTitle?.textColor = UIColor.white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lblPrice?.text = "0.99$"
        is_all_selected = false
        myCollectionView?.reloadData()
        
        btnAllCategories?.setTitleColor(UIColor.black, for: .normal)
    }
    
    // MARK: - pageControl
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let cell_width:CGFloat = 180.0
        selected_index = Int((myCollectionView?.contentOffset.x)!) / Int((cell_width))
        focusToCurrentIndex()
    }
    
}
