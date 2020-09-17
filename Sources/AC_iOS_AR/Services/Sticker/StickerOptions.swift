//
//  StickerOptions.swift
//  myPlace
//
//  Created by Mac on 21/02/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import SwiftyJSON

public class StickerOptions {
    
    static let sharedInstance = StickerOptions()
    
    public static let firstChosenOptions: Int = 5
    public enum name {
        case Rating
        case PriceCategory
        case Address
        case FeedbackAmount
        case Site
        case UrlTA
        case Kitchen
        case PhoneNumber
        case LastReview
        case Title
        case StickerID
    }
    
    public enum IconOption: String {
        case Earth = "icon_earth"
        case Location = "icon_location"
        case Phone = "icon_phone"
    }
    
    public enum jsonName: String, CaseIterable {
        case Rating = "Rating"
        case PriceCategory = "Price category"
        case Address = "Address"
        case FeedbackAmount = "Feedback amount"
        case Site = "Site"
        case UrlTA = "url_ta"
        case Path = "path"
        case Kitchen = "Kitchen"
        case PhoneNumber = "Phone number"
        case LastReview = "LastReview"
        case StickerText = "sticker_text"
        case StickerID = "sticker_id"
        case StickerType = "sticker_type"
        case StickerDetailedType = "sticker_detailed_type"
    }
    private enum ru: String, CaseIterable {
        case Rating = "Рейтинг"
        case PriceCategory = "Ценовая категория"
        case Address = "Адрес"
        case FeedbackAmount = "Количество отзывов"
        case Site = "Сайт"
        case UrlTA = "Сайт TripAdvisor"
        case Kitchen = "Кухня"
        case PhoneNumber = "Номер телефона"
        case LastReview = "Последний отзыв"
        case Title = "Наименование"
        case Path = "Путь"
        case StickerID = "Стикер ИН"
        case StickerType = "Тип стикера"
        case StickerDetailedType = "Подробный тип стикера"
        
    }
    private enum en: String, CaseIterable {
        case Rating = "Rating"
        case PriceCategory = "Price category"
        case Address = "Address"
        case FeedbackAmount = "Feedback amount"
        case Site = "WebSite"
        case UrlTA = "Site TripAdvisor"
        case Kitchen = "Kitchen"
        case PhoneNumber = "Phone number"
        case LastReview = "Last review"
        case Title = "Title"
        case Path = "Path"
        case StickerID = "Sticker ID"
        case StickerType = "Sticker Type"
        case StickerDetailedType = "Sticker Detailed Type"
    }
    public static var allOptionsKeys: [String] = {
        print(StickerOptions.ru.allCases)
        var optionsKeys: [String] = []
        switch Languages.currentLanguage {
        case .ru:
            for optionCase in ru.allCases { if (optionCase != .Title) {optionsKeys.append(optionCase.rawValue)} }
        case .en:
            for optionCase in en.allCases { if (optionCase != .Title) {optionsKeys.append(optionCase.rawValue)} }
        }
        return optionsKeys
    }()
    
