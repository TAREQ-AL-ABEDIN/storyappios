//
//  HomeViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 1/16/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

let animation_duration = 0.3

class HomeViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,StorySelectionDelegate {
    
    @IBOutlet var storyCollectionView : UICollectionView?
    
    var allStories : [NSDictionary]? = nil
    var sectionedStories : [[NSDictionary]]? = [[NSDictionary]]()
    var temoraryArray : [Int]? = [Int]()
    
    var storyInfo: NSDictionary? = nil
    
    @IBOutlet weak var lblNoOfNotific:UILabel?
    
    var readerVC:ReaderViewController?
    
    func didSelectStory(title: String, option : Int, imageName : String?) {
        
        if (imageName == nil){
            return
        }
        
        let seperatedValues = title.split(separator: "-")
        
        let row: Int = Int(seperatedValues[0])!
        let index: Int = Int(seperatedValues[1])!
        
        print ("Row : \(row)")
        print ("Button Index : \(index)")
        
        readerVC?.infoBottomView?.alpha = 0.0
        
        if option == 1{
            
            let indexPath = IndexPath(row: row, section: 0)
            let cell = storyCollectionView?.cellForItem(at: indexPath) as? OneOneCollectionViewCell
            
            let theAttributes:UICollectionViewLayoutAttributes! = storyCollectionView!.layoutAttributesForItem(at: indexPath)
            let cellFrameInSuperview:CGRect!  = storyCollectionView!.convert(theAttributes.frame, to: storyCollectionView!.superview)
            
            if (index == 0){
                readerVC?.view.frame.origin.x = 0
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnOne?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnOne?.frame.size.height)!
            }
            else{
                readerVC?.view.frame.origin.x = ScreenSize.SCREEN_WIDTH - (cell?.btnOne?.frame.size.width)!
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnOne?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnOne?.frame.size.height)!
            }
            

