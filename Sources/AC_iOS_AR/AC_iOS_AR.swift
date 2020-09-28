import Foundation

open class AR {
    
    typealias ArController = HalfRealTimeSceneViewController
    
    static let controller = ArController.shared

    open class Photo {
        
        public static func takePhoto(completion: @escaping (Data?) -> Void) {
            AR.controller.takePhoto { (data, alertMessage, deviceOrientation) in
                completion(data)
            }
        }
        
    }

    open class Session {
        
        
        
    }

}
