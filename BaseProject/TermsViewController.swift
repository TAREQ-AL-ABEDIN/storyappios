//
//  TermsViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/2/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet var txtViewDetails:UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "Database", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                let aboutStr = dict["Terms"] as! String
                txtViewDetails?.text = aboutStr
                //print("Data save \(aboutStr)")
            }
        }
        
        txtViewDetails?.textColor = UIColor.white
    }

    // MARK: - Button Action
    @IBAction func backRootAction(){
         //appDelegate.backToPreviousView()
        self.navigationController?.popViewController(animated: true)
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
