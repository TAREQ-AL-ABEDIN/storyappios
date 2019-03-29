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
