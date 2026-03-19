//
//  ProfileCoordinator.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import UIKit
import SwiftData

final class ProfileCoordinator: NavigationCoordinator {
    
    var navigationController: UINavigationController
    private let modelContainer: ModelContainer
    
    init(navigationController: UINavigationController, modelContainer: ModelContainer) {
        self.navigationController = navigationController
        self.modelContainer = modelContainer
    }
    
    func start() {
        let context = ModelContext(modelContainer)
        let betsRepository = BetsRepository(context: context)
        let fetchBetsUseCase = FetchBetsUseCase(localRepository: betsRepository)
        
        let viewModel = ProfileViewModel(
            fetchBetsUseCase: fetchBetsUseCase
        )
        let viewController = ProfileViewController(viewModel: viewModel)
        
        viewController.onBetSelected = { [weak self] bet in
            self?.showBetDetail(betId: bet.id)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func showBetDetail(betId: String) {
        let coordinator = ProductDetailCoordinator(
            navigationController: navigationController,
            modelContainer: modelContainer,
            betId: betId
        )
        coordinator.start()
    }
}
