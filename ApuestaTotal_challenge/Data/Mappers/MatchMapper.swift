//
//  MatchMapper.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

enum MatchMapper {
    static func map(response dto: MatchListDTO) -> MatchListModel {
        MatchListModel(
            date: dto.date,
            timezone: dto.timezone,
            matches: dto.matches.map { dto in
                map(match: dto)
            }
        )
    }

    static func map(match dto: MatchDTO) -> MatchModel {
        MatchModel(
            id: dto.id,
            startTime: dto.startTime,
            league: MatchLeagueModel(
                id: dto.league.id,
                name: dto.league.name,
                country: dto.league.country
            ),
            homeTeam: MatchTeamModel(
                id: dto.homeTeam.id,
                name: dto.homeTeam.name,
                shortName: dto.homeTeam.shortName
            ),
            awayTeam: MatchTeamModel(
                id: dto.awayTeam.id,
                name: dto.awayTeam.name,
                shortName: dto.awayTeam.shortName
            ),
            market: MatchMarketModel(
                type: dto.market.type,
                odds: MatchOddsModel(
                    home: dto.market.odds.home,
                    draw: dto.market.odds.draw,
                    away: dto.market.odds.away
                )
            )
        )
    }
}
