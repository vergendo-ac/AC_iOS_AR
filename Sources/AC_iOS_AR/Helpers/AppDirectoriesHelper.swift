//
//  AppDirectoriesHelper.swift
//  MyPlaceLibIOS
//
//  Created by Mac on 16.01.2020.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation

enum AppDirectories : String {
    case Documents = "Documents"
    case Inbox = "Inbox"
    case Library = "Library"
    case Temp = "tmp"
}

protocol AppDirectoryNames {
    func documentsDirectoryURL() -> URL?
    
    func inboxDirectoryURL() -> URL
    
    func libraryDirectoryURL() -> URL?
    
    func tempDirectoryURL() -> URL
    
    func getURL(for directory: AppDirectories) -> URL?
    
    func buildFullPath(for name: String, inDirectory directory: AppDirectories, isDirectory: Bool) -> URL?
} // end protocol AppDirectoryNames

extension AppDirectoryNames {
    func documentsDirectoryURL() -> URL? {
//        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func inboxDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(AppDirectories.Inbox.rawValue) // "Inbox")
    }
    
    func libraryDirectoryURL() -> URL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first
    }
    
    func tempDirectoryURL() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    func getURL(for directory: AppDirectories) -> URL? {
        switch directory {
            case .Documents:
                return documentsDirectoryURL()
            case .Inbox:
                return inboxDirectoryURL()
            case .Library:
                return libraryDirectoryURL()
            case .Temp:
                return tempDirectoryURL()
        }
    }
    
    func buildFullPath(for name: String, inDirectory directory: AppDirectories, isDirectory: Bool = false) -> URL? {
        return getURL(for: directory)?.appendingPathComponent(name, isDirectory: isDirectory)
    }
    
    func createDirectory(with name: String, at directory: AppDirectories, completion: ((URL?, Error?) -> Void)? = nil) {
        do {
            guard let fullPath: URL = buildFullPath(for: name, inDirectory: directory, isDirectory: true) else { completion?(nil, nil); fatalError("Trouble with new directory: \(name)") }
            try FileManager.default.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
            completion?(fullPath, nil)
        } catch {
            completion?(nil, error)
        }
    }
    
} // end extension AppDirectoryNames
