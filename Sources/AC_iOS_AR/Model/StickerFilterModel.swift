//
//  File.swift
//  
//
//  Created by Mac on 19.11.2020.
//

import Foundation
import UIKit

enum InfoStickerCategory: String, CaseIterable {
    case restaurant
    case shop
    case other
    case place
    
    static var categories: [InfoStickerCategory] {
        InfoStickerCategory.allCases
    }
    
    var title: String {
        self.rawValue.capitalizingFirstLetter()
    }

    static var titles: [String] {
        InfoStickerCategory.categories.map({ $0.title })
    }
    
    var image: UIImage {
        switch self {
        case .restaurant: return UIImage(named: "restaurant")!
        case .shop: return UIImage(named: "shop")!
        case .other: return UIImage(named: "other")!
        case .place: return UIImage(named: "place")!
        }
    }
    
    var color: UIColor {
        switch self {
        case .restaurant: return UIColor(hex: "689F38")
        case .shop: return UIColor(hex: "2196F3")
        case .other: return UIColor(hex: "E64A19")
        case .place: return UIColor(hex: "FFC107")
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .restaurant: return UIColor(hex: "558B2F")
        case .shop: return UIColor(hex: "1565C0")
        case .other: return UIColor(hex: "D84315")
        case .place: return UIColor(hex: "FF8F00")
        }
    }
    
    var rgbar: (CGFloat, CGFloat, CGFloat, CGFloat, Bool) {
        return color.rgbaTuple
    }
    
    static func category(for name: String?) -> InfoStickerCategory {
        guard let name = name else { return .other }
        switch name {
        case "restaurant":
            return .restaurant
        case "shop":
            return .shop
        case "other":
            return .other
        case "place":
            return .place
        default:
            return .other
        }
    }
    
    func isSame(type: InfoStickerCategory?) -> Bool {
        guard let type = type else { return true }
        return self == type
    }
}

enum StickerFilter {
    case info(categories: [InfoStickerCategory])
    case ddd
    case video
    case image
    case graffiti
    
    var title: String {
        switch self {
        case .info(_): return "Info"
        case .ddd: return "3d"
        case .video: return "Video"
        case .image: return "Image"
        case .graffiti: return "Graffiti"
        }
    }
    
    static var filters: [StickerFilter] {
        var res: [StickerFilter] = []
        res.append(StickerFilter.info(categories: InfoStickerCategory.categories))
        res.append(StickerFilter.ddd)
        res.append(StickerFilter.video)
        res.append(StickerFilter.image)
        res.append(StickerFilter.graffiti)
        return res
    }
    
    static var allTitles: [String] {
        StickerFilter.titles + InfoStickerCategory.titles
    }

    static var titles: [String] {
        StickerFilter.filters.map { $0.title }
    }
    
    static var count: Int {
        StickerFilter.filters.count
    }
    
    static func titleByID(id: Int) -> String {
        StickerFilter.titles[id]
    }
    
    var id: Int? {
        StickerFilter.titles.firstIndex(of: self.title)
    }
}
