//
//  TitleView.swift
//  UICollectionViewCompositionalLayout
//
//  Created by Alex Gurin on 8/28/19.
//

import UIKit

class TitleView: UICollectionReusableView {
    
    static let reuseIdentifier = "TitleView"
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var btnAddAction: (() -> Void)?
    
    // MARK: - Cell Configuration
    func configureCell(at indexPath: IndexPath) {
        
        self.lblTitle.text = indexPath.section == 0 ? "Local Images" : "Remote Images"
        self.btnAdd.isHidden = indexPath.section != 0
    }
    
    @IBAction func btnAddPressed(_ sender: UIButton) {
        self.btnAddAction?()
    }
}
