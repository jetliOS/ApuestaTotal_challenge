//
//  BetMapper.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import Foundation

enum BetMapper {
    static func map(response dto: BetListDTO) -> BetListModel {
        BetListModel(
            bets: dto.bets.map { dto in
                map(bet: dto)
            }
        )
    }

    static func map(bet dto: BetDTO) -> BetModel {
        BetModel(
            id: dto.id,
            matchId: dto.matchId,
            homeTeamName: dto.homeTeamName,
            awayTeamName: dto.awayTeamName,
            placedAt: dto.placedAt,
            pick: dto.pick,
            odd: dto.odd,
            stake: dto.stake,
            status: dto.status,
            return: dto.return,
            competition: nil,
            matchDate: nil,
            homeScore: nil,
            awayScore: nil,
            betType: "1X2",
            createdAt: Date()
        )
    }
    
    /// Create a local bet for save 
    static func createEnrichedBet(
        id: String,
        matchId: String,
        homeTeamName: String?,
        awayTeamName: String?,
        pick: String,
        odd: Double,
        stake: Double,
        status: String = "PENDING",
        potentialReturn: Double?,
        competition: String? = nil,
        matchDate: String? = nil,
        betType: String = "1X2"
    ) -> BetModel {
        BetModel(
            id: id,
            matchId: matchId,
            homeTeamName: homeTeamName,
            awayTeamName: awayTeamName,
            placedAt: ISO8601DateFormatter().string(from: Date()),
            pick: pick,
            odd: odd,
            stake: stake,
            status: status,
            return: potentialReturn,
            competition: competition,
            matchDate: matchDate,
            homeScore: nil,
            awayScore: nil,
            betType: betType,
            createdAt: Date()
        )
    }
}
