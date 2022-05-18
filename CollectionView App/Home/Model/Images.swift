//
//  Images.swift
//  CollectionView App
//
//  Created by Uzair on 18/04/2022.
//

import Foundation

struct Images: Codable, Hashable {
    
    var albumId: Int?
    var id: Int?
    var title: String?
    var url: String?
    var thumbnailUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case albumId
        case id
        case title
        case url
        case thumbnailUrl
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.albumId = try values.decodeIfPresent(Int.self, forKey: .albumId)
        self.id = try values.decodeIfPresent(Int.self, forKey: .id)
        self.title = try values.decodeIfPresent(String.self, forKey: .title)
        self.url = try values.decodeIfPresent(String.self, forKey: .url)
        self.thumbnailUrl = try values.decodeIfPresent(String.self, forKey: .thumbnailUrl)
    }
}
