//
//  BetEntity.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import Foundation
import SwiftData

@Model
final class BetEntity {
    @Attribute(.unique) var id: String
    var matchId: String
    var homeTeamName: String?
    var awayTeamName: String?
    var placedAt: String
    var pick: String
    var odd: Double
    var stake: Double
    var status: String
    var potentialReturn: Double?
    var competition: String?
    var matchDate: String?
    var homeScore: Int?
    var awayScore: Int?
    var betType: String?
    var createdAt: Date

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
        potentialReturn: Double?,
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
        self.potentialReturn = potentialReturn
        self.competition = competition
        self.matchDate = matchDate
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.betType = betType
        self.createdAt = createdAt
    }
}
