//
//  CollectionViewCell.swift
//  StoryApp
//
//  Created by Admin on 1/16/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class OneTwoCollectionViewCell: UICollectionViewCell,MyFileDownloaderDelegate {
    
    @IBOutlet weak var viewOne:UIView?
    @IBOutlet weak var imgViewOne:UIImageView?
    @IBOutlet weak var lblTitleOne:UILabel?
    @IBOutlet weak var lblDisOne:UILabel?
    @IBOutlet weak var btnOne:UIButton?
    
    @IBOutlet weak var viewTwo:UIView?
    @IBOutlet weak var imgViewTwo:UIImageView?
    @IBOutlet weak var lblTitleTwo:UILabel?
    @IBOutlet weak var lblDisTwo:UILabel?
    @IBOutlet weak var btnTwo:UIButton?
    
    @IBOutlet weak var viewThree:UIView?
    @IBOutlet weak var imgViewThree:UIImageView?
    @IBOutlet weak var lblTitleThree:UILabel?
    @IBOutlet weak var lblDisThree:UILabel?
    @IBOutlet weak var btnThree:UIButton?
    
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
    var storySelectionDelegate : StorySelectionDelegate?
    
    var index : Int = 0
    var option : Int = 0
    var storySubArray : [NSDictionary]? = nil
    
    func processData(items : [NSDictionary]){
        
        self.storySubArray = items
        
        if items.count == 3{
            
            //button one
            var story = items[0]
            viewOne?.alpha = 1.0
            
            //imgViewOne?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleOne?.text = (story.value(forKey: "title") as! String)
            //lblDisOne?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "name") as! String, labelName: lblTitleOne!, height: (imgViewOne?.frame.size.height)!)
            
            //btnOne?.setTitle(String(format : "%d-%d",index,0), for: .normal)
            
            //image One
            
            var imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["1"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["1"] = fileDownload
                        fileDownload?.index = 1
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewOne?.image = UIImage(named: "")
            }
            
            //button two
            
            story = items[1]
            viewTwo?.alpha = 1.0
            
            //imgViewTwo?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleTwo?.text = (story.value(forKey: "title") as! String)
            //lblDisTwo?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "name") as! String, labelName: lblTitleTwo!, height: (imgViewTwo?.frame.size.height)!)
            
            //btnTwo?.setTitle(String(format : "%d-%d",index,1), for: .normal)
            
            //image Two
            
            imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewTwo?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewTwo?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["2"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["2"] = fileDownload
                        fileDownload?.index = 2
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewTwo?.image = UIImage(named: "")
            }
            
            //button three
            
            story = items[2]
            viewThree?.alpha = 1.0
            
            //imgViewThree?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleThree?.text = (story.value(forKey: "title") as! String)
            //lblDisThree?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "name") as! String, labelName: lblTitleThree!, height: (imgViewThree?.frame.size.height)!)
            
            //btnThree?.setTitle(String(format : "%d-%d",index,2), for: .normal)
            
            //image Three
            
            imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewThree?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewThree?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["3"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["3"] = fileDownload
                        fileDownload?.index = 3
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewThree?.image = UIImage(named: "")
            }
            
        }
        else if (items.count == 2){
            //button one
            var story = items[0]
            viewOne?.alpha = 1.0
            
            //imgViewOne?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleOne?.text = (story.value(forKey: "title") as! String)
            //lblDisOne?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "name") as! String, labelName: lblTitleOne!, height: (imgViewOne?.frame.size.height)!)
            
            //btnOne?.setTitle(String(format : "%d-%d",index,0), for: .normal)
            
            //image One
            
            var imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["1"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["1"] = fileDownload
                        fileDownload?.index = 1
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewOne?.image = UIImage(named: "")
            }
            
            //button two
            
            story = items[1]
            viewTwo?.alpha = 1.0
            
            //imgViewTwo?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleTwo?.text = (story.value(forKey: "title") as! String)
            //lblDisTwo?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "title") as! String, labelName: lblTitleTwo!, height: (imgViewTwo?.frame.size.height)!)
            
            //btnTwo?.setTitle(String(format : "%d-%d",index,1), for: .normal)
            
            //image Two
            
            imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewTwo?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewTwo?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["2"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["2"] = fileDownload
                        fileDownload?.index = 2
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewTwo?.image = UIImage(named: "")
            }
        }
        else if (items.count == 1){
            //button one
            let story = items[0]
            viewOne?.alpha = 1.0
            
            //imgViewOne?.image = UIImage.init(named: story.value(forKey: "photo") as! String)
            //lblTitleOne?.text = (story.value(forKey: "title") as! String)
            //lblDisOne?.text = (story.value(forKey: "description") as! String)
            
            getLabelsize(text: story.value(forKey: "name") as! String, labelName: lblTitleOne!, height: (imgViewOne?.frame.size.height)!)
            
            //btnOne?.setTitle(String(format : "%d-%d",index,0), for: .normal)
            
            //image One
            
            var imageFile = self.getValue(value: (story.value(forKey: "photo")) as? NSString! as? String) as NSString
            imageFile = imageFile.lastPathComponent as NSString
            print("imageFile === \(imageFile)")
            
            if (imageFile.length) > 0 {
                
                var cellImage: UIImage? = nil
                
                if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                    print("fileExistsInProject")
                    cellImage = UIImage(named: imageFile as String)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                    //print("fileExistsInDocumentsDirectory")
                    let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let path: String? = arrayPaths.first
                    let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                    
                    //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                    
                    cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                    imgViewOne?.image = cellImage
                    //cell.activity?.stopAnimating()
                }
                else{
                    //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                    //cell.activity?.startAnimating()
                    
                    var fileDownload = fileDownloadsInProgress?["1"] as? MyFileDownloader
                    if fileDownload == nil {
                        fileDownload = MyFileDownloader()
                        fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                        fileDownload?.fileName = imageFile
                        fileDownloadsInProgress?["1"] = fileDownload
                        fileDownload?.index = 1
                        fileDownload?.myFileDownloaderDelegate = self
                        fileDownload?.startDownload()
                    }
                }
                
            }
            else {
                imgViewOne?.image = UIImage(named: "")
            }
        }
    }
    
    @IBAction func buttonPressed(_button : UIButton){
        /*let story = storySubArray![_button.tag]
        let image_name = story.value(forKey: "image") as! String
        print("buttonPressed : \(_button.currentTitle) == \(image_name)")
        self.storySelectionDelegate?.didSelectStory(title: _button.currentTitle!, option : option, imageName: image_name)*/
        
        if _button.tag >= (storySubArray?.count)!{
            return
        }
        
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
        
        let rvc = storyboard.instantiateViewController(withIdentifier: "ReaderViewController") as? ReaderViewController
        rvc?.storyInfo = storySubArray![_button.tag]
        appDelegate.currentNaviCon?.pushViewController(rvc!, animated: true)
    }
    
    func getLabelsize(text:String, labelName:UILabel, height:CGFloat) {
        let constraint = CGSize(width: (labelName.frame.size.width), height: CGFloat.greatestFiniteMagnitude)
        var size: CGSize
        let context = NSStringDrawingContext()
        labelName.text = text
        let boundingBox: CGSize? = labelName.text?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: labelName.font as Any], context: context).size
        
        size = CGSize(width: ceil((boundingBox?.width)!), height: ceil((boundingBox?.height)!))
        labelName.frame = CGRect.init(x: (labelName.frame.origin.x), y: height - size.height - 20, width: (labelName.frame.size.width), height: size.height)
        
        
        //print("====\(size.height)")
        //print("****\(String(describing: lblPrice?.frame.origin.y))")
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
        
        //let indexPath = IndexPath(row: index - cat_image_tag, section: 0)
        /*let cell = listCollectionView?.cellForItem(at: indexPath) as? SingleCollectionViewCell
         //cell?.activity?.stopAnimating()
         if cell != nil {
         if returnImage == nil {
         print("****** No Image")
         cell?.iconImg?.image = UIImage(named: "")
         }
         else {
         cell?.iconImg?.image = returnImage
         }
         }*/
        
        if index == 1{
            if returnImage != nil {
                imgViewOne?.image = returnImage
            }
        }
        else if index == 2{
            if returnImage != nil {
                imgViewTwo?.image = returnImage
            }
        }
        else if index == 3{
            if returnImage != nil {
                imgViewThree?.image = returnImage
            }
        }
    }
    
}
