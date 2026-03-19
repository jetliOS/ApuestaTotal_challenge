//
//  HomeBetFlowState.swift
//  ApuestaTotal_challenge
//

import Foundation

enum HomeBetFlowState: Equatable {
    case idle
    case inputting(match: MatchModel, pick: HomeBetPick)
    case validationError(message: String, match: MatchModel, pick: HomeBetPick)
    case loading(match: MatchModel, pick: HomeBetPick, stake: Double)
    case result(message: String, betId: String)
    case duplicateError(message: String)
    case apiError(message: String)
}
