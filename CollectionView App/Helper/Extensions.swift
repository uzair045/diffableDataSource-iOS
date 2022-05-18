//
//  Extensions.swift
//  CollectionView App
//
//  Created by Uzair on 18/04/2022.
//

import UIKit

func loadImageAt(url: URL, completion: @escaping (UIImage) -> Void) {
    DispatchQueue.global().async {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
}
