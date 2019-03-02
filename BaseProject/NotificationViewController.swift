//
//  NotificationViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/1/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,MyFileDownloaderDelegate {
    
    @IBOutlet var listTableView: UITableView!
    var dataArray = [NSDictionary]()
    
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()

    func reloadData(){
        if let path = Bundle.main.path(forResource: "Database", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                self.dataArray = (dict["Stories"] as! [NSDictionary])
                //print("allStories \(allStories)")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }

    @IBAction func backRootAction(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Table Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DeviceType.IS_IPHONE_5  || DeviceType.IS_IPHONE_6{
            return 87.0
        }
        else{
            return 113.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        let info = dataArray[indexPath.row]
        cell.lblTitle?.text = info.object(forKey: "title") as? String
        cell.lblDescription?.text = info.object(forKey: "description") as? String
        //cell.imgIcon?.image = UIImage.init(named: info.object(forKey: "image") as! String)
        
        
        //Images
        
        var imageFile = self.getValue(value: (info.value(forKey: "photo")) as? NSString! as? String) as NSString
        imageFile = imageFile.lastPathComponent as NSString
        //print("imageFile === \(imageFile)")
        
        if (imageFile.length) > 0 {
            
            var cellImage: UIImage? = nil
            
            if (appDelegate.fileExistsInProject(fileName: imageFile as String)) {
                print("fileExistsInProject")
                cellImage = UIImage(named: imageFile as String)
                cell.imgIcon?.image = cellImage
                //cell.activity?.stopAnimating()
            }
            else if (appDelegate.fileExistsInDocumentsDirectory(fileName: imageFile as String)) {
                //print("fileExistsInDocumentsDirectory")
                let arrayPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let path: String? = arrayPaths.first
                let imageFileName = NSURL(fileURLWithPath: path!).appendingPathComponent(imageFile as String)
                
                //print("fileExistsInDocumentsDirectory : \(imageFileName)");
                
                cellImage = UIImage(contentsOfFile: (imageFileName?.path)!)
                cell.imgIcon?.image = cellImage
                //cell.activity?.stopAnimating()
            }
            else{
                //cell.imgIcon?.image = UIImage(named: "demoBook-iPhone6.png")
                //cell.activity?.startAnimating()
                
                var fileDownload = fileDownloadsInProgress?["\(Int(indexPath.row) + noti_image_tag)"] as? MyFileDownloader
                
                if fileDownload == nil {
                    fileDownload = MyFileDownloader()
                    //fileDownload?.url = "\(vehicleUrl)\(imageFile)" as NSString
                    fileDownload?.url = Bundle.main.resourceURL!.appendingPathComponent("Stories").path as NSString
                    fileDownload?.fileName = imageFile
                    fileDownloadsInProgress?["\(Int(indexPath.row) + noti_image_tag)"] = fileDownload
                    fileDownload?.index = Int(indexPath.row) + noti_image_tag
                    fileDownload?.myFileDownloaderDelegate = self
                    fileDownload?.startDownload()
                }
            }
        }
        else {
            cell.imgIcon?.image = UIImage(named: "story_1.jpg")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("notification")
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
        
        print("fileDidDownloaded : \(index - noti_image_tag)")
        
        let indexPath = IndexPath(row: index - noti_image_tag, section: 0)
        let cell = listTableView.cellForRow(at: indexPath) as? TableCell
        //cell?.activity?.stopAnimating()
        if cell != nil {
            if returnImage == nil {
                print("****** No Image")
                cell?.imgIcon?.image = UIImage(named: "story_1.jpg")
            }
            else {
                cell?.imgIcon?.image = returnImage
            }
        }
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
