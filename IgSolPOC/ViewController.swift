//
//  ViewController.swift
//  IgSolPOC
//
//  Created by Faizyy on 23/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let categories = [ "Fiction", "Drama", "Humour", "Politics", "Philosophy", "History", "Adventure" ]
    @IBOutlet weak var categoryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 22)!], for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? CategoryCell
        guard let selectedCell = cell, let selectedIndex = categoryTable.indexPath(for: selectedCell) else { return }
        navigationItem.backBarButtonItem?.title = categories[selectedIndex.row]
        
        if let destVC = segue.destination as? BooksCollectionViewController {
            destVC.category = categories[selectedIndex.row]
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        cell.imageName = categories[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
        cell.animateSelection()
    }
}
