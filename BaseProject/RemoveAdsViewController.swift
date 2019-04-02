//
//  RemoveAdsViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/2/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class RemoveAdsViewController: UIViewController {
    
    @IBOutlet weak var lblPrice:UILabel?
    
    @IBOutlet weak var img_RemoveAds:UIImageView?
    @IBOutlet weak var img_All:UIImageView?
    @IBOutlet weak var img_Selected:UIImageView?
    
    @IBOutlet weak var btnRemoveAds:UIButton?
    @IBOutlet weak var btnUnlockAllCat:UIButton?
    @IBOutlet weak var btnUnlockSelectedCat:UIButton?
    
    @IBOutlet weak var lblRemoveAds:UILabel?
    @IBOutlet weak var lblUnlockAllCat:UILabel?
    @IBOutlet weak var lblUnlockSelectedCat:UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boderRound(img: img_RemoveAds!)
        self.boderRound(img: img_All!)
        self.boderRound(img: img_Selected!)
    }
    
    func boderRound(img:UIImageView){
        img.layer.cornerRadius = 10.0
        img.clipsToBounds = true
    }

    // MARK: - Button Action
    @IBAction func backRootAction(){
        self.navigationController?.popViewController(animated: true)
        
        //appDelegate.drawerViewController?.rootAction()
    }
    
    @IBAction func removeAction(){
        
        if (prefs.value(forKey: product_removeAds) != nil && (prefs.value(forKey: product_removeAds) as! String) == "purchased"){
            let alert = UIAlertController(title: "", message: "You have already remove ads", preferredStyle: .alert)
            
            let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true)
            })
            
            alert.addAction(yesButton)
            present(alert, animated: true)
            return
        }
        
        lblPrice?.text = "1.99$"
        
        btnRemoveAds?.isSelected = true
        btnUnlockAllCat?.isSelected = false
        btnUnlockSelectedCat?.isSelected = false
        
        adjustTextColor()
    }
    
    @IBAction func unlockAllCategories(){
        
        if ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") && (prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") && (prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased")) || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased") {
            let alert = UIAlertController(title: "", message: "You have already purchased all categories", preferredStyle: .alert)
            
            let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true)
            })
            
            alert.addAction(yesButton)
            present(alert, animated: true)
            return
        }
        
        lblPrice?.text = "1.99$"
        
        btnRemoveAds?.isSelected = false
        btnUnlockAllCat?.isSelected = true
        btnUnlockSelectedCat?.isSelected = false
        
        adjustTextColor()
    }
    
    @IBAction func unlockSelectedCategory(){
        
        if ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") && (prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") && (prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased")) || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased") {
            let alert = UIAlertController(title: "", message: "You have already purchased all categories", preferredStyle: .alert)
            
            let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true)
            })
            
            alert.addAction(yesButton)
            present(alert, animated: true)
            return
        }
        
        lblPrice?.text = "0.99$"
        
        btnRemoveAds?.isSelected = false
        btnUnlockAllCat?.isSelected = false
        btnUnlockSelectedCat?.isSelected = true
        
        adjustTextColor()
        
        let uvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "UnLockViewController") as? UnLockViewController
        self.navigationController?.pushViewController(uvc!, animated: true)
    }
    
    @IBAction func purchaseAction(){
        
        if (btnUnlockAllCat?.isSelected)!{
            
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
        if (btnRemoveAds?.isSelected)!{
            
            if (prefs.value(forKey: product_removeAds) != nil && (prefs.value(forKey: product_removeAds) as! String) == "purchased"){
                let alert = UIAlertController(title: "", message: "You have already remove ads", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "OK", style: .default, handler: { action in
                    alert.dismiss(animated: true)
                })
                
                alert.addAction(yesButton)
                present(alert, animated: true)
            }
            else{
                let alert = UIAlertController(title: "", message: "Do you want to remove ads with 0.99$", preferredStyle: .alert)
                
                let yesButton = UIAlertAction(title: "Buy", style: .default, handler: { action in
                    
                    #if (arch(i386) || arch(x86_64)) && os(iOS)
                    print("It's an iOS Simulator")
                    
                    prefs.set("purchased", forKey: product_removeAds)
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
            
            let uvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "UnLockViewController") as? UnLockViewController
            self.navigationController?.pushViewController(uvc!, animated: true)
        }
        
    }
    
    func adjustTextColor(){
        lblRemoveAds?.textColor = (btnRemoveAds?.isSelected)! ? UIColor.white : UIColor.black
        lblUnlockAllCat?.textColor = (btnUnlockAllCat?.isSelected)! ? UIColor.white : UIColor.black
        lblUnlockSelectedCat?.textColor = (btnUnlockSelectedCat?.isSelected)! ? UIColor.white : UIColor.black
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
