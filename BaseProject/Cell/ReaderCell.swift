//
//  TableCell.swift
//  BaseProject
//
//  Created by M Khairul Bashar on 9/28/17.
//  Copyright © 2017 Annanovas IT Ltd. All rights reserved.
//

import UIKit

class ReaderCell: UITableViewCell{
    
    @IBOutlet var txtView:UIView?
    
    @IBOutlet var image_bg:UIImageView?
    @IBOutlet var image_Path:UIImageView?
    @IBOutlet var lblCharacter:UILabel?
    @IBOutlet var lblText:UILabel?
    
    func setContent(_ info : NSDictionary){
        image_bg?.layer.cornerRadius = 5.0
        image_bg?.layer.masksToBounds = true
    }
    
    
    func getLabelsize(text:String) {
        let constraint = CGSize(width: (lblText?.frame.size.width)!, height: CGFloat.greatestFiniteMagnitude)
        var size: CGSize
        let context = NSStringDrawingContext()
        lblText?.text = text
        let boundingBox: CGSize? = lblText?.text?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: lblText?.font as Any], context: context).size
        
        size = CGSize(width: ceil((boundingBox?.width)!), height: ceil((boundingBox?.height)!))
        
        lblText?.frame = CGRect.init(x: (lblText?.frame.origin.x)!, y: (lblText?.frame.origin.y)!, width: (lblText?.frame.size.width)!, height: size.height)
        image_Path?.frame = CGRect.init(x: (image_Path?.frame.origin.x)!, y: (image_Path?.frame.origin.y)!, width: (image_Path?.frame.size.width)!, height: size.height + 16 )
        txtView?.frame = CGRect.init(x: (txtView?.frame.origin.x)!, y: (txtView?.frame.origin.y)!, width: (txtView?.frame.size.width)!, height: size.height + 16 )
        
        print("====\(size.height)")
        //print("****\(String(describing: lblPrice?.frame.origin.y))")
    }
}
