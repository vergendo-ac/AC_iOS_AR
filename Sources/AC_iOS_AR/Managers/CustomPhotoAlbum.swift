//
//  CustomPhotoAlbum.swift
//  PhotoPicker
//
//  Created by Mac on 11.04.2018.
//  Copyright © 2018 Mac. All rights reserved.
//

import Photos
import MobileCoreServices
import UIKit

class CustomPhotoAlbum: NSObject {
    
    struct CustomPhotoAlbumImage {
        let name: String?
        let data: Data?
        let localID: String?
    }
    
    var albumName: String? = nil // here put your album name
    
    var photoAssets = PHFetchResult<PHAssetCollection>()
    var album: PHAssetCollection!
    
    var allImages: [CustomPhotoAlbumImage] = []
    
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.album = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    init(albumName: String) {
        super.init()
        
        self.albumName = albumName
        
    }
    
    init(albumID: String, completion: ((String?) -> Void)? = nil) {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum(with: albumID) {
            self.album = assetCollection
            self.albumName = self.album.localizedTitle
        } else {
            print("ERROR: CustomPhotoAlbum: can't get album with id = \(albumID)")
        }
        
        completion?(self.albumName)

    }
    
    func prepareAlbum(completion: @escaping (String?) -> ()) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.album = assetCollection
            completion(self.album.localIdentifier)
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum(completion: completion)
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum(completion: @escaping (String?) -> () = { _ in }) {
        
        guard let albumName = self.albumName else {
            completion(nil)
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.album = self.fetchAssetCollectionForAlbum()
                completion(self.album.localIdentifier)
            } else {
                print("error \(error!)")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        
        guard let albumName = self.albumName else {
            return nil
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        photoAssets = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = photoAssets.firstObject {
            return photoAssets.firstObject
        }
        return nil
    }
    
    func fetchAssetCollectionForAlbum(with localIdentifier: String) -> PHAssetCollection? {
        photoAssets = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil)
        if let _: AnyObject = photoAssets.firstObject {
            return photoAssets.firstObject
        }
        return nil
    }
    
    func save(image: UIImageView) {
        if album == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            UIGraphicsBeginImageContextWithOptions(image.bounds.size, false, 0)
            let context: CGContext? = UIGraphicsGetCurrentContext()
            image.layer.render(in: context!)
            
            let imgs: UIImage? = image.image
            UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: imgs!)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.album)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
            
        }, completionHandler: nil)
    }
    
    func getImagesCount() -> Int {
        
        guard let album = self.album else {
            print("No album!")
            return -1
        }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
        
        if assets.count > 0 {
            return assets.count
        }
        
        return 0
        
    }
    
    func getAllImagesFromAlbum(completion: @escaping (Int, AlertMessage?) -> Void) -> [CustomPhotoAlbumImage] {
        
        allImages.removeAll()
        
        guard let album = self.album else {
            completion(-1,  AlertMessage(title: "Get images from album", message: "No album found") )
            return []
        }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
        
        assets.enumerateObjects{(
            asset: PHAsset,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            /* For best quality and progress*/
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            
            completion(count, nil)
            
            PHImageManager.default().requestImageData(
                for: asset,
                options: options
            ) { (imageData, dataUTI, orientation, info) in
                    self.addImgToArray(uploadImage:
                        CustomPhotoAlbumImage(
                            name: asset.originalFilename,
                            data: imageData,
                            localID: asset.localIdentifier
                        )
                    )
            }
            
        }
    
        return self.allImages
    }
    
    func addImgToArray(uploadImage: CustomPhotoAlbumImage) {
        self.allImages.append(uploadImage)
    }
    
    func saveUImage(image: UIImage, completion: @escaping (String) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.album)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }, completionHandler: { (success, error) -> Void in
            completion(success ? "" : error!.localizedDescription)
        })
    }
    
    // Save an image with meta data to the photo album
    func saveToPhotoAlbumWithMetadata(_ imageData: Data, imageName: String, id: Int?, completion: @escaping (String?, Error?, Int?) -> ()) {
        guard let album = self.album else {
            completion(nil, nil, id)
            return
        }

        DispatchQueue.global().sync {
            // Take care when passing the paths. The directory must exist.
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
            let filePath = path + imageName
            
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                completion(nil, error, id)
                return
            }
            
            // You can change your exif type here.
            if let cfPath = CFURLCreateWithFileSystemPath(nil, filePath as CFString, CFURLPathStyle.cfurlposixPathStyle, false),
                let destination = CGImageDestinationCreateWithURL(cfPath, kUTTypeJPEG, 1, nil),
                let source = CGImageSourceCreateWithData(imageData as NSData, nil),
                let copyProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
            {
                let metadata = NSMutableDictionary(dictionary: copyProperties) as CFDictionary
                CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
                CGImageDestinationFinalize(destination)
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Can't get metadata for \(imageName)"])
                completion(nil, error , id)
                return
            }
            
            var assetPlaceHolder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
                assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
            },
                completionHandler: { (success, error) -> Void in
                    if success {
                        completion(assetPlaceHolder?.localIdentifier, error, id)
                    } else {
                        completion(assetPlaceHolder?.localIdentifier, error, id)
                    }
            })
        }
    
    }
    
    func delete(completion: @escaping (Bool) -> Void) {
        self.deleteImages { isOK in
            if isOK {
                guard let album = self.album else {
                    completion(false)
                    return
                }
                PHPhotoLibrary.shared().performChanges({ () -> Void in
                    PHAssetCollectionChangeRequest.deleteAssetCollections([album] as NSFastEnumeration)
                }) { (isOK, maybeError) in
                    if isOK {
                        print("Album has been deleted successfully")
                        completion(true)
                    } else if let error = maybeError{
                        print("Error during deleting album \(String(describing: self.albumName)): \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Something goes wrong during deleting album \(String(describing: self.albumName))")
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func deleteImages(completion: @escaping (Bool) -> Void) {
        
        if getImagesCount() > 0 {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            }) { (isOK, maybeError) in
                if let error = maybeError {
                    print("PhotoAlbum: deleteImages: error = \(error.localizedDescription)")
                }
                completion(isOK)
            }
        } else {
            completion(true)
        }
        
    }

    func deleteImages(patchesToDelete: Int) {
        
        if getImagesCount() > 0 {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            options.fetchLimit = patchesToDelete
            let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            }, completionHandler: nil)
        }
        
    }
    
    func deleteImage(name: String, completion: @escaping (Bool, Error?) -> Void ) {
        
        if getImagesCount() > 0 {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
            
            let assetsToDelete = assets.objects(at: IndexSet(0...assets.count-1)).filter { (asset) -> Bool in
                var filename: String = ""
                if let originalName = asset.originalFilename {
                    if let lastSlash = originalName.lastIndex(of: "/") {
                        let range = Range(uncheckedBounds: (lower: originalName.index(after: lastSlash), upper: originalName.endIndex))
                        filename = String(originalName[range])
                    } else {
                        filename = originalName
                    }
                }
                return filename == name
            }
            
            print(assetsToDelete)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
            }) { (isOK, maybeError) in
                completion(isOK, maybeError)
            }
        } else {
            completion(false, nil)
        }

    }
    
    func deleteImage(maybeID: String?, completion: @escaping (Bool, Error?) -> Void ) {
        
        guard let id = maybeID, getImagesCount() > 0 else {
            completion(false, nil)
            return
        }
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: album, options: options)
        
        let assetsToDelete = assets.objects(at: IndexSet(0...assets.count-1)).filter { (asset) -> Bool in
            return asset.localIdentifier == id
        }
        
        print(assetsToDelete)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { (isOK, maybeError) in
            completion(isOK, maybeError)
        }
        
    }

    func getURL(of asset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        
        if asset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            asset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                completionHandler(contentEditingInput!.fullSizeImageURL)
            })
        } else if asset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    func rename(maybeNewName: String?, completion: @escaping (Bool) -> Void) {
        
        guard let newName = maybeNewName, self.album.canPerform(.rename) else {
            print("can't PerformEditOperation - rename")
            return
        }
    
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            
            let changeTitleRequest = PHAssetCollectionChangeRequest(for: self.album)
            changeTitleRequest?.title = newName

        }) { (isOK, maybeError) in
            if isOK {
                self.albumName = newName
                print("Album has been renamed successfully. New name = \(newName)")
            } else if let error = maybeError{
                print("Error during renaming album \(String(describing: self.albumName)): \(error.localizedDescription)")
            } else {
                print("Something goes wrong during renaming album \(String(describing: self.albumName))")
            }
            completion(isOK)
        }
    }
    
}
