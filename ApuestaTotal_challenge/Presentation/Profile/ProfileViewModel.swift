//
//  ProfileViewModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation

struct ProfileScreenModel {
    let bets: [BetModel]
}

protocol ProfileViewModelProtocol {
    func loadProfileScreen() -> Result<ProfileScreenModel, CustomError>
}

final class ProfileViewModel: ProfileViewModelProtocol {

    private let fetchBetsUseCase: FetchBetsUseCaseProtocol

    init(
        fetchBetsUseCase: FetchBetsUseCaseProtocol
    ) {
        self.fetchBetsUseCase = fetchBetsUseCase
    }

    func loadProfileScreen() -> Result<ProfileScreenModel, CustomError> {
        var result: Result<ProfileScreenModel, CustomError> = .success(
            ProfileScreenModel(bets: [])
        )

        fetchBetsUseCase.execute { response in
            switch response {
            case .success(let betList):
                result = .success(ProfileScreenModel(bets: betList.bets))
            case .failure(let error):
                result = .failure(error)
            }
        }

        return result
    }
}
