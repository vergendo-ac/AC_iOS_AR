//
//  YaFileManager.swift
//  Developer
//
//  Created by Mac on 16.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation

class YaFileManager: AppDirectoryNames {
    
    static let sharedInstance = YaFileManager()
    
    private let syncRoot = NSRecursiveLock()
    
    init() {

    }

    func createFolder(rootDirectory: AppDirectories, name: String, completion: ((URL?, Error?) -> Void)? = nil) {
        self.createDirectory(with: name, at: rootDirectory) { completion?($0, $1) }
    }
    
    func write(images: [ImageModels.Image], to path: URL, completion: ((Int) -> Void)? = nil) {
        var n: Int = 0
        for image in images {
            if writeFile(with:image.filename, data: image.data, to: path) {
                n += 1
            }
        }
        completion?(n)
    }
    
    func writeFile(with name: String?, data: Data?, to path: URL) -> Bool {
        syncRoot.lock()
        
        guard let fileData = data, let fileName = name else {
            syncRoot.unlock()
            return false
        }
        
        do {
            let fileUrl = path.appendingPathComponent(fileName, isDirectory: false)
            try fileData.write(to: fileUrl)
            syncRoot.unlock()
            return true
        }
        catch {
            print("ImageSeries: Couldn't write image to series. " + error.localizedDescription)
            syncRoot.unlock()
            return false
        }
        
    }
    
}
