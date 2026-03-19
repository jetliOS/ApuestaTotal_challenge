//
//  MainCoordinator.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit
import SwiftData

final class MainCoordinator: Coordinator {

    let rootViewController = UITabBarController()
    private let modelContainer: ModelContainer
    private var childCoordinators: [Coordinator] = []

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func start() {
        let homeNav = UINavigationController()
        let profileNav = UINavigationController()

        configureNavigationBarAppearance(for: homeNav)
        configureNavigationBarAppearance(for: profileNav)

        let homeCoordinator = HomeCoordinator(
            navigationController: homeNav,
            modelContainer: modelContainer
        )
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNav,
            modelContainer: modelContainer
        )

        childCoordinators = [homeCoordinator, profileCoordinator]

        homeCoordinator.start()
        profileCoordinator.start()

        homeNav.tabBarItem = UITabBarItem(
            title: "Inicio",
            image: UIImage(systemName: "house"),
            tag: 0
        )
        profileNav.tabBarItem = UITabBarItem(
            title: "Perfil",
            image: UIImage(systemName: "person.crop.circle"),
            tag: 1
        )

        rootViewController.viewControllers = [homeNav, profileNav]
        
        configureTabBarAppearance()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.backgroundColor = .bettingSurfaceBackground
        
        appearance.stackedLayoutAppearance.selected.iconColor = .bettingAccent
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.bettingAccent
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = .bettingTextMuted
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.bettingTextMuted
        ]
        
        rootViewController.tabBar.standardAppearance = appearance
        rootViewController.tabBar.scrollEdgeAppearance = appearance
    }

    private func configureNavigationBarAppearance(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.backgroundColor = .bettingSurfaceBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.bettingTextPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.bettingTextPrimary]
        
        navigationController.navigationBar.tintColor = .bettingAccent
        
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
    }
}