            readerVC?.origin_size = readerVC?.view.frame
            readerVC?.fullscreen_imagename = imageName
            readerVC?.showInfo()
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.readerVC?.view.alpha = 1
            }, completion: {
                focused in UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.readerVC?.view.frame = UIScreen.main.bounds
            }, completion: nil)})
        }
        else if (option == 2){
            
            let indexPath = IndexPath(row: row, section: 0)
            let cell = storyCollectionView?.cellForItem(at: indexPath) as? OneTwoCollectionViewCell
            
            let theAttributes:UICollectionViewLayoutAttributes! = storyCollectionView!.layoutAttributesForItem(at: indexPath)
            let cellFrameInSuperview:CGRect!  = storyCollectionView!.convert(theAttributes.frame, to: storyCollectionView!.superview)
            
            if (index == 0){
                readerVC?.view.frame.origin.x = 0
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnOne?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnOne?.frame.size.height)!
            }
            else if (index == 1){
                readerVC?.view.frame.origin.x = ScreenSize.SCREEN_WIDTH - (cell?.btnTwo?.frame.size.width)!
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnTwo?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnTwo?.frame.size.height)!
            }
            else{
                readerVC?.view.frame.origin.x = ScreenSize.SCREEN_WIDTH - (cell?.btnThree?.frame.size.width)!
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y + ((cell?.btnThree?.frame.size.height)!) + 5
                readerVC?.view.frame.size.width = (cell?.btnThree?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnThree?.frame.size.height)!
            }
            
            
            readerVC?.origin_size = readerVC?.view.frame
            readerVC?.fullscreen_imagename = imageName
            readerVC?.showInfo()
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.readerVC?.view.alpha = 1
            }, completion: {
                focused in UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.readerVC?.view.frame = UIScreen.main.bounds
                }, completion: nil)})
        }
        else if (option == 3){
            
            let indexPath = IndexPath(row: row, section: 0)
            let cell = storyCollectionView?.cellForItem(at: indexPath) as? TwoOneCollectionViewCell
            
            let theAttributes:UICollectionViewLayoutAttributes! = storyCollectionView!.layoutAttributesForItem(at: indexPath)
            let cellFrameInSuperview:CGRect!  = storyCollectionView!.convert(theAttributes.frame, to: storyCollectionView!.superview)
            
            if (index == 0){
                readerVC?.view.frame.origin.x = 0
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnOne?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnOne?.frame.size.height)!
            }
            else if (index == 1){
                readerVC?.view.frame.origin.x = 0
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y  + ((cell?.btnTwo?.frame.size.height)!) + 5
                readerVC?.view.frame.size.width = (cell?.btnTwo?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnTwo?.frame.size.height)!
            }
            else{
                readerVC?.view.frame.origin.x = ScreenSize.SCREEN_WIDTH - (cell?.btnThree?.frame.size.width)!
                readerVC?.view.frame.origin.y = cellFrameInSuperview.origin.y
                readerVC?.view.frame.size.width = (cell?.btnThree?.frame.size.width)!
                readerVC?.view.frame.size.height = (cell?.btnThree?.frame.size.height)!
            }
            
            
            readerVC?.origin_size = readerVC?.view.frame
            readerVC?.fullscreen_imagename = imageName
            readerVC?.showInfo()
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.readerVC?.view.alpha = 1
            }, completion: {
                focused in UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.readerVC?.view.frame = UIScreen.main.bounds
                }, completion: nil)})
        }
        
        Timer.scheduledTimer(timeInterval: TimeInterval(animation_duration + 0.1), target: self, selector: #selector(self.showDetails), userInfo: nil, repeats: false)
    }
    
    func showDetails(){
        readerVC?.infoBottomView?.alpha = 1.0
    }
    
    func reloadData(){
        print("storyInfo \(String(describing: storyInfo))")
        
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        allStories = mqdbm.getStoryListWithCategory(id: storyInfo?.value(forKey: "id") as! Int) as? [NSDictionary]
        print("allStories = \(String(describing: allStories))")
        
        mqdbm.closeDB()
        
        //data processing
        var stepper : Int = 0
        var counter : Int = 0
        var sectionArray : [NSDictionary] = [NSDictionary]()
        
        for story in allStories! {
            
            //print ("story : \(story)")
            //print ("stepper = \(stepper)")
            //print ("sectionedStories : \(sectionedStories)")
            
            if (stepper == 0){
                
                sectionArray.append(story)
                print ("sectionArray : \(sectionArray)")
                
                if (sectionArray.count == 2){
                    
                    stepper = 1
                    sectionedStories?.append(sectionArray)
                    temoraryArray?.append(sectionArray.count)
                    sectionArray.removeAll()
                }
            }
            else if (stepper == 1){
                sectionArray.append(story)
                
                if (sectionArray.count == 3){
                    stepper = 2
                    sectionedStories?.append(sectionArray)
                    temoraryArray?.append(sectionArray.count)
                    sectionArray.removeAll()
                }
            }
            else if (stepper == 2){
                sectionArray.append(story)
                
                if (sectionArray.count == 3){
                    stepper = 3
                    sectionedStories?.append(sectionArray)
                    temoraryArray?.append(sectionArray.count)
                    sectionArray.removeAll()
                }
            }
            else if (stepper == 3){
                sectionArray.append(story)
                
                if (sectionArray.count == 2){
                    stepper = 0
                    sectionedStories?.append(sectionArray)
                    temoraryArray?.append(sectionArray.count)
                    sectionArray.removeAll()
                }
            }
            
            counter = counter + 1
        }
        
        if sectionArray.count > 0{
            sectionedStories?.append(sectionArray)
            temoraryArray?.append(sectionArray.count)
        }
        
        print("sectionedStories \(String(describing: sectionedStories))")
        print("temoraryArray \(String(describing: temoraryArray))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        /*readerVC = storyboard?.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
        self.view.addSubview((readerVC?.view)!)
        readerVC?.view.alpha = 0*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action
    
    @IBAction func backAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
     @IBAction func notificationAction(){
        let nvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController
        appDelegate.currentNaviCon?.pushViewController(nvc!, animated: true)
    }
    
    @IBAction func searchAction(){
        let svc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        svc?.storyInfo = storyInfo
        appDelegate.currentNaviCon?.pushViewController(svc!, animated: true)
    }
    

    // MARK: - CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (sectionedStories?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if DeviceType.IS_IPHONE_6P{
            if (sectionedStories![indexPath.row]).count == 2{
                return CGSize.init(width: 414.0, height: 240.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count < 3{
                return CGSize.init(width: 414.0, height: 320.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count == 3{
                return CGSize.init(width: 414.0, height: 320.0)
            }
            else{
                return CGSize.init(width: 414.0, height: 240.0)
            }
        }
        else if DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_X || DeviceType.IS_IPHONE_XR{
            if (sectionedStories![indexPath.row]).count == 2{
                return CGSize.init(width: 375.0, height: 240.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count < 3{
                return CGSize.init(width: 375.0, height: 320.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count == 3{
                return CGSize.init(width: 375.0, height: 320.0)
            }
            else{
                return CGSize.init(width: 375.0, height: 240.0)
            }
        }
        else{
            if (sectionedStories![indexPath.row]).count == 2{
                return CGSize.init(width: 320.0, height: 240.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count < 3{
                return CGSize.init(width: 320.0, height: 320.0)
            }
            else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count == 3{
                return CGSize.init(width: 320.0, height: 320.0)
            }
            else{
                return CGSize.init(width: 320.0, height: 240.0)
            }
        }
        
        
        //return CGSize.init(width: 180.0, height: 180.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell:UICollectionViewCell?
        
        if (sectionedStories![indexPath.row]).count == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneOneCollectionViewCell", for: indexPath as IndexPath)
            (cell as! OneOneCollectionViewCell).option = 1
            (cell as! OneOneCollectionViewCell).index = indexPath.row
            (cell as! OneOneCollectionViewCell).processData(items: sectionedStories![indexPath.row])
            (cell as! OneOneCollectionViewCell).storySelectionDelegate = self
        }
        else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count < 3{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneTwoCollectionViewCell", for: indexPath as IndexPath)
            (cell as! OneTwoCollectionViewCell).option = 2
            (cell as! OneTwoCollectionViewCell).index = indexPath.row
            (cell as! OneTwoCollectionViewCell).processData(items: sectionedStories![indexPath.row])
            (cell as! OneTwoCollectionViewCell).storySelectionDelegate = self
        }
        else if (sectionedStories![indexPath.row]).count == 3 && (sectionedStories![indexPath.row - 1]).count == 3{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TwoOneCollectionViewCell", for: indexPath as IndexPath)
            (cell as! TwoOneCollectionViewCell).option = 3
            (cell as! TwoOneCollectionViewCell).index = indexPath.row
            (cell as! TwoOneCollectionViewCell).processData(items: sectionedStories![indexPath.row])
            (cell as! TwoOneCollectionViewCell).storySelectionDelegate = self
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneOneCollectionViewCell", for: indexPath as IndexPath)
            (cell as! OneOneCollectionViewCell).option = 1
            (cell as! OneOneCollectionViewCell).index = indexPath.row
            (cell as! OneOneCollectionViewCell).processData(items: sectionedStories![indexPath.row])
            (cell as! OneOneCollectionViewCell).storySelectionDelegate = self
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        
        /*let rvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
        appDelegate.currentNaviCon?.pushViewController(rvc!, animated: true)*/
        
    }
}
