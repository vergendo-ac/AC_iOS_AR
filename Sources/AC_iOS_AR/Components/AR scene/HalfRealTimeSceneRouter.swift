//
//  HalfRealTimeSceneRouter.swift
//  YaPlace
//
//  Created by Rustam Shigapov on 11/09/2019.
//  Copyright (c) 2019 SKZ. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol HalfRealTimeSceneRoutingLogic {
}

protocol HalfRealTimeSceneDataPassing {
  var dataStore: HalfRealTimeSceneDataStore? { get set }
}

class HalfRealTimeSceneRouter: NSObject, HalfRealTimeSceneRoutingLogic, HalfRealTimeSceneDataPassing {
    weak var viewController: HalfRealTimeSceneViewController?
    var dataStore: HalfRealTimeSceneDataStore?
    
    
}
