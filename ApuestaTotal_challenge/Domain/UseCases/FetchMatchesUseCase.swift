//
//  FetchMatchesUseCase.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation

protocol FetchMatchesUseCaseProtocol {
    func execute(completion: @escaping (Result<MatchListModel, CustomError>) -> Void)
}

final class FetchMatchesUseCase: FetchMatchesUseCaseProtocol {

    private let repository: BaseRepositoryProtocol

    init(repository: BaseRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<MatchListModel, CustomError>) -> Void) {
        repository.request(
            endpoint: ProductAPI.fetchMatches,
            model: MatchListDTO.self
        ) { result in
            switch result {
            case .success(let response):
                let matches = MatchMapper.map(response: response)
                completion(.success(matches))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