    public static var title: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Title.rawValue
        case .en:
            return en.Title.rawValue
        }
    }()
    
    public static var rating: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Rating.rawValue
        case .en:
            return en.Rating.rawValue
        }
    }()
    
    public static var priceCategory: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.PriceCategory.rawValue
        case .en:
            return en.PriceCategory.rawValue
        }
    }()
    
    public static var address: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Address.rawValue
        case .en:
            return en.Address.rawValue
        }
    }()
    
    public static var feedbackAmount: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.FeedbackAmount.rawValue
        case .en:
            return en.FeedbackAmount.rawValue
        }
    }()
    
    public static var site: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Site.rawValue
        case .en:
            return en.Site.rawValue
        }
    }()
    
    public static var urlTA: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.UrlTA.rawValue
        case .en:
            return en.UrlTA.rawValue
        }
    }()
    
    public static var kitchen: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Kitchen.rawValue
        case .en:
            return en.Kitchen.rawValue
        }
    }()
    
    public static var phoneNumber: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.PhoneNumber.rawValue
        case .en:
            return en.PhoneNumber.rawValue
        }
    }()
    
    public static var lastReview: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.LastReview.rawValue
        case .en:
            return en.LastReview.rawValue
        }
    }()
    
    public static var path: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.Path.rawValue
        case .en:
            return en.Path.rawValue
        }
    }()
    
    public static var stickerID: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.StickerID.rawValue
        case .en:
            return en.StickerID.rawValue
        }
    }()
    
    public static var stickerType: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.StickerType.rawValue
        case .en:
            return en.StickerType.rawValue
        }
    }()
    
    public static var stickerDetailedType: String = {
        switch Languages.currentLanguage {
        case .ru:
            return ru.StickerDetailedType.rawValue
        case .en:
            return en.StickerDetailedType.rawValue
        }
    }()

    
    public func parse(subJson: JSON) -> [String:String] {
        let rating: String? = subJson["sticker"][StickerOptions.jsonName.Rating.rawValue].string
        let priceCategory: String? = subJson["sticker"][StickerOptions.jsonName.PriceCategory.rawValue].string
        let kitchen: String? = subJson["sticker"][StickerOptions.jsonName.Kitchen.rawValue].string
        let webSiteString: String? = subJson["sticker"][StickerOptions.jsonName.Site.rawValue].string
        let phoneNumber: String? = subJson["sticker"][StickerOptions.jsonName.PhoneNumber.rawValue].string
        let address: String? = subJson["sticker"][StickerOptions.jsonName.Address.rawValue].string
        let feedbackAmount: String? = subJson["sticker"][StickerOptions.jsonName.FeedbackAmount.rawValue].string
        let lastReview: String? = subJson["sticker"][StickerOptions.jsonName.LastReview.rawValue].string
        var stickerText: String? = "Sticker has no text"
        if let text = subJson["sticker"][StickerOptions.jsonName.StickerText.rawValue].string, text.count > 0 {
            stickerText = text
        } else if let number = subJson["sticker"][StickerOptions.jsonName.StickerText.rawValue].int {
            stickerText = "\(number)"
        }
        let pathString: String? = subJson["sticker"][StickerOptions.jsonName.Path.rawValue].string
        let urlTAString: String? = subJson["sticker"][StickerOptions.jsonName.UrlTA.rawValue].string
        let stickerIDString: String? = subJson["sticker"][StickerOptions.jsonName.StickerID.rawValue].string
        let stickerTypeString: String? = subJson["sticker"][StickerOptions.jsonName.StickerType.rawValue].string
        let stickerDetailTypeString: String? = subJson["sticker"][StickerOptions.jsonName.StickerDetailedType.rawValue].string
        

        //["Рейтинг", "Ценовая категория", "Кухня", "Сайт", "Номер телефона", "Адрес", "Количество отзывов", "Крайний отзыв"]
        var stickerOptions: [String: String] = [:]
        if let r = rating, r.count > 0 { stickerOptions[StickerOptions.rating] = r }
        if let pC = priceCategory, pC.count > 0 { stickerOptions[StickerOptions.priceCategory] = pC }
        if let k = kitchen, k.count > 0 { stickerOptions[StickerOptions.kitchen] = k }
        if let wS = webSiteString, wS.count > 0 { stickerOptions[StickerOptions.site] = fixHttp(wS) }
        if let pN = phoneNumber, pN.count > 0 { stickerOptions[StickerOptions.phoneNumber] = pN }
        if let a = address, a.count > 0 { stickerOptions[StickerOptions.address] = a }
        if let fA = feedbackAmount, fA.count > 0 { stickerOptions[StickerOptions.feedbackAmount] = fA }
        if let lR = lastReview, lR.count > 0 { stickerOptions[StickerOptions.lastReview] = lR }
        if let sT = stickerText, sT.count > 0 { stickerOptions[StickerOptions.title] = sT }
        if let pthS = pathString, pthS.count > 0 { stickerOptions[StickerOptions.path] = fixHttp(pthS) }
        if let uTA = urlTAString, uTA.count > 0 { stickerOptions[StickerOptions.urlTA] = fixHttp(uTA) }
        if let sID = stickerIDString, sID.count > 0 { stickerOptions[StickerOptions.stickerID] = sID }
        if let sTp = stickerTypeString, sTp.count > 0 { stickerOptions[StickerOptions.stickerType] = sTp }
        if let sDTp = stickerDetailTypeString, sDTp.count > 0 { stickerOptions[StickerOptions.stickerDetailedType] = sDTp }

        return stickerOptions
    }
    
    public func parse(options: [String: String]) -> [String: String] {
        let rating = options[StickerOptions.jsonName.Rating.rawValue]
        let priceCategory = options[StickerOptions.jsonName.PriceCategory.rawValue]
        let kitchen = options[StickerOptions.jsonName.Kitchen.rawValue]
        let webSiteString = options[StickerOptions.jsonName.Site.rawValue]
        let phoneNumber = options[StickerOptions.jsonName.PhoneNumber.rawValue]
        let address = options[StickerOptions.jsonName.Address.rawValue]
        let feedbackAmount = options[StickerOptions.jsonName.FeedbackAmount.rawValue]
        let lastReview = options[StickerOptions.jsonName.LastReview.rawValue]
        
        var stickerText = options[StickerOptions.jsonName.StickerText.rawValue]
        if stickerText?.isEmpty ?? true {
            stickerText = "Sticker has no text"
        }
        
        let pathString = options[StickerOptions.jsonName.Path.rawValue]
        let urlTAString = options[StickerOptions.jsonName.UrlTA.rawValue]
        let stickerIDString = options[StickerOptions.jsonName.StickerID.rawValue]
        let stickerTypeString = options[StickerOptions.jsonName.StickerType.rawValue]
        let stickerDetailTypeString = options[StickerOptions.jsonName.StickerDetailedType.rawValue]

        //["Рейтинг", "Ценовая категория", "Кухня", "Сайт", "Номер телефона", "Адрес", "Количество отзывов", "Крайний отзыв"]
        var stickerOptions: [String: String] = [:]
        if let r = rating, r.count > 0 { stickerOptions[StickerOptions.rating] = r }
        if let pC = priceCategory, pC.count > 0 { stickerOptions[StickerOptions.priceCategory] = pC }
        if let k = kitchen, k.count > 0 { stickerOptions[StickerOptions.kitchen] = k }
        if let wS = webSiteString, wS.count > 0 { stickerOptions[StickerOptions.site] = fixHttp(wS) }
        if let pN = phoneNumber, pN.count > 0 { stickerOptions[StickerOptions.phoneNumber] = pN }
        if let a = address, a.count > 0 { stickerOptions[StickerOptions.address] = a }
        if let fA = feedbackAmount, fA.count > 0 { stickerOptions[StickerOptions.feedbackAmount] = fA }
        if let lR = lastReview, lR.count > 0 { stickerOptions[StickerOptions.lastReview] = lR }
        if let sT = stickerText, sT.count > 0 { stickerOptions[StickerOptions.title] = sT }
        if let pthS = pathString, pthS.count > 0 { stickerOptions[StickerOptions.path] = fixHttp(pthS) }
        if let uTA = urlTAString, uTA.count > 0 { stickerOptions[StickerOptions.urlTA] = fixHttp(uTA) }
        if let sID = stickerIDString, sID.count > 0 { stickerOptions[StickerOptions.stickerID] = sID }
        if let sTp = stickerTypeString, sTp.count > 0 { stickerOptions[StickerOptions.stickerType] = sTp }
        if let sDTp = stickerDetailTypeString, sDTp.count > 0 { stickerOptions[StickerOptions.stickerDetailedType] = sDTp }

        return stickerOptions
    }
    
    func fixHttp(_ urlS: String) -> String {
        let httpSign = "://"
        guard urlS.index(of: httpSign) == nil else { return urlS }
        let resUrlS = "https" + httpSign + urlS
        return resUrlS
    }
    
}
