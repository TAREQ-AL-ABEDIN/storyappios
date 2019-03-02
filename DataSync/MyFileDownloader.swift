//
//  MyFileDownloader.swift
//  BaseProject
//
//  Created by Admin on 9/29/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

protocol MyFileDownloaderDelegate{
    func fileDidDownloaded(_ index: Int, withImage returnImage: UIImage?)
}

class MyFileDownloader: NSObject,URLSessionTaskDelegate {

    var index: Int = 0
    var url: NSString? = ""
    var fileName : NSString? = ""
    var downloadTask: URLSessionDataTask?
    var myFileDownloaderDelegate: MyFileDownloaderDelegate?
    
    func startDownload() {
        print("startDownload : \(url ?? "nnnnn")")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let uniquePath = "\(paths[0])/\(fileName! as String)"
        
        var image: UIImage? = nil
        
        if FileManager.default.fileExists(atPath: uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)
        }
        
        if image != nil {
            myFileDownloaderDelegate?.fileDidDownloaded(index, withImage: image!)
        }
        else {
            if (fileName?.length)! > 0 {

                let dURL = URL(string: ((url)?.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!)!)
                
                /*let session = URLSession.shared
                downloadTask = session.downloadTask(with: dURL!)
                downloadTask?.resume()*/
                
                let session = URLSession.shared
                downloadTask = session.dataTask(with: dURL!, completionHandler: { (data, response, error) in
                    
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    let uniquePath = NSURL(fileURLWithPath: appDelegate.getPath(fileName:self.fileName! as String))
                    let downloadedImage = UIImage(data: data!)
                    
                    if downloadedImage == nil{
                        DispatchQueue.main.async(execute: {
                            self.myFileDownloaderDelegate?.fileDidDownloaded(self.index, withImage: downloadedImage)
                            
                        })
                        return
                    }
                    
                    do {
                        
                        if (self.fileName!).range(of: ".png", options: .caseInsensitive).location != NSNotFound {
                            print("Png Write")
                            try UIImagePNGRepresentation(downloadedImage!)?.write(to: uniquePath as URL, options: .atomic)
                        }
                        else if (self.fileName!).range(of: ".jpg", options: .caseInsensitive).location != NSNotFound || (self.fileName!).range(of: ".jpeg", options: .caseInsensitive).location != NSNotFound {
                            print("JPG Write")
                            try UIImageJPEGRepresentation(downloadedImage!, 1.0)?.write(to: uniquePath as URL, options: .atomic)
                        }
                        else {
                            print("Normal Write")
                            try UIImageJPEGRepresentation(downloadedImage!, 1.0)?.write(to: uniquePath as URL, options: .atomic)
                        }
                        
                    } catch {
                        print(error)
                        print("file cant not be save at path \(uniquePath), with error : \(error)");
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.myFileDownloaderDelegate?.fileDidDownloaded(self.index, withImage: downloadedImage!)
                    })
                    
                })
                
                downloadTask?.resume()
            }
        }
    }
    
    /*func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        /*if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }*/
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("didFinishDownloadingTo")
        
        let uniquePath = NSURL(fileURLWithPath: appDelegate.getPath(fileName:fileName! as String))
        let downloadedImage = try! UIImage(data: Data(contentsOf: location))
        
        do {
            
            if (fileName!).range(of: ".png", options: .caseInsensitive).location != NSNotFound {
                print("Png Write")
                try UIImagePNGRepresentation(downloadedImage!)?.write(to: uniquePath as URL, options: .atomic)
            }
            else if (fileName!).range(of: ".jpg", options: .caseInsensitive).location != NSNotFound || (fileName!).range(of: ".jpeg", options: .caseInsensitive).location != NSNotFound {
                print("JPG Write")
                try UIImageJPEGRepresentation(downloadedImage!, 1.0)?.write(to: uniquePath as URL, options: .atomic)
            }
            else {
                print("Normal Write")
                    try UIImageJPEGRepresentation(downloadedImage!, 1.0)?.write(to: uniquePath as URL, options: .atomic)
            }
            
        } catch {
            print(error)
            print("file cant not be save at path \(uniquePath), with error : \(error)");
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Task completed: \(task), error: \(String(describing: error?.localizedDescription))")
    }*/
    
    func isDownloading() -> Bool {
        if downloadTask == nil {
            return true
        }
        return false
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
    }

}
