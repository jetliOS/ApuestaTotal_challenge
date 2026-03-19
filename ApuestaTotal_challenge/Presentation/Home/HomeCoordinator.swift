//
//  HomeCoordinator.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit
import SwiftData

final class HomeCoordinator: NavigationCoordinator {

    var navigationController: UINavigationController
    private let modelContainer: ModelContainer

    init(navigationController: UINavigationController, modelContainer: ModelContainer) {
        self.navigationController = navigationController
        self.modelContainer = modelContainer
    }

    func start() {
        let repository = BaseRepository()
        let useCase = FetchMatchesUseCase(repository: repository)
        let betsRepository = BetsRepository(context: modelContainer.mainContext)
        let placeBetUseCase = PlaceBetUseCase(
            localRepository: betsRepository,
            networkRepository: repository
        )
        let viewModel = HomeViewModel(
            matchService: useCase,
            placeBetUseCase: placeBetUseCase
        )
        let viewController = HomeViewController(viewModel: viewModel)
        
        viewController.onBetDetailRequested = { [weak self] betId in
            self?.showBetDetail(betId: betId)
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
