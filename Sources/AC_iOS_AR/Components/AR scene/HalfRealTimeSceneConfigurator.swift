//
//  HalfRealTimeSceneConfigurator.swift
//  YaPlace
//
//  Created by Rustam Shigapov on 11/09/2019.
//  Copyright © 2019 SKZ. All rights reserved.
//

import UIKit

// MARK: Connect View, Interactor, and Presenter

class HalfRealTimeSceneConfigurator {
    // MARK: Object lifecycle
    
    static let sharedInstance = HalfRealTimeSceneConfigurator()
    
    private init() {}
    
    // MARK: Configuration
    
    func configure(_ viewController: HalfRealTimeSceneViewController) {
        //let viewController = viewController
        let interactor = HalfRealTimeSceneInteractor()
        let presenter = HalfRealTimeScenePresenter()
        let router = HalfRealTimeSceneRouter()
        let worker = HalfRealTimeSceneWorker()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}
