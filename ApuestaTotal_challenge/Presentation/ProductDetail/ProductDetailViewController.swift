//
//  ProductDetailViewController.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import UIKit
import SwiftUI
import Combine

final class ProductDetailViewController: UIViewController {
    private let viewModel: ProductDetailViewModelProtocol
    private let betId: String
    private let input = PassthroughSubject<ProductDetailViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentBet: BetModel?
    
    init(viewModel: ProductDetailViewModelProtocol, betId: String) {
        self.viewModel = viewModel
        self.betId = betId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bettingSurfaceBackground
        setupBindings()
        input.send(.onAppear(betId: betId))
    }
    
    private func setupBindings() {
        viewModel
            .executeEvent(from: input.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                self?.handleOutput(output)
            }
            .store(in: &cancellables)
    }
    
    private func handleOutput(_ output: ProductDetailViewModelOutput) {
        switch output {
        case .bet(let bet):
            currentBet = bet
            showBetDetail(bet)
            
        case .notFound:
            showAlert(title: "Error", message: "No se encontró la apuesta")
            navigationController?.popViewController(animated: true)
            
        case .error(let message):
            showAlert(title: "Error", message: message)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func showBetDetail(_ bet: BetModel) {
        let detailView = ProductDetailView(bet: bet)
        let hostingController = UIHostingController(rootView: detailView)
        
        hostingController.navigationItem.largeTitleDisplayMode = .never
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
}
