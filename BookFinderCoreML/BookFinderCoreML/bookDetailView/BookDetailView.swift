//
//  BookDetailView.swift
//  BookFinderCoreMl
//
//  Created by vd-rahim on 5/6/18.
//  Copyright © 2018 venturedive. All rights reserved.
//

import UIKit
import SDWebImage

class BookDetailView: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var bookDetails:[BookDetailModel] = []
    var delegate: BookDetailViewDelegate?
    
    override func viewDidLoad() {
        setupNib()
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(BookDetailView.handleSingleTap(_:)))
        self.view.addGestureRecognizer(singleFingerTap)
    }
    
    func setupNib(){
        collectionView.register(UINib(nibName: "BookDetailViewCell", bundle: nil), forCellWithReuseIdentifier: "bookDetail")
    }
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.delegate?.dismissingView()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

extension BookDetailView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookDetail", for: indexPath) as! BookDetailViewCollectionViewCell
        
        
        let url = bookDetails[indexPath.row].imgThumb ?? bookDetails[indexPath.row].imgSmallThumb
        ImageLoader.sharedLoader.imageForUrl(urlString: url!, completionHandler:{(image: UIImage?, url: String) in
            DispatchQueue.main.async {
                cell.bookImage.image = image
            }
            
        })
        
        cell.bookName.text = bookDetails[indexPath.row].bookName
        cell.authorNames.text = (bookDetails[indexPath.row].author! as NSArray).componentsJoined(by: ", ")
        cell.category.text = (bookDetails[indexPath.row].category! as NSArray).componentsJoined(by: ", ")
        
        let myAttribute = [ NSAttributedStringKey.font: UIFont(name: "AppleSDGothicNeo-Bold", size: 16.0)! ]
        let myString = NSMutableAttributedString(string: "Description: ", attributes: myAttribute )
        
        let desc = bookDetails[indexPath.row].description
        let attrString = NSAttributedString(string: desc ?? "")
        myString.append(attrString)
        let myRange = NSRange(location: 13, length: desc?.count ?? 0)
        myString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "AppleSDGothicNeo-Medium", size: 16.0)! , range: myRange)
        
        let eBook = bookDetails[indexPath.row].pdfLink
        let buy = bookDetails[indexPath.row].buyLink
        let preview = bookDetails[indexPath.row].previewLink
        
        cell.eBookButton.isEnabled = false
        cell.buyButton.isEnabled = false
        cell.previewButton.isEnabled = false
        
        cell.eBookButton.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        cell.buyButton.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        cell.previewButton.backgroundColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        
        cell.bookDesc = bookDetails[indexPath.row]
        
        if (eBook != nil) && (eBook?.count)! > 0{
            cell.eBookButton.isEnabled = true
            cell.eBookButton.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.7803921569, blue: 0.5843137255, alpha: 1)
        }
        if (buy != nil) && (buy?.count)! > 0{
            cell.buyButton.isEnabled = true
            cell.buyButton.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.7803921569, blue: 0.5843137255, alpha: 1)
        }
        if (preview != nil) && (preview?.count)! > 0{
            cell.previewButton.isEnabled = true
            cell.previewButton.backgroundColor = #colorLiteral(red: 0.3450980392, green: 0.7803921569, blue: 0.5843137255, alpha: 1)
        }
        
        cell.bookDescription.attributedText = myString
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height-100)
    }
}

protocol BookDetailViewDelegate {
    func dismissingView()
}
