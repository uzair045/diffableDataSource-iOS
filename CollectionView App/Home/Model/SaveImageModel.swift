//
//  SaveImageModel.swift
//  CollectionView App
//
//  Created by Uzair on 19/04/2022.
//

import Foundation
import RealmSwift

class SaveImageModel: Object {
    
    @objc dynamic var imageData: Data?
    @objc dynamic var addedDate: Date?
    
    init(imageData: Data) {
        self.imageData = imageData
        self.addedDate = Date()
    }
    
    required init() {
        
    }
}
