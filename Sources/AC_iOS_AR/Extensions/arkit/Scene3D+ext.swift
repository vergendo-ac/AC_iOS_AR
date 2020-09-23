//
//  Scene3D+ext.swift
//  YaPlace
//
//  Created by Andrei Okoneshnikov on 06.08.2020.
//  Copyright © 2020 SKZ. All rights reserved.
//

import Foundation
import ARKit

extension Scene3D {
    
    func getStickerNodes(by id: Int) -> [SCNNode]? {
        if let result = self.arfNodes.first(where: {$0.key.hashValue == id}) {
            return result.value
        }
        return nil
    }
    
    func getStickerTypeById(_ id: String) -> CategoryPin? {
        if let stickerData = self.stickersData.first(where: { $0.options[StickerOptions.stickerID] == id }), let sid = stickerData.options[StickerOptions.stickerType] {
            return CategoryPin.category(for: sid)
        }
        return nil
    }
    
    func getStickerOptions(by id: String) -> [String: String]? {
        if let stickerData = self.stickersData.first(where: { $0.options[StickerOptions.stickerID] == id }) {
            return stickerData.options
        }
        return nil
    }
}
