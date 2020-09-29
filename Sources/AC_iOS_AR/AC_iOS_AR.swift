import Foundation
import UIKit
import CoreLocation

open class AR {
    
    typealias ArController = HalfRealTimeSceneViewController
    
    static let controller = ArController.shared

    open class Localization {
        
        public static func getData(completion: @escaping (_ imageData: Data?, _ location: CLLocation?, _ photoInfo: [String:Any]?) -> Void) {
            AR.controller.getLocalizationData(completion: completion)
        }
        
    }

    open class Session {
        
        public static func set(arView backView: UIView) {
            AR.controller.set(arView: backView)
        }
        
        public static func startAR() {
            AR.controller.start()
        }
        
        public static func stopAR() {
            AR.controller.stopAR()
        }

        public static func show(localizationResult: LocalizationResult) {
            AR.controller.show(localizationResult: localizationResult)
        }

    }

}
