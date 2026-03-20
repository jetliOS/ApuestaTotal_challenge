//
//  HomeViewModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation
import Combine

protocol HomeViewModelProtocol {
    func executeEvent(
        from input: AnyPublisher<HomeViewModelInput, Never>
    ) -> AnyPublisher<HomeViewModelOutput, Never>
    func placeBet(match: MatchModel, pick: HomeBetPick, stake: Double)
    func hasExistingBet(for matchId: String) -> Bool
}

final class HomeViewModel: HomeViewModelProtocol {
    private let matchService: FetchMatchesUseCaseProtocol
    private let placeBetUseCase: PlaceBetUseCaseProtocol
    private let output = PassthroughSubject<HomeViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var matches: [MatchModel] = []
    private var isLoading = false

    init(
        matchService: FetchMatchesUseCaseProtocol,
        placeBetUseCase: PlaceBetUseCaseProtocol
    ) {
        self.matchService = matchService
        self.placeBetUseCase = placeBetUseCase
    }
}

// MARK: Combine
extension HomeViewModel {

    func executeEvent(from input: AnyPublisher<HomeViewModelInput, Never>) -> AnyPublisher<HomeViewModelOutput, Never> {
        input.sink { [weak self] event in
            switch event {
            case .onAppear:
                self?.loadMatches()
            }
        }
        .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    private func loadMatches() {
        guard !isLoading, matches.isEmpty else { return }

        isLoading = true

        matchService.execute { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                self.matches = response.matches
                if self.matches.isEmpty {
                    self.output.send(.empty)
                } else {
                    self.output.send(.matches(self.matches))
                }
            case .failure(let error):
                self.output.send(.error(error.localizedDescription))
            }
        }
    }

    func placeBet(match: MatchModel, pick: HomeBetPick, stake: Double) {
        placeBetUseCase.execute(
            match: match,
            pick: pick.domainValue,
            odd: odd(for: pick, in: match),
            stake: stake
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.output.send(.betPlaced(
                    self.feedbackMessage(for: response.bet),
                    betId: response.bet.id
                ))
                
                self.output.send(.matches(self.matches))
                
            case .failure(let error):
                self.output.send(.error(error.localizedDescription))
            }
        }
    }
    
    func hasExistingBet(for matchId: String) -> Bool {
        return placeBetUseCase.hasExistingBet(for: matchId)
    }
}

private extension HomeViewModel {
    func odd(for pick: HomeBetPick, in match: MatchModel) -> Double {
        switch pick {
        case .home:
            return match.market.odds.home
        case .draw:
            return match.market.odds.draw
        case .away:
            return match.market.odds.away
        }
    }

    func feedbackMessage(for bet: BetModel) -> String {
        switch bet.status.uppercased() {
        case "WON":
            let returnValue = String(format: "%.2f", bet.return ?? 0)
            return "Apuesta registrada. Ganaste S/ \(returnValue)."
        case "LOST":
            return "Apuesta registrada. Resultado: perdida."
        default:
            return "Apuesta registrada. Resultado pendiente."
        }
    }
}

private extension HomeBetPick {
    var domainValue: String {
        switch self {
        case .home:
            return "HOME"
        case .draw:
            return "DRAW"
        case .away:
            return "AWAY"
        }
    }
}


