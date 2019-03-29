//
//  AgeRestrictionViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 5/12/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class AgeRestrictionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if appDelegate.bannerView != nil{
            appDelegate.bannerView.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if appDelegate.bannerView != nil{
            appDelegate.bannerView.alpha = 1
        }
    }
    
    // MARK: - Button Action    
    
    @IBAction func iAmOverAction(){
        
        prefs.set("YES", forKey: "ageRestriction")
        prefs.synchronize()
        appDelegate.createViewDeck()
        appDelegate.requestForData()
    }
    
    @IBAction func exitAction(){
        exit(0)
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
