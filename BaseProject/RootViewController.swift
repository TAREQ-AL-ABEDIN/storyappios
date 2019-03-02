//
//  RootViewController.swift
//  StoryApp
//
//  Created by Admin on 1/24/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit
import SystemConfiguration
//import PageController

let cat_image_tag = 1000
let noti_image_tag = 10000

class RootViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,MyFileDownloaderDelegate {
    
    @IBOutlet weak var pageControl:UIPageControl?
    @IBOutlet weak var listCollectionView:UICollectionView?
    
    @IBOutlet weak var lblNoOfNotific:UILabel?
    
    
    var cellSize = CGSize.zero
    var mList = [Any]()
    var dataArray = [NSDictionary]()
    
    var mostRecentOffset : CGPoint = CGPoint()
    
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
    func reloadData(){
        
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        self.dataArray = mqdbm.getCategoryList() as! [NSDictionary]
        print("self.dataArray = \(String(describing: self.dataArray))")
        
        mqdbm.closeDB()
        
        pageControl?.numberOfPages = dataArray.count
        listCollectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
        
        //var width: CGFloat = screenFrame.size.width * cv.frame.size.height / screenFrame.size.height
        
        /*let width: CGFloat = 212
         cellSize = CGSize(width: width, height: (listCollectionView?.frame.size.height)!)
         cellSize.height -= 1
         
         mList = ["1","2","3"]*/
        
        var insets = self.listCollectionView?.contentInset
        let value = (self.view.frame.size.width - (self.listCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets?.left = value
        insets?.right = value
        self.listCollectionView?.contentInset = insets!
        self.listCollectionView?.decelerationRate = UIScrollViewDecelerationRateFast;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       appDelegate.noConnectedToNetwork()
        
    }
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
     if mList.count > 0 {
     let centerX: CGFloat = (listCollectionView?.center.x)!
     for cell: UICollectionViewCell in (listCollectionView?.visibleCells)! {
     var pos = cell.convert(CGPoint.zero, to: view)
     pos.x += cellSize.width / 2.0
     let distance: CGFloat = fabs(centerX - pos.x)
     let scale: CGFloat = 1.0 - (distance / centerX) * 0.1
     cell.transform = CGAffineTransform(scaleX: scale, y: scale)
     }
     }
     }
     
     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
     // for custom paging
     let movingX: CGFloat = velocity.x * scrollView.frame.size.width
     var newOffsetX: CGFloat = scrollView.contentOffset.x + movingX
     if newOffsetX < 0 {
     newOffsetX = 0
     }
     else if newOffsetX > (CGFloat(cellSize.width) * CGFloat(mList.count - 1)) {
     newOffsetX = (CGFloat(cellSize.width) * CGFloat(mList.count - 1))
     }
     else {
     let newPage = CGFloat((newOffsetX / cellSize.width + (CGFloat(Int(newOffsetX) % Int(cellSize.width)) > CGFloat(cellSize.width) / 2.0 ? 1 : 0)))
     newOffsetX = CGFloat((newPage * cellSize.width))
     
     }
     
     //targetContentOffset.pointee = CGFloat( newOffsetX )
     
     }*/
    
    
    @IBAction func showSidePanel(){
        NSLog("showSidePanel")
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    // MARK: - pageControl
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let cell_width:CGFloat = 163.0
        
        pageControl?.currentPage = Int((listCollectionView?.contentOffset.x)!) / Int((cell_width))
    }
    
    // MARK: - Button Action
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
    
