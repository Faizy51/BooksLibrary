//
//  Services.swift
//  IgSolPOC
//
//  Created by Faizyy on 23/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import Foundation

enum Category: String {
    case Fiction
    case Drama
    case Humour
    case Politics
    case Philosophy
    case History
    case Adventure
}

struct ServiceType {
    static let bookListBaseUrl = "http://skunkworks.ignitesol.com:8000/books/?mime_type=image%2Fjpeg"
    
    static func urlForCategory(_ category: Category) -> URL? {
        return URL(string: "\(self.bookListBaseUrl)&topic=\(category.rawValue)")
    }
    
    static func urlForSearch(_ text: String) -> URL? {
        var string = "\(self.bookListBaseUrl)&search="
        if let encodedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            string += encodedString
        }
        
        return URL(string: string)
    }
}

class Services {
    
    let session = URLSession.shared
    
    func downloadBooks(for category: Category, with callback: ((DataModel, Error?) -> ())?) {
        if let url = ServiceType.urlForCategory(category) {
            self.downloadBooks(for: url, with: callback)
        }
    }
    
    func downloadBooks(forSearchText text: String, with callback: ((DataModel, Error?) -> ())?) {
        if let searchUrl = ServiceType.urlForSearch(text), text.count > 0 {
            self.downloadBooks(for: searchUrl, with: callback)
        }
    }
    
    func downloadBooks(forNextPage urlString: String, with callback: ((DataModel, Error?) -> ())?) {
        if let nextPageUrl = URL(string: urlString) {
            self.downloadBooks(for: nextPageUrl, with: callback)
        }
    }
    
    private func downloadBooks(for url: URL, with callback: ((DataModel, Error?) -> ())?) {
        self.session.dataTask(with: url) { (data, response, error) in
            if let responseError = error {
                print("error ",responseError)
            }
            else if let recievedData = data {
                // Parse into model
                do {
                    let bookData = try JSONDecoder().decode(DataModel.self, from: recievedData)
                    callback?(bookData, error)
                }
                catch(let exception) {
                    print("error ",exception)
                }
                
            }
        }.resume()
    }
    
}

