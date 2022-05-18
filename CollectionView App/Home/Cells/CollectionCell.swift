//
//  CollectionCell.swift
//  CollectionView App
//
//  Created by Uzair on 15/04/2022.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CollectionCell"
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    func configureCell(image: UIImage) {
        self.imageView.image = image
    }
    
    func configureCell(with url: String) {
        guard let url = URL(string: url) else {
            print("Unable to load image")
            return
        }
        
        loadImageAt(url: url) { [unowned self] image in
            self.imageView.image = image
        }
    }
}
