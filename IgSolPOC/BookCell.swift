//
//  BookCell.swift
//  IgSolPOC
//
//  Created by Faizyy on 24/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    var book: Book? {
        didSet {
            if let imageUrl = self.book?.formats["image/jpeg"] {
                self.bookImage?.imageFromURL(urlString: imageUrl)
            }
            self.bookName?.text = self.book?.title.uppercased()
            if (self.book?.authors.count)! > 0 {
                self.authorName?.text = self.reOrganiseName(name: (self.book?.authors[0].name)!)
            }
        }
    }

    // Re arrange the name into proper fnam-lname format.
    func reOrganiseName(name: String) -> String {
        var finalName = ""
        
        let names = name.components(separatedBy: ",")
        if names.count > 1 {
            finalName = names[1]+" "+names[0]
        }
        else {
            finalName = name
        }
        
        return finalName.trimmingCharacters(in: .whitespaces)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.bookImage.layer.masksToBounds = true
//        self.bookImage.layer.cornerRadius = 10
    }

}
