//
//  BetModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation

struct BetListModel {
    let bets: [BetModel]
}

struct BetModel {
    let id: String
    let matchId: String
    let homeTeamName: String?
    let awayTeamName: String?
    let placedAt: String
    let pick: String
    let odd: Double
    let stake: Double
    let status: String
    let `return`: Double?
    
    let competition: String?
    let matchDate: String?
    let homeScore: Int?
    let awayScore: Int?
    let betType: String?
    let createdAt: Date
    
    init(
        id: String,
        matchId: String,
        homeTeamName: String?,
        awayTeamName: String?,
        placedAt: String,
        pick: String,
        odd: Double,
        stake: Double,
        status: String,
        return: Double?,
        competition: String? = nil,
        matchDate: String? = nil,
        homeScore: Int? = nil,
        awayScore: Int? = nil,
        betType: String? = "1X2",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.matchId = matchId
        self.homeTeamName = homeTeamName
        self.awayTeamName = awayTeamName
        self.placedAt = placedAt
        self.pick = pick
        self.odd = odd
        self.stake = stake
        self.status = status
        self.return = `return`
        self.competition = competition
        self.matchDate = matchDate
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.betType = betType
        self.createdAt = createdAt
    }
}
