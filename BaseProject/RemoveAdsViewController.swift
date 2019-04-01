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
        
        btnRemoveAds?.isSelected = false
        btnUnlockAllCat?.isSelected = true
        btnUnlockSelectedCat?.isSelected = false
        
        adjustTextColor()
    }
    
    @IBAction func unlockSelectedCategory(){
        lblPrice?.text = "0.99$"
        
        btnRemoveAds?.isSelected = false
        btnUnlockAllCat?.isSelected = false
        btnUnlockSelectedCat?.isSelected = true
        
        adjustTextColor()
        
        let uvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "UnLockViewController") as? UnLockViewController
        self.navigationController?.pushViewController(uvc!, animated: true)
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
