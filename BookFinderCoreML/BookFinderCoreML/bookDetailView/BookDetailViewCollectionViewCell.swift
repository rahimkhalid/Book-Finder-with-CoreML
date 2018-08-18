//
//  BookDetailViewCollectionViewCell.swift
//  BookFinderCoreMl
//
//  Created by vd-rahim on 5/6/18.
//  Copyright © 2018 Rahim. All rights reserved.
//

import UIKit

class BookDetailViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var authorNames: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var bookDescription: UITextView!
    @IBOutlet weak var eBookButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    var bookDesc:BookDetailModel!
    
    @IBAction func eBookButtonTapped(_ sender: UIButton) {
        if let url = URL(string: bookDesc.pdfLink) {
             UIApplication.shared.open(url)
            print("default browser was successfully opened")
        }
    }
    
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        if let url = URL(string: bookDesc.buyLink) {
             UIApplication.shared.open(url)
            print("default browser was successfully opened")
        }
    }
    
    @IBAction func previewButtonTapped(_ sender: UIButton) {
        if let url = URL(string: bookDesc.previewLink) {
             UIApplication.shared.open(url)
            print("default browser was successfully opened")
        }
    }
    
}
