//
//  CategoryCell.swift
//  IgSolPOC
//
//  Created by Faizyy on 23/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    fileprivate let cPadding: CGFloat = 25
    
    let iconImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
    let categoryNameLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 400, height: 30))
    var imageName = String() {
        didSet {
            self.iconImageView.image = UIImage(named: self.imageName)
            self.categoryNameLabel.text = self.imageName.uppercased()
        }
    }
    
    // Genre Card
    var mainView: UIView {
        let view = UIView(frame: CGRect(x: cPadding, y: 12.5, width: self.frame.width-(cPadding*2), height: 50))
        view.backgroundColor = UIColor.white
        
        layer.masksToBounds = false
        layer.cornerRadius = 4
        layer.shadowColor = UIColor(red: 0.83, green: 0.82, blue: 0.93, alpha: 0.50).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 5)
        
        view.addSubview(self.iconImageView)
        self.categoryNameLabel.font = UIFont(name: "Montserrat-SemiBold", size: 20)
        view.addSubview(categoryNameLabel)
        
        return view
    }
    
    var customAccessoryView: UIView {
        let view = UIImageView(image: UIImage(named: "Next"))
        view.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Modifying accessoryView's frame.
        var adjustedFrame = self.accessoryView?.frame
        adjustedFrame?.origin.x -= 30.0
        self.accessoryView?.frame = adjustedFrame!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.addSubview(mainView)
        self.accessoryView = customAccessoryView
        
    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.animateSelection()
    }

    func animateSelection() {
         
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 6, options: [], animations: {
             self.contentView.transform = CGAffineTransform.init(translationX: 10, y: 0)
         }, completion: { (finished) in
            self.contentView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
         })
    }
    
}
