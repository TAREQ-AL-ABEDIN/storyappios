//
//  ViewController.swift
//  Task1_InfiniteUICollectionView
//
//  Created by MOSHIOUR on 1/27/19.
//  Copyright © 2019 moshiour. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CategoryViewController: UIViewController,GADInterstitialDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //var imageArray = [UIImage(named: "album1.jpg"),UIImage(named: "album2.jpg"),UIImage(named: "album3.jpg"),UIImage(named: "album4.jpg"),UIImage(named: "album5.jpg"),UIImage(named: "album6.jpg"),UIImage(named: "album7.jpg")]
    
    
    let infiniteSize = 10000000
    let flowLayout = ZoomFlowLayout()
    var dataArray = [NSDictionary]()
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
    var interstitial: GADInterstitial!
    var ad_shown_already = false
    
    func reloadData(){
        
        fileDownloadsInProgress?.removeAllObjects()
        
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        self.dataArray = mqdbm.getCategoryList() as! [NSDictionary]
        print("self.dataArray = \(String(describing: self.dataArray))")
        
        mqdbm.closeDB()
        
        if dataArray.count > 0{
            collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Zoomed & snapped cells"
        
        guard let collectionView = collectionView else { fatalError() }
        //collectionView.decelerationRate = .fast // uncomment if necessary
        
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        let midIndexPath = IndexPath(row: infiniteSize / 2, section: 0)
        collectionView.scrollToItem(at: midIndexPath,
                                    at: .centeredHorizontally,
                                    animated: false)
        
        //admob ad
        ad_shown_already = false
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.reloadData()
        
        if appDelegate.bannerView != nil{
            appDelegate.bannerView.alpha = 1
        }
    }
    
    // MARK: - Button Action
    
    @IBAction func showSidePanel(){
        NSLog("showSidePanel")
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func notificationAction(){
        let nvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "NotificationViewController") as? NotificationViewController
        appDelegate.currentNaviCon?.pushViewController(nvc!, animated: true)
    }
    
    @IBAction func fbAction(){
        
    }
    
    @IBAction func twitterAction(){
        
    }
    
    @IBAction func instagramAction(){
        
    }
    
    @IBAction func settingAction(){
        let svc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController
        appDelegate.isSetting_flag = 1
        self.navigationController?.pushViewController(svc!, animated: true)
    }
    
    //MARK:- Admob
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
        
        if interstitial.isReady && !ad_shown_already {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
        self.ad_shown_already = true
        appDelegate.bannerView.alpha = 0
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        appDelegate.bannerView.alpha = 1
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitials = GADInterstitial(adUnitID: appDelegate.admob_app_inters_unitID)
        interstitials.delegate = self
        interstitials.load(GADRequest())
        return interstitials
    }
}



extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource,MyFileDownloaderDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return imageArray.count
        
        return infiniteSize
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! CollectionViewCell
        
        
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.masksToBounds = true
        
        if dataArray.count > 0{
            let cat_info = dataArray[indexPath.row % dataArray.count]
            cell.lblTitle.text = (cat_info.value(forKey: "name") as! String)
            
            //free or paid
            let cid = cat_info.value(forKey: "id") as! Int
            
            if paid_categories.contains(cid){
                if cid == 2 && ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                    cell.imgLock?.alpha = 0
                }
                else if cid == 7 && ((prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                    cell.imgLock?.alpha = 0
                }
                else if cid == 11 && ((prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                    cell.imgLock?.alpha = 0
                }
                else{
                    cell.imgLock?.alpha = 1
                }
            }
            else{
                cell.imgLock?.alpha = 0
            }
            
            //image
            var imageFile = self.getValue(value: (cat_info.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            //cell.iconImg?.image = UIImage.init(named: imageFile as String)
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                cell.cellImageView?.image = UIImage.init(named: imageFile as String)
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    cell.cellImageView.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    cell.cellImageView.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["\(Int(indexPath.row) + cat_image_tag)"] as? MyFileDownloader
                    
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(imageUrl)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["\(Int(indexPath.row) + cat_image_tag)"] = fileDownload
                        fileDownload?.index = Int(indexPath.row) + cat_image_tag
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
            }
            else {
                cell.cellImageView?.image = UIImage(named: "")
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //free or paid
        let cat_info = dataArray[indexPath.row % dataArray.count]
        let cid = cat_info.value(forKey: "id") as! Int
        
        if paid_categories.contains(cid) {
            if cid == 2 && ((prefs.value(forKey: product_adventure) != nil && (prefs.value(forKey: product_adventure) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: cat_info)
            }
            else if cid == 7 && ((prefs.value(forKey: product_flashFiction) != nil && (prefs.value(forKey: product_flashFiction) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: cat_info)
            }
            else if cid == 11 && ((prefs.value(forKey: product_scifi) != nil && (prefs.value(forKey: product_scifi) as! String) == "purchased") || (prefs.value(forKey: product_allCategories) != nil && (prefs.value(forKey: product_allCategories) as! String) == "purchased")){
                self.goNext(withInfo: cat_info)
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
                    collectionView.reloadData()
                    
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
            self.goNext(withInfo: cat_info)
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
    }
    
    //MARK: - Other Function
    
    func getValue(value : String?) -> String{
        if (value != nil && !(value?.isEqual(NSNull()))! && !(value?.contains("null"))! && value!.count > 0){
            return value! as String
        }
        else{
            return ""
        }
    }
    
    
    func fileDidDownloaded(_ index: Int, withImage returnImage: UIImage?) {
        
        print("fileDidDownloaded : \(index - cat_image_tag)")
        
        let indexPath = IndexPath(row: index - cat_image_tag, section: 0)
        let cell = collectionView?.cellForItem(at: indexPath) as? CollectionViewCell
        
        if cell != nil {
            if returnImage == nil {
                print("****** No Image")
                cell?.cellImageView?.image = UIImage(named: "")
            }
            else {
                cell?.cellImageView?.image = returnImage
            }
        }
        
        collectionView?.reloadItems(at: [indexPath])
    }
}

