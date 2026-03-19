//
//  HomeViewController.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 17/03/26.
//

import UIKit
import SwiftUI
import Combine

final class HomeViewController: UIViewController {

    private let viewModel: any HomeViewModelProtocol
    private let input = PassthroughSubject<HomeViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    var onBetDetailRequested: ((String) -> Void)?

    private lazy var hostingController = UIHostingController(
        rootView: makeHomeView()
    )

    init(viewModel: any HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio"
        setupHostingController()
        bindViewModel()
        input.send(.onAppear)
    }
}

// MARK: - Hosting Setup
private extension HomeViewController {
    func setupHostingController() {
        view.backgroundColor = .systemBackground

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
}

// MARK: - ViewModel Binding
private extension HomeViewController {
    func bindViewModel() {
        // Bind output events (match loading errors)
        viewModel.executeEvent(from: input.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .empty:
                    self?.showAlert(title: "Aviso", message: "No se encontraron partidos.")
                case .error(let message):
                    self?.showAlert(title: "Error", message: message)
                case .matches:
                    break
                }
            }
            .store(in: &cancellables)

        // Observe sections changes
        viewModel.sectionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)

        // Observe bet flow state changes
        viewModel.betFlowStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateView()
            }
            .store(in: &cancellables)
    }

    func updateView() {
        hostingController.rootView = makeHomeView()
    }

    func makeHomeView() -> HomeView {
        let state = HomeViewState(
            sections: viewModel.sections,
            betFlowState: viewModel.betFlowState,
            hasExistingBet: { [weak viewModel] matchId in
                viewModel?.hasExistingBet(for: matchId) ?? false
            }
        )

        let actions = HomeViewActions(
            onBetSelected: { [weak viewModel] match, pick in
                viewModel?.handleBetSelection(match: match, pick: pick)
            },
            onConfirmBet: { [weak viewModel] stake in
                viewModel?.confirmBet(stake: stake)
            },
            onDismissBetFlow: { [weak viewModel] in
                viewModel?.dismissBetFlow()
            },
            onBetDetailRequested: { [weak self] betId in
                self?.onBetDetailRequested?(betId)
            }
        )

        return HomeView(state: state, actions: actions)
    }
}
