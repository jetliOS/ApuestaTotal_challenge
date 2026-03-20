//
//  HomeViewModelOutput.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import Foundation

enum HomeViewModelOutput {
    case matches([MatchModel])
    case empty
    case betPlaced(String, betId: String)
    case error(String)
}
