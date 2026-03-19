//
//  HomeViewActions.swift
//  ApuestaTotal_challenge
//

import Foundation

struct HomeViewActions {
    let onBetSelected: (MatchModel, HomeBetPick) -> Void
    let onConfirmBet: (Double) -> Void
    let onDismissBetFlow: () -> Void
    let onBetDetailRequested: (String) -> Void
}
