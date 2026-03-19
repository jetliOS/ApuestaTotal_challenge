//
//  PlaceBetUseCase.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation

struct EvaluatedBet {
    let matchId: String
    let homeTeamName: String
    let awayTeamName: String
    let placedAt: String
    let pick: String
    let odd: Double
    let stake: Double
    let status: String
    let potentialReturn: Double?
}

struct PlaceBetResult {
    let bet: BetModel
}

protocol PlaceBetUseCaseProtocol {
    func execute(
        match: MatchModel,
        pick: String,
        odd: Double,
        stake: Double,
        completion: @escaping (Result<PlaceBetResult, CustomError>) -> Void
    )
    func hasExistingBet(for matchId: String) -> Bool
}

final class PlaceBetUseCase: PlaceBetUseCaseProtocol {
    private let localRepository: BetsRepositoryProtocol
    private let networkRepository: BaseRepositoryProtocol

    init(
        localRepository: BetsRepositoryProtocol,
        networkRepository: BaseRepositoryProtocol
    ) {
        self.localRepository = localRepository
        self.networkRepository = networkRepository
    }

    func execute(
        match: MatchModel,
        pick: String,
        odd: Double,
        stake: Double,
        completion: @escaping (Result<PlaceBetResult, CustomError>) -> Void
    ) {
        print("[PlaceBetUseCase] Execute - matchId: \(match.id), pick: \(pick), stake: \(stake)")
        
        // Fetch bets directly from network
        networkRepository.request(endpoint: ProductAPI.fetchBets, model: BetListDTO.self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let dto):
                let remoteBets = BetMapper.map(response: dto).bets
                let matchBets = remoteBets.filter { $0.matchId == match.id }
                print("[PlaceBetUseCase] Reference bets found: \(matchBets.count)")
                
                let evaluatedBet = evaluateBet(
                    match: match,
                    pick: pick,
                    odd: odd,
                    stake: stake,
                    matchBets: matchBets
                )
                
                print("[PlaceBetUseCase] Evaluated status: \(evaluatedBet.status), return: \(evaluatedBet.potentialReturn ?? 0)")
                
                let persistedBet = makePersistedBet(from: evaluatedBet)

                switch self.localRepository.save(persistedBet) {
                case .success:
                    completion(.success(PlaceBetResult(bet: persistedBet)))
                case .failure(let error):
                    print("[PlaceBetUseCase] Save error: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[PlaceBetUseCase] Fetch error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func hasExistingBet(for matchId: String) -> Bool {
        return localRepository.findFirst(matchId: matchId) != nil
    }
}

private extension PlaceBetUseCase {
    func evaluateBet(
        match: MatchModel,
        pick: String,
        odd: Double,
        stake: Double,
        matchBets: [BetModel]
    ) -> EvaluatedBet {
        let resolvedStatus = resolveStatus(userPick: pick, matchBets: matchBets)

        return EvaluatedBet(
            matchId: match.id,
            homeTeamName: match.homeTeam.name,
            awayTeamName: match.awayTeam.name,
            placedAt: ISO8601DateFormatter().string(from: Date()),
            pick: pick,
            odd: odd,
            stake: stake,
            status: resolvedStatus,
            potentialReturn: resolveReturn(status: resolvedStatus, odd: odd, stake: stake)
        )
    }

    func makePersistedBet(from evaluatedBet: EvaluatedBet) -> BetModel {
        BetModel(
            id: UUID().uuidString,
            matchId: evaluatedBet.matchId,
            homeTeamName: evaluatedBet.homeTeamName,
            awayTeamName: evaluatedBet.awayTeamName,
            placedAt: evaluatedBet.placedAt,
            pick: evaluatedBet.pick,
            odd: evaluatedBet.odd,
            stake: evaluatedBet.stake,
            status: evaluatedBet.status,
            return: evaluatedBet.potentialReturn
        )
    }

    func resolveStatus(userPick: String, matchBets: [BetModel]) -> String {
        let userPickUpper = userPick.uppercased()
        
        // Si no hay apuestas de referencia, el estado es pendiente
        guard !matchBets.isEmpty else {
            print("[resolveStatus] No reference bets found - returning PENDING")
            return "PENDING"
        }
        
        // Buscar una bet de referencia resuelta (WON o LOST), ignorar PENDING
        guard let referenceBet = matchBets.first(where: {
            let s = $0.status.uppercased()
            return s == "WON" || s == "LOST"
        }) else {
            print("[resolveStatus] All reference bets are PENDING - returning PENDING")
            return "PENDING"
        }
        
        let refPick = referenceBet.pick.uppercased()
        let refStatus = referenceBet.status.uppercased()
        
        print("[resolveStatus] userPick: \(userPickUpper), refPick: \(refPick), refStatus: \(refStatus)")
        
        // Caso DRAW: el usuario apuesta a empate
        // Solo gana si hay una bet de DRAW que haya ganado
        if userPickUpper == "DRAW" {
            let drawBet = matchBets.first(where: {
                $0.pick.uppercased() == "DRAW" && $0.status.uppercased() != "PENDING"
            })
            if let drawBet = drawBet {
                print("[resolveStatus] DRAW bet found with status: \(drawBet.status)")
                return drawBet.status.uppercased()
            }
            // Si no hay bet de DRAW resuelta, pero hay otras resueltas
            // significa que el partido ya se jugó y no fue empate → LOST
            print("[resolveStatus] No resolved DRAW bet, match resolved with other picks - returning LOST")
            return "LOST"
        }
        
        // Caso HOME o AWAY: el usuario apuesta a un equipo
        if userPickUpper == refPick {
            // Mismo pick que la referencia → mismo resultado
            print("[resolveStatus] Same pick - returning \(refStatus)")
            return refStatus
        } else {
            // Pick diferente → resultado invertido
            let inverted = refStatus == "WON" ? "LOST" : "WON"
            print("[resolveStatus] Different pick - returning \(inverted) (inverted)")
            return inverted
        }
    }

    func resolveReturn(status: String, odd: Double, stake: Double) -> Double? {
        switch status.uppercased() {
        case "WON":
            return odd * stake
        case "LOST":
            return 0
        default:
            return nil
        }
    }
}
