//
//  ReaderViewController.swift
//  StoryApp
//
//  Created by Admin on 1/21/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,MyFileDownloaderDelegate {
    
    @IBOutlet weak var scrollView : UIScrollView?
    @IBOutlet weak var listTable : UITableView?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var infoView : UIView?
    @IBOutlet weak var infoBottomView : UIView?
    @IBOutlet weak var readerView : UIView?
    @IBOutlet weak var backView : UIView?
    
    @IBOutlet weak var bgImageView : UIImageView?
    @IBOutlet weak var backBgImageView : UIImageView?
    @IBOutlet weak var lblTitle : UILabel?
    @IBOutlet weak var lblDesc : UILabel?
    @IBOutlet weak var btnDown : UIButton?
    
    @IBOutlet weak var lblTemp : UILabel?
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
    fileprivate let cellId = "cell"
    
    var dataArray : [NSDictionary]? = nil
    var storyInfo: NSDictionary? = nil
    var tapStoryInfo:NSDictionary? = nil
    
    var origin_size : CGRect? = nil
    var fullscreen_imagename : String? = nil
    var lastContentOffset: CGFloat = 0
    
    var contentArray : NSMutableArray? = NSMutableArray()
    var did_tap = 0
    
    func showInfo(){
        
        if fullscreen_imagename == nil {
            return
        }
        
        print("fullscreen_imagename : \(fullscreen_imagename ?? "1111")")
        bgImageView?.image = UIImage.init(named: fullscreen_imagename!)
        backBgImageView?.image = UIImage.init(named: fullscreen_imagename!)
        
        self.backView?.alpha = 0
    }
    
    func reloadData(){
        
        print("storyInfo: \(String(describing: storyInfo))")
        
        if storyInfo != nil{
            //appDelegate.storiesDetailsDataSync.requestForSroriesDetails(id: String(format:"%d",storyInfo?.object(forKey: "id") as! Int))
            
            let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
            _ = mqdbm.openDB()
            
            dataArray = mqdbm.getStoryDetails(id: storyInfo?.value(forKey: "id") as! Int) as? [NSDictionary]
            print("dataArray = \(String(describing: dataArray))")
            
            mqdbm.closeDB()
            
            lblTitle?.text = storyInfo?.value(forKey: "name") as? String
            //lblDesc?.text = storyInfo?.value(forKey: "description") as? String
            //bgImageView?.image = UIImage.init(named: storyInfo?.value(forKey: "photo") as! String)
            
            //bg image
            
            if (storyInfo?.value(forKey: "photo") != nil) && !(((storyInfo?.value(forKey: "photo")  as AnyObject).isKind(of: NSNull.self))){
                //let imageFile: NSString? = (self.getValue(value:(storyInfo?.value(forKey: "photo")  as! String)) as NSString).lastPathComponent as NSString
                let imageFile: NSString? = (self.getValue(value:(storyInfo?.value(forKey: "photo") as! String)) as NSString)
                
                if (imageFile?.length)! > 0 {
                    
                    var cellImage: UIImage? = nil
                    
                    if (appDelegate.fileExistsInProject(fileName: imageFile! as String)) {
                        print("fileExistsInProject")
                        cellImage = UIImage(named: imageFile! as String)
                        bgImageView?.image = cellImage
                    }
                    else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile! as String)) {
                        //print("fileExistsInDocumentsDirectory")
                        let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                        let path: String? = arrayPaths.first
                        let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile! as String)
                        cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                        bgImageView?.image = cellImage
                    }
                    else{
                        //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                        //cell.activity?.startAnimating()
                        
                        var fileDownload = fileDownloadsInProgress?["1"] as? MyFileDownloader
                        
                        if fileDownload == nil {
                            fileDownload = MyFileDownloader()
                            fileDownload?.url = "\(storyImagePath)\(imageFile!)" as NSString
                            fileDownload?.fileName = imageFile
                            fileDownloadsInProgress?["1001"] = fileDownload
                            fileDownload?.index = 1001
                            fileDownload?.myFileDownloaderDelegate = self
                            fileDownload?.startDownload()
                        }
                    }
                }
            }
        }
        
        
        backBgImageView?.image = bgImageView?.image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listTable!.register(TableViewCell.self, forCellReuseIdentifier: cellId)
        
        self.reloadData()
        
        //scrollView?.addSubview(containerView!)
        infoView?.frame.size.height = (scrollView?.frame.size.height)!
        readerView?.frame.size.height = (scrollView?.frame.size.height)!
        readerView?.frame.origin.y = ScreenSize.SCREEN_HEIGHT
        containerView?.frame.size.height = ((scrollView?.frame.size.height)! * 2) + 336.0
        scrollView?.contentSize = CGSize(width: self.view.frame.size.width, height: (containerView?.frame.size.height)!)
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 254, right: 0)
        self.listTable?.contentInset = insets
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.listTable?.addGestureRecognizer(tap)
        self.containerView?.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.noConnectedToNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if storyInfo != nil{
            appDelegate.storiesDetailsDataSync.requestForSroriesDetails(id: String(format:"%d",storyInfo?.object(forKey: "id") as! Int))
        }
    }
    
    
    // MARK: - Button Action
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backRootAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func downAction(){
       
    }
    
    func tableTapped(tap:UITapGestureRecognizer) {
        
        self.did_tap = 1
        self.contentArray?.add("++++++")
        
        if (contentArray?.count)! > (dataArray?.count)!{
            return
        }
        else{
            self.tapStoryInfo = dataArray?[(self.contentArray?.count)! - 1]
            print("tapStoryInfo : \(String(describing: tapStoryInfo))")
        }

        let indexPath:IndexPath = IndexPath(row:(self.contentArray!.count - 1), section:0)
        self.listTable?.insertRows(at:[indexPath], with: .bottom)
        NSLog("Added a new cell to the bottom!")
        
        self.scrollToBottom()
    }
    
    func scrollToMiddle(){
        let indexPath:IndexPath = IndexPath(row:(self.contentArray!.count - 1), section:0)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.listTable?.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
        }, completion: nil)
        
    }
    
    func scrollToBottom(){
        let indexPath = IndexPath(row: self.contentArray!.count-1, section: 0)
        self.listTable!.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    
    @IBAction func showReaderView(){
        
        UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView?.contentOffset.y = ScreenSize.SCREEN_HEIGHT
        }, completion: nil)
        
        if (contentArray!.count > 4 && contentArray!.count < dataArray!.count){
            let indexPath:IndexPath = IndexPath(row:(self.contentArray!.count - 1), section:0)
            self.listTable?.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    @IBAction func hideReaderView(){
        UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.scrollView?.contentOffset.y = 0
        }, completion: nil)
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (contentArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TableViewCell
        let info = dataArray![indexPath.row]
        
        cell.messageLabel.text = ((info as AnyObject).value(forKey: "content") as? String)!
        cell.isIncoming = indexPath.row % 2 == 0
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == listTable{
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    

    func fileDidDownloaded(_ index: Int, withImage returnImage: UIImage?) {
        
        print("fileDidDownloaded : \(index)")
        
        if returnImage == nil {
            print("****** No Image")
            bgImageView?.image = UIImage(named: "")
        }
        else {
            bgImageView?.image = returnImage
        }
        
        backBgImageView?.image = bgImageView?.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func touchAction(){
        if origin_size == nil {
            return
        }
        
        self.infoBottomView?.alpha = 0
        
        UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.frame = self.origin_size!
        }, completion: {focused in
            UIView.animate(withDuration: animation_duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.alpha = 0
            }, completion: nil)})
    }
    

    func getValue(value : String?) -> String{
        if (value != nil && !(value?.isEqual(NSNull()))! && !(value?.contains("null"))! && value!.count > 0){
            return value! as String
        }
        else{
            return ""
        }
    }
}
