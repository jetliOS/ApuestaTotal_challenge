//
//  FetchBetsUseCase.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation

protocol FetchBetsUseCaseProtocol {
    func execute(completion: @escaping (Result<BetListModel, CustomError>) -> Void)
    func fetchBet(byId id: String, completion: @escaping (Result<BetModel, CustomError>) -> Void)
}

final class FetchBetsUseCase: FetchBetsUseCaseProtocol {
    private let localRepository: BetsRepositoryProtocol

    init(localRepository: BetsRepositoryProtocol) {
        self.localRepository = localRepository
    }

    func execute(completion: @escaping (Result<BetListModel, CustomError>) -> Void) {
        completion(.success(BetListModel(bets: localRepository.getAll())))
    }
    
    func fetchBet(byId id: String, completion: @escaping (Result<BetModel, CustomError>) -> Void) {
        if let bet = localRepository.findFirst(betId: id) {
            completion(.success(bet))
        } else {
            completion(.failure(.errorUnknown))
        }
    }
}
