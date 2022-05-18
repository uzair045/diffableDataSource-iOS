//
//  NetworkManager.swift
//  CollectionView App
//
//  Created by Uzair on 18/04/2022.
//

import Foundation
import Combine



enum BaseURL {
    case production
    case staging
}

enum EndPoint {
    
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Class Properties
    var cancelables = Set<AnyCancellable>()
}

// MARK: - Make Request
extension NetworkManager {
    
    func makeCall<T>(at url: URL, method: String) -> AnyPublisher<T, Error> where T: Codable {
        
        return Future { promise in
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap({ data, _ in
                    try JSONDecoder().decode(T.self, from: data)
                })
                .sink { completion in
                    switch completion {
                        case .finished:
                            print("Task finished")
                        case let .failure(error):
                            promise(.failure(error))
                    }
                } receiveValue: { data in
                    promise(.success(data))
                }
                .store(in: &self.cancelables)
        }
        .eraseToAnyPublisher()
    }
}
