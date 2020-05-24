//
//  DataModel.swift
//  IgSolPOC
//
//  Created by Faizyy on 23/05/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import Foundation

struct Author: Codable {
    var name: String
    var birth_year: Int?
    var death_year: Int?
}

struct Book: Codable {
    var id: Int
    var title: String
    var authors: [Author]
    var subjects: [String]
    var bookshelves: [String]
    var languages: [String]
    var media_type: String
    var formats: [String: String]
    var download_count: Int
}

struct DataModel: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Book]
}
