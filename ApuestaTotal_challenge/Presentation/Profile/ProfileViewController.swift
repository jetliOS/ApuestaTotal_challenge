//
//  ProfileViewController.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 17/03/26.
//

import UIKit
import SwiftUI

final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModelProtocol
    var onBetSelected: ((BetModel) -> Void)?

    private lazy var hostingController = UIHostingController(
        rootView: makeProfileView(bets: [])
    )

    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Perfil"
        setupHostingController()
        loadProfileData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileData()
    }
}

private extension ProfileViewController {
    func setupHostingController() {
        view.backgroundColor = .bettingSurfaceBackground

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    func loadProfileData() {
        switch viewModel.loadProfileScreen() {
        case .success(let screenModel):
            hostingController.rootView = makeProfileView(
                bets: screenModel.bets
            )
        case .failure(let error):
            hostingController.rootView = makeProfileView(bets: [])
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    func makeProfileView(bets: [BetModel]) -> ProfileView {
        ProfileView(bets: bets) { [weak self] bet in
            self?.onBetSelected?(bet)
        }
    }
}
