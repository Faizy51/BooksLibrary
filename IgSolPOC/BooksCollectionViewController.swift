//
//  BooksCollectionViewController.swift
//  IgSolPOC
//
//  Created by Faizyy on 24/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookCell"

class BooksCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate {
    
    let service = Services()
    var category: String!
    var bookList: [Book] = []
    var searchedBookList: [Book] = []
    var resultSearchController = UISearchController()
    let controller = UISearchController(searchResultsController: nil)
    var navBar: UINavigationBar = UINavigationBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Implement Search Controller
        self.resultSearchController = ({
            
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .minimal
            controller.searchBar.delegate = self
            navigationItem.searchController = controller
            
            return controller
        })()
        
        controller.searchBar.showsCancelButton = false
        controller.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        customiseSearchBar()
        downloadBooksData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
        
    }
        
    func customiseSearchBar() {
        
        let searchBarTextField = controller.searchBar.searchTextField
        searchBarTextField.textColor = UIColor.black
        searchBarTextField.font = UIFont(name: "Montserrat-Regular", size: 14)
        searchBarTextField.layer.cornerRadius = 4
        searchBarTextField.layer.borderWidth = 1
        searchBarTextField.layer.borderColor = UIColor.white.cgColor
        
        UISearchBar.appearance().setImage(UIImage(named: "Cancel"), for: .clear, state: .highlighted)
            
        searchBarTextField.leftView = UIImageView(image: UIImage(named: "Search"))

    }
    
    func downloadBooksData() {
        if let categoryFromString = Category.init(rawValue: self.category) {
            self.service.downloadBooks(for: categoryFromString) { (data, error) in
                if let _ = error {
                    // present error alert
                    let alert = UIAlertController(title: "Failed to fetch data", message: error?.localizedDescription, preferredStyle: .alert)
                    let button = UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        self.downloadBooksData()
                    })
                    alert.addAction(button)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    //Populate the datasource with books.
                    self.bookList = data.results
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        else {
            assertionFailure("Cannot create category from string: \(String(describing: self.category))")
        }
    }

    
    // MARK: - Search delegates
    func updateSearchResults(for searchController: UISearchController) {
        
        service.downloadBooks(forSearchText: controller.searchBar.text!) { (data, error) in
            if let _ = error {
                print("Error in search service.")
            }
            else {
                //Populate the datasource with books.
                self.searchedBookList = data.results
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resultSearchController.isActive = false
        self.collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let searchBarTextField = controller.searchBar.searchTextField
        searchBarTextField.layer.borderColor = UIColor(red: 0.37, green: 0.34, blue: 0.91, alpha: 1.00).cgColor

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let searchBarTextField = controller.searchBar.searchTextField
        searchBarTextField.layer.borderColor = UIColor.white.cgColor

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if resultSearchController.isActive && self.searchedBookList.count > 0 {
            return self.searchedBookList.count
        }
        else {
            return self.bookList.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? BookCell
        
        let listOfBooks = (controller.isActive && self.searchedBookList.count > 0 ) ? self.searchedBookList : self.bookList
        
        cell?.book = listOfBooks[indexPath.row]
    
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let listOfBooks = (controller.isActive && self.searchedBookList.count > 0 ) ? self.searchedBookList : self.bookList
        
        let cell = collectionView.cellForItem(at: indexPath) as! BookCell
        
        // Animate selection
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 6, options: [], animations: {
            cell.contentView.transform = CGAffineTransform.init(translationX: 0, y: 20)
        }, completion: { (finished) in
           cell.contentView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        })
        
        /* Select appropriate book format.
            1. HTML
            2. PDF
            3. TXT
         */
        let bookFormats = listOfBooks[indexPath.row].formats
        var format: String? = nil
        
        if let html = bookFormats["text/html; charset=utf-8"], !html.hasSuffix(".zip") {
            format = html
        }
        else if let html = bookFormats["text/html; charset=iso-8859-1"], !html.hasSuffix(".zip") {
            format = html
        }
        else if let pdf = bookFormats["application/pdf"], !pdf.hasSuffix(".zip") {
            format = pdf
        }
        else if let txt = bookFormats["text/plain; charset=utf-8"], !txt.hasSuffix(".zip") {
            format = txt
        }
        else if let txt = bookFormats["text/plain; charset=iso-8859-1"], !txt.hasSuffix(".zip") {
            format = txt
        }
        else if let txt = bookFormats["text/plain"], !txt.hasSuffix(".zip") {
            format = txt
        }
        
        if let formatToOpen = format, let urlToOpen = URL(string: formatToOpen) {
            if UIApplication.shared.canOpenURL(urlToOpen) {
                UIApplication.shared.open(urlToOpen, options: [ : ], completionHandler: nil)
            }
        }
        else {
            let alert = UIAlertController(title: "No viewable version available", message: "", preferredStyle: .alert)
            let button = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(button)
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 114, height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20);
    }

}

// Cache to store the downloaded image.
let imageCache = NSCache<NSString, UIImage>()

// Download url image
extension UIImageView {
    
    public func imageFromURL(urlString: String) {
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
                activityIndicator.removeFromSuperview()
                imageCache.setObject(imageToCache!, forKey: NSString(string: urlString))

                self.image = imageToCache
            })
        }).resume()
    }
}


extension UITextField {
    func applyCustomClearButton() {
        clearButtonMode = .never
        rightViewMode = .whileEditing

        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        clearButton.setImage(UIImage(named: "Cancel")!, for: .normal)
//        clearButton.addTarget(self, action: "clearClicked:", forControlEvents: .TouchUpInside)

        rightView = clearButton
    }

    func clearClicked(sender:UIButton) {
        text = ""
    }
}
