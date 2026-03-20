//
//  ProductAPI.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 17/03/26.
//

// Open/Closed Principle
enum ProductAPI: APIEndpoint {
    case fetchBets
    case fetchMatches

    var path: String {
        switch self {
        case .fetchBets:
            return "/bets"
        case .fetchMatches:
            return "/matchestoday"
        }
    }

    var method: HTTPMethod { .get }

    var parameters: Parameters? { [:] }
}
