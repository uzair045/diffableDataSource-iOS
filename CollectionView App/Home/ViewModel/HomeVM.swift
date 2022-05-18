//
//  HomeVM.swift
//  CollectionView App
//
//  Created by Uzair on 18/04/2022.
//

import UIKit
import Combine
import RealmSwift

class HomeVM {
    
    // MARK: - Class Properties
    var images: [Images] = []
    var localImages: [UIImage] = []
    var gotImages = PassthroughSubject<Bool, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Instantiate RealM
    var realmDB: Realm!
    
    // MARK: - Initializer
    init() {
        self.realmDB = try! Realm()
        
        self.getImages()
    }
}

// MARK: - Fetch Images
extension HomeVM {
    
    func fetchImages() {
        
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos") else { return }
        NetworkManager.shared.makeCall(at: url)
            .sink { completion in
                switch completion {
                    case .finished:
                        print("Finished")
                    case let .failure(error):
                        print(error)
                }
            } receiveValue: { [unowned self] (data: [Images]) in
                self.images = data
                self.gotImages.send(true)
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - RealM images in local DB
extension HomeVM {
    func saveImage(_ image: UIImage) {
        guard let data = image.pngData() else {
            print("Unable to convert image into data")
            return
        }
        
        let model = SaveImageModel(imageData: data)
        
        DispatchQueue.main.async {
            try! self.realmDB.write {
                self.realmDB.add(model)
            }
        }
    }
    
    func getImages() {
        
        let images = self.realmDB.objects(SaveImageModel.self)
        let dataArray = images.map({$0.imageData})
        
        dataArray.forEach { [unowned self] imageData in
            if let data = imageData, let uiImage = UIImage(data: data) {
                self.localImages.append(uiImage)
            }
        }
    }
}