    // MARK: - CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if DeviceType.IS_IPHONE_5{
            return CGSize.init(width: 163, height: 108)
        }
        else{
            return CGSize.init(width: 212, height: 140)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleCollectionViewCell", for: indexPath as IndexPath) as! SingleCollectionViewCell
        
        let info = dataArray[indexPath.row]
        cell.iconImg?.layer.cornerRadius = 13.0
        cell.iconImg?.clipsToBounds = true
        
        cell.lblTitle?.text = info.object(forKey: "name") as? String
        
        //images
        
        var imageFile = self.getValue(value: (info.value(forKey: "photo")) as? NSString! as? String) as NSString
        imageFile = imageFile.lastPathComponent as NSString
        print("imageFile === \(imageFile)")
        
        //cell.iconImg?.image = UIImage.init(named: imageFile as String)
        
        if (imageFile.length) > 0 {
            
            var cellImage: UIImage? = nil
            
            cell.iconImg?.image = UIImage.init(named: imageFile as String)
            
            if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                print("fileExistsInProject")
                cellImage = UIImage(named: imageFile as String)
                cell.iconImg?.image = cellImage
                //cell.activity?.stopAnimating()
            }
            else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                //print("fileExistsInDocumentsDirectory")
                let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path: String? = arrayPaths.first
                let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                
                //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                
                cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                cell.iconImg?.image = cellImage
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
            cell.iconImg?.image = UIImage(named: "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let hvc = appDelegate.storyBoard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        hvc?.storyInfo = dataArray[indexPath.row]
        appDelegate.currentNaviCon?.pushViewController(hvc!, animated: true)
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
     if DeviceType.IS_IPHONE_5{
     //let gap: CGFloat = (320 - 163) / 2.0
     //return UIEdgeInsetsMake(0, gap, 0, gap)
     
     }
     else{
     let gap: CGFloat = (414 - 212) / 2.0
     return UIEdgeInsetsMake(0, gap, 0, gap)
     
     }
     }*/
    
    
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
        let cell = listCollectionView?.cellForItem(at: indexPath) as? SingleCollectionViewCell
        //cell?.activity?.stopAnimating()
        if cell != nil {
            if returnImage == nil {
                print("****** No Image")
                cell?.iconImg?.image = UIImage(named: "")
            }
            else {
                cell?.iconImg?.image = returnImage
            }
        }
        
        listCollectionView?.reloadItems(at: [indexPath])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*class CustomMenuCell: MenuCell {
 
 required init(frame: CGRect) {
 super.init(frame: frame)
 
 contentInset = UIEdgeInsets(top: 0, left: 40, bottom: 1, right: 40)
 }
 
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 }
 
 override func updateData() {
 super.updateData()
 titleLabel.textColor = selected ? UIColor.black : UIColor.gray
 }
 }
 
 class RootViewController: PageController {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 //menuBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
 //menuBar.registerClass(CustomMenuCell.self)
 delegate = self
 //viewControllers = createViewControllers()
 print("viewControllers : \(viewControllers)")
 }
 
 @IBAction func showSidePanel(){
 NSLog("showSidePanel")
 if let drawerController = navigationController?.parent as? KYDrawerController {
 drawerController.setDrawerState(.opened, animated: true)
 }
 }
 
 }
 
 extension RootViewController {
 
 func createViewControllers() -> [UIViewController] {
 let names = [
 "Test",
 "Innovation",
 "Technology",
 "Life",
 "Bussiness",
 "Economics",
 "Financial",
 "Market",
 ]
 
 let viewControllers = names.map { name -> TestViewController in
 //let viewController = TestViewController()
 let viewController = TestViewController()
 viewController.title = name
 //viewController.collectionView?.scrollsToTop = false
 return viewController
 }
 
 //viewControllers.first?.collectionView?.scrollsToTop = true
 return viewControllers
 }
 }
 
 extension RootViewController: PageControllerDelegate {
 
 func pageController(_ pageController: PageController, didChangeVisibleController visibleViewController: UIViewController, fromViewController: UIViewController?) {
 print("now title is \(pageController.visibleViewController?.title)")
 print("did change from \(fromViewController?.title) to \(visibleViewController.title)")
 if pageController.visibleViewController == visibleViewController {
 print("visibleViewController is assigned pageController.visibleViewController")
 }
 
 if let viewController = fromViewController as? TestViewController  {
 //viewController.collectionView?.scrollsToTop = false
 }
 if let viewController = visibleViewController as? TestViewController  {
 //viewController.collectionView?.scrollsToTop = true
 }
 }
 }*/

