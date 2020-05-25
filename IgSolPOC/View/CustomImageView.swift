//
//  CustomImageView.swift
//  IgSolPOC
//
//  Created by Faizyy on 25/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit

// Cache to store the downloaded image.
fileprivate let imageCache = NSCache<NSString, UIImage>()

// Download url image
class CustomImageView: UIImageView {
    
    private var imageUrlString: String?
    
    public func imageFromURL(urlString: String) {
        self.imageUrlString = urlString
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: NSString(string: urlString)) {
            self.image = imageFromCache
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    activityIndicator.removeFromSuperview()
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: NSString(string: urlString))
            })
        }).resume()
    }
}
