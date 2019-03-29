//
//  SettingViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/2/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet var imgViewPremium:UIImageView!
    @IBOutlet var imgViewRate:UIImageView!
    @IBOutlet var imgViewAbout:UIImageView!
    @IBOutlet var imgViewContact:UIImageView!
    @IBOutlet var imgViewTerms:UIImageView!
    @IBOutlet var imgViewNotification:UIImageView!
    
    @IBOutlet var nSwitch:UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7);
        
        self.borderRound(imgView: imgViewPremium)
        self.borderRound(imgView: imgViewRate)
        self.borderRound(imgView: imgViewAbout)
        self.borderRound(imgView: imgViewContact)
        self.borderRound(imgView: imgViewTerms)
        self.borderRound(imgView: imgViewNotification)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if appDelegate.bannerView != nil{
            appDelegate.bannerView.alpha = 1
        }
    }
    
    func borderRound(imgView:UIImageView){
        imgView.layer.cornerRadius = 5.0
        imgView.clipsToBounds = true
    }

    // MARK: - Button Action
    @IBAction func backRootAction(){
        if appDelegate.isSetting_flag == 1{
            self.navigationController?.popViewController(animated: true)
        }
        else{
            appDelegate.backToPreviousView()
        }
    }
    
    @IBAction func premiumAction(){
        let ravc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "RemoveAdsViewController") as? RemoveAdsViewController
        self.navigationController?.pushViewController(ravc!, animated: true)
    }
    
    @IBAction func rateAction(){
        
    }
    
    @IBAction func aboutAction(){
        let avc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController
        self.navigationController?.pushViewController(avc!, animated: true)
    }
    
    @IBAction func contactAction(){
        
    }
    
    @IBAction func termsAction(){
        let tvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "TermsViewController") as? TermsViewController
        self.navigationController?.pushViewController(tvc!, animated: true)
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
