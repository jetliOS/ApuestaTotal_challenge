//
//  BetsRepository.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation
import SwiftData

protocol BetsRepositoryProtocol {
    func getAll() -> [BetModel]
    func save(_ bet: BetModel) -> Result<Void, CustomError>
    func findFirst(matchId: String) -> BetModel?
    func findFirst(betId: String) -> BetModel?
    func isEmpty() -> Bool
}

final class BetsRepository: BetsRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getAll() -> [BetModel] {
        let descriptor = FetchDescriptor<BetEntity>()
        guard let entities = try? context.fetch(descriptor) else { return [] }
        return entities
            .map(map(entity:))
            .sorted { $0.placedAt > $1.placedAt }
    }

    func save(_ bet: BetModel) -> Result<Void, CustomError> {
        context.insert(makeEntity(from: bet))

        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.errorUnknown)
        }
    }

    func findFirst(matchId: String) -> BetModel? {
        let descriptor = FetchDescriptor<BetEntity>()
        guard let entities = try? context.fetch(descriptor) else { return nil }

        return entities
            .map(map(entity:))
            .filter { $0.matchId == matchId }
            .sorted { $0.placedAt > $1.placedAt }
            .first
    }
    
    func findFirst(betId: String) -> BetModel? {
        let descriptor = FetchDescriptor<BetEntity>(
            predicate: #Predicate { $0.id == betId }
        )
        guard let entity = try? context.fetch(descriptor).first else { return nil }
        return map(entity: entity)
    }

    func isEmpty() -> Bool {
        let descriptor = FetchDescriptor<BetEntity>()
        guard let entities = try? context.fetch(descriptor) else { return true }
        return entities.isEmpty
    }
}

private extension BetsRepository {
    func map(entity: BetEntity) -> BetModel {
        BetModel(
            id: entity.id,
            matchId: entity.matchId,
            homeTeamName: entity.homeTeamName,
            awayTeamName: entity.awayTeamName,
            placedAt: entity.placedAt,
            pick: entity.pick,
            odd: entity.odd,
            stake: entity.stake,
            status: entity.status,
            return: entity.potentialReturn,
            competition: entity.competition,
            matchDate: entity.matchDate,
            homeScore: entity.homeScore,
            awayScore: entity.awayScore,
            betType: entity.betType,
            createdAt: entity.createdAt
        )
    }

    func makeEntity(from bet: BetModel) -> BetEntity {
        BetEntity(
            id: bet.id,
            matchId: bet.matchId,
            homeTeamName: bet.homeTeamName,
            awayTeamName: bet.awayTeamName,
            placedAt: bet.placedAt,
            pick: bet.pick,
            odd: bet.odd,
            stake: bet.stake,
            status: bet.status,
            potentialReturn: bet.return,
            competition: bet.competition,
            matchDate: bet.matchDate,
            homeScore: bet.homeScore,
            awayScore: bet.awayScore,
            betType: bet.betType,
            createdAt: bet.createdAt
        )
    }
}
