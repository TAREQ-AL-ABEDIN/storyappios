//
//  SearchViewController.swift
//  StoryApp
//
//  Created by M Khairul Bashar on 2/1/18.
//  Copyright © 2018 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MyFileDownloaderDelegate  {

    @IBOutlet var listTableView: UITableView!
    var dataArray = [NSDictionary]()
    
    var storyInfo: NSDictionary? = nil
    
    @IBOutlet var searchView: UIView!
    
    @IBOutlet var txtSearch:UITextField?
    
    var fileDownloadsInProgress : NSMutableDictionary? = NSMutableDictionary()
    
    func reloadData(){
        let mqdbm = MyQueryDBManager.sharedManager() as! MyQueryDBManager
        _ = mqdbm.openDB()
        
        if ((txtSearch!.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)).count > 0){
            self.dataArray = (mqdbm.getStroyWithSearchKey(searchKey: (txtSearch?.text)!, id: storyInfo?.value(forKey: "id") as! Int) as? [NSDictionary])!
        }
        else{
            self.dataArray = (mqdbm.getStroyWithSearchKey(searchKey: "", id: storyInfo?.value(forKey: "id") as! Int) as? [NSDictionary])!
        }
        
        //print("dataArray = \(String(describing: dataArray))")
        
        mqdbm.closeDB()
        
        listTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()

        searchView.layer.cornerRadius = 10.0
        searchView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }
    
    @IBAction func backRootAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchAction(){
        self.reloadData()
    }
    // MARK: - Table Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_6{
            return 87.0
        }
        else{
            return 113.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:TableCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        
        let info = dataArray[indexPath.row]
        cell.lblTitle?.text = info.object(forKey: "name") as? String
        //cell.lblDescription?.text = info.object(forKey: "description") as? String
        //cell.imgIcon?.image = UIImage.init(named: info.object(forKey: "image") as! String)
        
        
        //Images
        
        var imageFile = self.getValue(value: (info.value(forKey: "photo")) as? NSString! as? String) as NSString
        imageFile = imageFile.lastPathComponent as NSString
        //print("imageFile === \(imageFile)")
        
        //cell.imgIcon?.image = UIImage.init(named: imageFile as String)
        
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
                    fileDownload?.url = "\(storyImagePath)\(imageFile)" as NSString
                    fileDownload?.fileName = imageFile
                    fileDownloadsInProgress?["\(Int(indexPath.row) + noti_image_tag)"] = fileDownload
                    fileDownload?.index = Int(indexPath.row) + noti_image_tag
                    fileDownload?.myFileDownloaderDelegate = self
                    fileDownload?.startDownload()
                }
            }
        }
        else {
            cell.imgIcon?.image = UIImage(named: "story_2.jpg")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        rvc?.storyInfo = dataArray[indexPath.row]
        appDelegate.currentNaviCon?.pushViewController(rvc!, animated: true)
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
                cell?.imgIcon?.image = UIImage(named: "story_2.jpg")
            }
            else {
                cell?.imgIcon?.image = returnImage
            }
        }
    }
    
    // MARK: - TextField Delegates
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            self.reset()
        }
        super.touchesBegan(touches, with: event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.reset()
        return true
    }
    
    @objc func reset(){
        txtSearch?.resignFirstResponder()
        
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
