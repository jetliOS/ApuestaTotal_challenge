//
//  ProductDetailViewModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Combine
import Foundation

protocol ProductDetailViewModelProtocol {
    func executeEvent(
        from input: AnyPublisher<ProductDetailViewModelInput, Never>
    ) -> AnyPublisher<ProductDetailViewModelOutput, Never>
}

final class ProductDetailViewModel: ProductDetailViewModelProtocol {
    private let service: FetchBetsUseCaseProtocol
    private let output = PassthroughSubject<ProductDetailViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(service: FetchBetsUseCaseProtocol) {
        self.service = service
    }
}

// MARK: - Combine
extension ProductDetailViewModel {
    func executeEvent(
        from input: AnyPublisher<ProductDetailViewModelInput, Never>
    ) -> AnyPublisher<ProductDetailViewModelOutput, Never> {
        input
            .sink { [weak self] event in
                switch event {
                case .onAppear(let betId):
                    self?.loadBet(byId: betId)
                }
            }
            .store(in: &cancellables)

        return output.eraseToAnyPublisher()
    }

    private func loadBet(byId id: String) {
        service.fetchBet(byId: id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let bet):
                self.output.send(.bet(bet))
            case .failure(let error):
                self.output.send(.error(error.localizedDescription))
            }
        }
    }
}
