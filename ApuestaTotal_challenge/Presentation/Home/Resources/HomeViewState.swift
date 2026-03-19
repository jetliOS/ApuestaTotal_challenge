//
//  HomeViewState.swift
//  ApuestaTotal_challenge
//

import Foundation

struct HomeViewState {
    let sections: [HomeMatchSection]
    let betFlowState: HomeBetFlowState
    let hasExistingBet: (String) -> Bool
}
