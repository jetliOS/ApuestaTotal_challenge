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
        // Si no hay apuestas de referencia, el estado es pendiente
        guard let referenceBet = matchBets.first else {
            print("[resolveStatus] No reference bet found - returning PENDING")
            return "PENDING"
        }
        
        let refPick = referenceBet.pick.uppercased()
        let refStatus = referenceBet.status.uppercased()
        let userPickUpper = userPick.uppercased()
        
        print("[resolveStatus] matchId: \(referenceBet.matchId), userPick: \(userPickUpper), refPick: \(refPick), refStatus: \(refStatus)")
        
        // Si la referencia está pendiente, la apuesta también
        if refStatus == "PENDING" {
            print("[resolveStatus] Reference is PENDING - returning PENDING")
            return "PENDING"
        }
        
        // Caso 1: La pick coincide con el pick de referencia
        // → Comparte el mismo resultado (si ellos ganan, tú ganas; si pierden, tú pierdes)
        if userPickUpper == refPick {
            print("[resolveStatus] Same pick - returning \(refStatus)")
            return refStatus // "WON" o "LOST"
        }
        
        // Caso 2: Tu pick es diferente al pick de referencia
        // → El resultado es invertido (si ellos ganan, tú pierdes; si pierden, tú ganas)
        else {
            if refStatus == "WON" {
                print("[resolveStatus] Different pick, ref WON - returning LOST (inverted)")
                return "LOST"
            } else if refStatus == "LOST" {
                print("[resolveStatus] Different pick, ref LOST - returning WON (inverted)")
                return "WON"
            } else {
                print("[resolveStatus] Unrecognized status - returning PENDING")
                return "PENDING"
            }
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
