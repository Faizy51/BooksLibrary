//
//  Services.swift
//  IgSolPOC
//
//  Created by Faizyy on 23/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import Foundation

enum Category: String {
    case fiction
    case drama
    case humor
    case politics
    case philosophy
    case history
    case adventure
}

struct ServiceType {
    static let bookListBaseUrl = "https://gutendex.com/books"
    
    static func urlForCategory(_ category: Category) -> URL? {
        return URL(string: "\(self.bookListBaseUrl)/?topic=\(category.rawValue)")
    }
}

class Services {
    
    func downloadBooks(for category: Category) {
        let session = URLSession.shared
        if let url = ServiceType.urlForCategory(category) {
            session.dataTask(with: url) { (data, response, error) in
                if let responseError = error {
                    print("error ",responseError)
                }
                else if let recievedData = data {
                    // Parse into model
                    do {
                        let bookData = try JSONDecoder().decode(DataModel.self, from: recievedData)
                        print(bookData.count)
                    }
                    catch(let exception) {
                        print("error ",exception)
                    }
                    
                }
            }.resume()
        }
    }
    
}

