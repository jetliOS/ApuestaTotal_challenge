//
//  ProductDetailCoordinator.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit
import SwiftData

final class ProductDetailCoordinator: NavigationCoordinator {
    var navigationController: UINavigationController
    private let modelContainer: ModelContainer
    private let betId: String

    init(navigationController: UINavigationController, modelContainer: ModelContainer, betId: String) {
        self.navigationController = navigationController
        self.modelContainer = modelContainer
        self.betId = betId
    }

    func start() {
        let context = ModelContext(modelContainer)
        let repository = BetsRepository(context: context)
        let useCase = FetchBetsUseCase(localRepository: repository)
        let viewModel = ProductDetailViewModel(service: useCase)
        let viewController = ProductDetailViewController(viewModel: viewModel, betId: betId)

        navigationController.pushViewController(viewController, animated: true)
    }
}
