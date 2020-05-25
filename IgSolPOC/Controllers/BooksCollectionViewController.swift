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
    var nextPage: String?
    var searchedBookList: [Book] = []
    var resultSearchController = UISearchController()
    let controller = UISearchController(searchResultsController: nil)
    var fetchingMore = false
    var paginationActivity = UIActivityIndicatorView(style: .large)
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        paginationActivity.hidesWhenStopped = true
        paginationActivity.color = UIColor(red: 0.37, green: 0.34, blue: 0.91, alpha: 1.00)
        
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
    
    // MARK: - Search delegates
    func updateSearchResults(for searchController: UISearchController) {
        
        service.downloadBooks(forSearchText: controller.searchBar.text!) { (data, error) in
            if let _ = error {
                print("Error in search service.")
            }
            else {
                //Populate the datasource with books.
                self.searchedBookList = data.results
                self.nextPage = data.next
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
        self.animateCellSelection(for: cell)
        // Decide the format and open the browser. Display alert if no format is available.
        self.openUrlOnRequest(listOfBooks: listOfBooks, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 114, height: 215)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "myFooter", for: indexPath)
        
        view.addSubview(paginationActivity)
        paginationActivity.translatesAutoresizingMaskIntoConstraints = false
        paginationActivity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        paginationActivity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == self.bookList.count - 1 ) { //it's your last cell
          //Load more data & reload your collection view
           if !fetchingMore {
               beginBatchFetch()
           }
        }
    }
    
    // MARK: - Helpers
    
    private func animateCellSelection(for cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 6, options: [], animations: {
            cell.contentView.transform = CGAffineTransform.init(translationX: 0, y: 20)
        }, completion: { (finished) in
           cell.contentView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        })
    }
    
    private func openUrlOnRequest(listOfBooks: [Book], indexPath: IndexPath) {
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
    
    private func beginBatchFetch() {
        guard let nextPage = self.nextPage else { return }
        
        self.paginationActivity.startAnimating()
        self.fetchingMore = true
        
        service.downloadBooks(forNextPage: nextPage) { (data, error) in
            if let _ = error {
                // present error alert
                let alert = UIAlertController(title: "Failed to fetch data", message: error?.localizedDescription, preferredStyle: .alert)
                let button = UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                    self.beginBatchFetch()
                })
                alert.addAction(button)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                //Populate the datasource with books.
                self.bookList.append(contentsOf: data.results)
                self.nextPage = data.next
                self.fetchingMore = false
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.paginationActivity.stopAnimating()
                }
            }
        }
    }
    
    private func customiseSearchBar() {
        
        let searchBarTextField = controller.searchBar.searchTextField
        searchBarTextField.textColor = UIColor.black
        searchBarTextField.font = UIFont(name: "Montserrat-Regular", size: 14)
        searchBarTextField.layer.cornerRadius = 4
        searchBarTextField.layer.borderWidth = 1
        searchBarTextField.layer.borderColor = UIColor.white.cgColor
        
        UISearchBar.appearance().setImage(UIImage(named: "Cancel"), for: .clear, state: .highlighted)
            
        searchBarTextField.leftView = UIImageView(image: UIImage(named: "Search"))

    }
    
    private func downloadBooksData() {
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
                    self.nextPage = data.next
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

}

