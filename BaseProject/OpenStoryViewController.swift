//
//  OpenStoryViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/1/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit



class OpenStoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.noConnectedToNetwork()
        
    }
    
    // MARK: - Button Action
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backRootAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func readMoreAction(){
        let rvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
        appDelegate.currentNaviCon?.pushViewController(rvc!, animated: true)
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
