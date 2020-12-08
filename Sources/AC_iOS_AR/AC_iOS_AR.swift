import Foundation
import UIKit
import CoreLocation

open class AR {
    
    typealias ArController = HalfRealTimeSceneViewController
    
    static let controller = ArController.shared

    open class Localization {
        
        public static func getData(completion: @escaping (_ imageData: Data?, _ location: CLLocation?, _ photoInfo: [String:Any]?, _ pose: Pose?) -> Void) {
            AR.controller.getLocalizationData(completion: completion)
        }
        
    }

    open class Session {
        
        public static func set(arView backView: UIView, stickerDelegate: StickerDelegate? = nil) {
            AR.controller.set(arView: backView, stickerDelegate: stickerDelegate)
        }
        
        public static func startAR() {
            AR.controller.start()
        }
        
        public static func stopAR() {
            AR.controller.stopAR()
        }

        public static func show(localizationData: Data) {
            guard let localizationResult = try? JSONDecoder().decode(LocalizationResult.self, from: localizationData) else { return }
            AR.controller.show(localizationResult: localizationResult)
        }
        
        public static func takePhoto(completion: @escaping (Data?, NSError?, UIDeviceOrientation?) -> Void) {
            AR.controller.takePhoto(completion: completion)
        }

    }
    
    open class Sticker {
        public static func delete(stickerID: Int) {
            AR.controller.delete(by: stickerID)
        }
        public static func filter(by types: [String:Bool] = [:]) {
            AR.controller.set(filters: types)
        }
    }

}
