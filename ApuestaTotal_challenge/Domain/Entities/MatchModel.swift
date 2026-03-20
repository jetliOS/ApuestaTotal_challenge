//
//  MatchModel.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

struct MatchListModel {
    let date: String
    let timezone: String
    let matches: [MatchModel]
}

struct MatchModel {
    let id: String
    let startTime: String
    let league: MatchLeagueModel
    let homeTeam: MatchTeamModel
    let awayTeam: MatchTeamModel
    let market: MatchMarketModel
}

struct MatchLeagueModel {
    let id: String
    let name: String
    let country: String
}

struct MatchTeamModel {
    let id: String
    let name: String
    let shortName: String
}

struct MatchMarketModel {
    let type: String
    let odds: MatchOddsModel
}

struct MatchOddsModel {
    let home: Double
    let draw: Double
    let away: Double
}
