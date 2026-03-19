//
//  HomeViewModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation
import Combine

protocol HomeViewModelProtocol: AnyObject {
    var betFlowStatePublisher: AnyPublisher<HomeBetFlowState, Never> { get }
    var sectionsPublisher: AnyPublisher<[HomeMatchSection], Never> { get }
    var betFlowState: HomeBetFlowState { get }
    var sections: [HomeMatchSection] { get }

    func executeEvent(
        from input: AnyPublisher<HomeViewModelInput, Never>
    ) -> AnyPublisher<HomeViewModelOutput, Never>
    func handleBetSelection(match: MatchModel, pick: HomeBetPick)
    func confirmBet(stake: Double)
    func dismissBetFlow()
    func hasExistingBet(for matchId: String) -> Bool
}

final class HomeViewModel: HomeViewModelProtocol {
    private let matchService: FetchMatchesUseCaseProtocol
    private let placeBetUseCase: PlaceBetUseCaseProtocol
    private let output = PassthroughSubject<HomeViewModelOutput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var matches: [MatchModel] = []
    private var isLoading = false

    @Published var betFlowState: HomeBetFlowState = .idle
    @Published var sections: [HomeMatchSection] = []

    var betFlowStatePublisher: AnyPublisher<HomeBetFlowState, Never> {
        $betFlowState.eraseToAnyPublisher()
    }

    var sectionsPublisher: AnyPublisher<[HomeMatchSection], Never> {
        $sections.eraseToAnyPublisher()
    }

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
                    self.rebuildSections()
                    self.output.send(.matches(self.matches))
                }
            case .failure(let error):
                self.output.send(.error(error.localizedDescription))
            }
        }
    }
}

// MARK: - Bet Flow
extension HomeViewModel {

    func handleBetSelection(match: MatchModel, pick: HomeBetPick) {
        if hasExistingBet(for: match.id) {
            betFlowState = .duplicateError(
                message: "Ya tienes una apuesta activa en este partido.\nNo puedes hacer múltiples apuestas en el mismo partido."
            )
            return
        }
        betFlowState = .inputting(match: match, pick: pick)
    }

    func confirmBet(stake: Double) {
        guard case .inputting(let match, let pick) = betFlowState else {
            // También aceptar desde validationError para reintentar
            if case .validationError(_, let match, let pick) = betFlowState {
                processConfirmation(match: match, pick: pick, stake: stake)
            }
            return
        }
        processConfirmation(match: match, pick: pick, stake: stake)
    }

    func dismissBetFlow() {
        betFlowState = .idle
    }

    func hasExistingBet(for matchId: String) -> Bool {
        return placeBetUseCase.hasExistingBet(for: matchId)
    }
}

// MARK: - Private
private extension HomeViewModel {

    func processConfirmation(match: MatchModel, pick: HomeBetPick, stake: Double) {
        guard stake > 0 else {
            betFlowState = .validationError(
                message: "Por favor ingresa un monto válido mayor a S/ 0.00",
                match: match, pick: pick
            )
            return
        }
        guard stake >= 1.0 else {
            betFlowState = .validationError(
                message: "El monto mínimo de apuesta es S/ 1.00",
                match: match, pick: pick
            )
            return
        }

        betFlowState = .loading(match: match, pick: pick, stake: stake)

        // Delay para que el sheet termine su animación de dismiss antes de llamar a la API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.placeBet(match: match, pick: pick, stake: stake)
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

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.betFlowState = .result(
                        message: self.feedbackMessage(for: response.bet),
                        betId: response.bet.id
                    )
                    self.rebuildSections()

                case .failure(let error):
                    self.betFlowState = .apiError(message: error.localizedDescription)
                }
            }
        }
    }

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

    // MARK: - Section Building

    func rebuildSections() {
        sections = buildSections(from: matches)
    }

    func buildSections(from matches: [MatchModel]) -> [HomeMatchSection] {
        let groupedMatches = Dictionary(grouping: matches, by: hourTitle(for:))
        let formatter = ISO8601DateFormatter()

        return groupedMatches
            .map { title, matches in
                HomeMatchSection(
                    id: title,
                    title: title,
                    matches: matches.sorted { $0.startTime < $1.startTime }
                )
            }
            .sorted { lhs, rhs in
                guard let lhsMatch = lhs.matches.first,
                      let rhsMatch = rhs.matches.first,
                      let lhsDate = formatter.date(from: lhsMatch.startTime),
                      let rhsDate = formatter.date(from: rhsMatch.startTime) else {
                    return lhs.title < rhs.title
                }
                return lhsDate < rhsDate
            }
    }

    func hourTitle(for match: MatchModel) -> String {
        let formatter = ISO8601DateFormatter()

        guard let date = formatter.date(from: match.startTime) else {
            return match.startTime
        }

        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "es_PE")
        hourFormatter.dateFormat = "HH:mm"
        return hourFormatter.string(from: date)
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
