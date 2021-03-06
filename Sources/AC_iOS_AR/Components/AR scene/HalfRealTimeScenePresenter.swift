//
//  HalfRealTimeScenePresenter.swift
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
import ARKit

protocol HalfRealTimeScenePresentationLogic {
    
    func presentNodes(response: HalfRealTimeScene.Nodes.Response)
    func presentClusters(response: HalfRealTimeScene.Clusters.Response)
    
    func presentStart(response: HalfRealTimeScene.Start.Response)
    func presentStop(response: HalfRealTimeScene.Stop.Response)

    //MARK: new API
    func presentLocalize(response: HalfRealTimeScene.Localize.Response)

    func presentLocalizeData(response: HalfRealTimeScene.LocalizeData.Response)

    func presentDelegate(response: HalfRealTimeScene.Delegate.Response)
    func presentDelete(response: HalfRealTimeScene.Delete.Response)
    func presentStickerFilters(response: HalfRealTimeScene.StickerFilters.Response)
}

class HalfRealTimeScenePresenter: HalfRealTimeScenePresentationLogic {
    
    weak var viewController: HalfRealTimeSceneDisplayLogic?
   
    func presentNodes(response: HalfRealTimeScene.Nodes.Response) {
        let viewModel = HalfRealTimeScene.Nodes.ViewModel(
            views: response.views,
            frames: response.frames
        )
        viewController?.displayNodes(viewModel: viewModel)
    }
    
    func presentClusters(response: HalfRealTimeScene.Clusters.Response) {
        let viewModel = HalfRealTimeScene.Clusters.ViewModel(clusters: response.clusters)
        viewController?.displayClusters(viewModel: viewModel)
    }

    
    func presentStart(response: HalfRealTimeScene.Start.Response) {
        let viewModel = HalfRealTimeScene.Start.ViewModel()
        viewController?.displayStart(viewModel: viewModel)
    }
    
    func presentStop(response: HalfRealTimeScene.Stop.Response) {
        let viewModel = HalfRealTimeScene.Stop.ViewModel()
        viewController?.displayStop(viewModel: viewModel)
    }
    
    func presentLocalize(response: HalfRealTimeScene.Localize.Response) {
        let viewModel = HalfRealTimeScene.Localize.ViewModel()
        viewController?.displayLocalize(viewModel: viewModel)
    }
    
    
    func presentLocalizeData(response: HalfRealTimeScene.LocalizeData.Response) {
        let viewModel = HalfRealTimeScene.LocalizeData.ViewModel()
        viewController?.displayLocalizeData(viewModel: viewModel)
    }
    
    func presentDelegate(response: HalfRealTimeScene.Delegate.Response) {
        let viewModel = HalfRealTimeScene.Delegate.ViewModel()
        self.viewController?.displayDelegate(viewModel: viewModel)
    }
    
    func presentDelete(response: HalfRealTimeScene.Delete.Response) {
        let viewModel = HalfRealTimeScene.Delete.ViewModel()
        self.viewController?.displayDelete(viewModel: viewModel)
    }
    
    func presentStickerFilters(response: HalfRealTimeScene.StickerFilters.Response) {
        self.viewController?.displayStickerFilters(viewModel: HalfRealTimeScene.StickerFilters.ViewModel())
    }
    
}
