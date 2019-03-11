//
//  ViewController.swift
//  Task1_InfiniteUICollectionView
//
//  Created by MOSHIOUR on 1/27/19.
//  Copyright © 2019 moshiour. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //var imageArray = [UIImage(named: "album1.jpg"),UIImage(named: "album2.jpg"),UIImage(named: "album3.jpg"),UIImage(named: "album4.jpg"),UIImage(named: "album5.jpg"),UIImage(named: "album6.jpg"),UIImage(named: "album7.jpg")]
    
    
    let infiniteSize = 10000000
    let flowLayout = ZoomFlowLayout()
    var dataArray = [NSDictionary]()
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
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
        
         self.reloadData()
        
        let midIndexPath = IndexPath(row: infiniteSize / 2, section: 0)
        collectionView.scrollToItem(at: midIndexPath,
                                    at: .centeredHorizontally,
                                    animated: false)
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
        hvc?.storyInfo = dataArray[indexPath.row % dataArray.count]
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

