//
//  File.swift
//  
//
//  Created by Mac on 19.11.2020.
//

import Foundation

enum StickerFilter: CaseIterable {
    case info
    case ddd
    case video
    case image
    case graffiti
    
    var title: String {
        switch self {
        case .info: return "Info"
        case .ddd: return "3d"
        case .video: return "Video"
        case .image: return "Image"
        case .graffiti: return "Graffiti"
        }
    }
    
    static var titles: [String] {
        StickerFilter.allCases.map { $0.title }
    }
    
    static var count: Int {
        StickerFilter.allCases.count
    }
    
    static func titleByID(id: Int) -> String {
        StickerFilter.titles[id]
    }
    
    var id: Int? {
        StickerFilter.titles.firstIndex(of: self.title)
    }
}
