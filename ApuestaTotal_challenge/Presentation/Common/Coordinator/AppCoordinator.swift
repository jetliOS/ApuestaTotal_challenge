//
//  AppCoordinator.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import UIKit
import SwiftData

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private var childCoordinators: [Coordinator] = []
    private let modelContainer: ModelContainer

    init(window: UIWindow) {
        self.window = window
        self.modelContainer = AppCoordinator.makeModelContainer()
    }

    func start() {
        applyDarkMode()
        
        let mainCoordinator = MainCoordinator(modelContainer: modelContainer)
        childCoordinators = [mainCoordinator]
        mainCoordinator.start()

        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()
    }
    
    private func applyDarkMode() {
        if #available(iOS 13.0, *) {
            window.overrideUserInterfaceStyle = .dark
        }
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([BetEntity.self])

        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            do {
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: fallbackConfig)
            } catch {
                fatalError("Unable to initialize ModelContainer: \(error.localizedDescription)")
            }
        }
    }
}
