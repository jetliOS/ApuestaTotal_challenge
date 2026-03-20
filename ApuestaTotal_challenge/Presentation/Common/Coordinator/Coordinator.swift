//
//  CoordinatorProtocol.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    func start()
}

@MainActor
protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get set }
}
