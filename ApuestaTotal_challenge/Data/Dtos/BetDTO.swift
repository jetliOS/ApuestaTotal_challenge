//
//  BetDTO.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

struct BetListDTO: Decodable {
    let bets: [BetDTO]
}

struct BetDTO: Decodable {
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
}
