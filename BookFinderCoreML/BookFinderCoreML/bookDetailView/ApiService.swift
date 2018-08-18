//
//  ApiService.swift
//  BookFinderCoreMl
//
//  Created by vd-rahim on 5/6/18.
//  Copyright © 2018 venturedive. All rights reserved.
//

import Foundation
import Alamofire
class ApiService{
    
    static func fetchBooks(with bookName:String, completion: @escaping ([BookDetailModel]?) -> Void) {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(bookName.replacingOccurrences(of: " ", with: "+"))&key=AIzaSyAcBjI4Br1WkcqCufNJRIcs99UJNC_njwA") else {
            completion(nil)
            return
        }
        Alamofire.request(url,
                          method: .get,
                          parameters: nil)
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching remote rooms: \(String(describing: response.result.error))")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: Any],
                let row = value["items"] as? [[String:Any]] else {
                        print("Malformed data received from fetchAllRooms service")
                        completion(nil)
                        return
                }
                
                let books = row.flatMap { bookDict in return BookDetailModel(jsonData: bookDict) }
                completion(books)
        }
    }
    
}
