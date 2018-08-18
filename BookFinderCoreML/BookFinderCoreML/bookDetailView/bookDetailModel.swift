//
//  bookDetailModel.swift
//  BookFinderCoreMl
//
//  Created by vd-rahim on 5/6/18.
//  Copyright © 2018 venturedive. All rights reserved.
//

import Foundation

class BookDetailModel {
    var bookName:String
    var author:[String]!
    var publisher:String!
    var publishedDate: String!
    var description:String!
    var imgSmallThumb:String!
    var imgThumb:String!
    var previewLink: String!
    var webReaderLink:String!
    var pdfLink:String!
    var buyLink:String!
    var category:[String]!
    
    init(jsonData:[String:Any]) {
        
        let bookDesc = jsonData["volumeInfo"] as! [String:Any]
        self.bookName = "\(bookDesc["title"] as? String ?? "") \(bookDesc["subtitle"] as? String ?? "")"
        self.author = bookDesc["authors"] as? [String] ?? []
        self.publisher = bookDesc["publisher"] as? String ?? ""
        self.publishedDate = bookDesc["publishedDate"] as? String ?? ""
        self.description = bookDesc["description"] as? String ?? ""
        self.category = bookDesc["categories"] as? [String] ?? []
        
        let bookImg = bookDesc["imageLinks"] as! [String:String]
        self.imgSmallThumb = bookImg["smallThumbnail"] ?? ""
        self.imgThumb = bookImg["thumbnail"] ?? ""
        self.previewLink = bookDesc["previewLink"] as? String ?? ""
     
        let accessInfo = jsonData["accessInfo"] as! [String:Any]
        let pdf = accessInfo["pdf"] as! [String:Any]
        if pdf["isAvailable"] as! Bool{
            self.pdfLink = pdf["acsTokenLink"] as? String ?? ""
        }
        
        
    }
}
