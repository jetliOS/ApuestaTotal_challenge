//
//  MatchDTO.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

struct MatchListDTO: Decodable {
    let date: String
    let timezone: String
    let matches: [MatchDTO]
}

struct MatchDTO: Decodable {
    let id: String
    let startTime: String
    let league: MatchLeagueDTO
    let homeTeam: MatchTeamDTO
    let awayTeam: MatchTeamDTO
    let market: MatchMarketDTO
}

struct MatchLeagueDTO: Decodable {
    let id: String
    let name: String
    let country: String
}

struct MatchTeamDTO: Decodable {
    let id: String
    let name: String
    let shortName: String
}

struct MatchMarketDTO: Decodable {
    let type: String
    let odds: MatchOddsDTO
}

struct MatchOddsDTO: Decodable {
    let home: Double
    let draw: Double
    let away: Double
}
