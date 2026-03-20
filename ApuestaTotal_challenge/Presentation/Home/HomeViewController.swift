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

    private let viewModel: HomeViewModelProtocol
    private let input = PassthroughSubject<HomeViewModelInput, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var matches: [MatchModel] = []
    var onBetDetailRequested: ((String) -> Void)?
    private lazy var hostingController = UIHostingController(
        rootView: makeHomeView(sections: [])
    )

    init(viewModel: HomeViewModelProtocol) {
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
        eventListener()
        input.send(.onAppear)
    }
}

// MARK: Combine
private extension HomeViewController {
    func eventListener() {
        viewModel.executeEvent(from: input.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .matches(let matches):
                    self.matches = matches
                    self.renderMatches()
                case .empty:
                    self.matches = []
                    self.renderMatches()
                    self.showAlert(title: "Aviso", message: "No se encontraron partidos.")
                case .betPlaced(let message, let betId):
                    self.dismiss(animated: true) {
                        self.showBetPlacedAlert(message: message, betId: betId)
                    }
                case .error(let message):
                    self.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: message)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func renderMatches() {
        hostingController.rootView = makeHomeView(sections: buildSections(from: matches))
    }
}

// MARK: SwiftUI Hosting
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

    func makeHomeView(sections: [HomeMatchSection]) -> HomeView {
        HomeView(
            sections: sections,
            hasExistingBet: { [weak self] matchId in
                return self?.viewModel.hasExistingBet(for: matchId) ?? false
            },
            onBetSelected: { [weak self] match, pick in
                self?.handleBetSelection(match: match, pick: pick)
            }
        )
    }

    func buildSections(from matches: [MatchModel]) -> [HomeMatchSection] {
        // Agrupar partidos por hora
        let groupedMatches = Dictionary(grouping: matches, by: hourTitle(for:))
        
        let formatter = ISO8601DateFormatter()

        return groupedMatches
            .map { title, matches in
                HomeMatchSection(
                    id: title,
                    title: title,
                    matches: matches.sorted { $0.startTime < $1.startTime }
                )
            }
            .sorted { lhs, rhs in
                // Ordenar por la fecha real del primer partido de cada sección
                guard let lhsMatch = lhs.matches.first,
                      let rhsMatch = rhs.matches.first,
                      let lhsDate = formatter.date(from: lhsMatch.startTime),
                      let rhsDate = formatter.date(from: rhsMatch.startTime) else {
                    // Fallback: ordenar por título si no se puede parsear
                    return lhs.title < rhs.title
                }
                return lhsDate < rhsDate
            }
    }

    func hourTitle(for match: MatchModel) -> String {
        let formatter = ISO8601DateFormatter()

        guard let date = formatter.date(from: match.startTime) else {
            return match.startTime
        }

        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "es_PE")
        hourFormatter.dateFormat = "HH:mm"
        return hourFormatter.string(from: date)
    }

    func handleBetSelection(match: MatchModel, pick: HomeBetPick) {
        // Verificar si ya existe una apuesta para este partido
        if viewModel.hasExistingBet(for: match.id) {
            showAlert(
                title: "Ya apostaste",
                message: "Ya tienes una apuesta activa en este partido.\nNo puedes hacer múltiples apuestas en el mismo partido."
            )
            return
        }
        
        // Determinar el nombre de la selección
        let selectionName: String
        switch pick {
        case .home:
            selectionName = match.homeTeam.name
        case .draw:
            selectionName = "Empate"
        case .away:
            selectionName = match.awayTeam.name
        }
        
        let alertController = UIAlertController(
            title: "Nueva apuesta",
            message: "\nIngresa el monto para \(selectionName) en:\n\(match.homeTeam.shortName) vs \(match.awayTeam.shortName)\n",
            preferredStyle: .alert
        )

        // TextField personalizado con S/
        alertController.addTextField { textField in
            textField.placeholder = "0.00"
            textField.keyboardType = .decimalPad
            textField.textAlignment = .right
            textField.font = .systemFont(ofSize: 20, weight: .semibold)
            textField.textColor = .bettingAccent
            
            // Agregar el prefijo S/ a la izquierda
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
            let label = UILabel(frame: CGRect(x: 8, y: 0, width: 37, height: 30))
            label.text = "S/"
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textColor = .bettingAccent
            paddingView.addSubview(label)
            textField.leftView = paddingView
            textField.leftViewMode = .always
            
            // Toolbar con botón "Listo"
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(
                title: "Listo",
                style: .done,
                target: textField,
                action: #selector(textField.resignFirstResponder)
            )
            doneButton.tintColor = .bettingAccent
            toolbar.items = [flexSpace, doneButton]
            toolbar.barTintColor = .bettingSurfaceBackground
            textField.inputAccessoryView = toolbar
        }

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .default) { [weak self, weak alertController] _ in
            guard let self = self else { return }
            
            // Validar y obtener el valor
            guard
                let textField = alertController?.textFields?.first,
                let text = textField.text,
                !text.isEmpty,
                let stake = Double(text.replacingOccurrences(of: ",", with: ".")),
                stake > 0
            else {
                self.showAlert(title: "⚠️ Error", message: "Por favor ingresa un monto válido mayor a S/ 0.00")
                return
            }
            
            // Validar monto mínimo
            if stake < 1.0 {
                self.showAlert(title: "⚠️ Monto mínimo", message: "El monto mínimo de apuesta es S/ 1.00")
                return
            }
            
            // Mostrar spinner de carga y procesar
            self.showLoadingAndPlaceBet(match: match, pick: pick, stake: stake)
        }
        
        alertController.addAction(confirmAction)
        alertController.preferredAction = confirmAction

        present(alertController, animated: true)
    }
    
    private func showLoadingAndPlaceBet(match: MatchModel, pick: HomeBetPick, stake: Double) {
        // Alert de loading simple
        let loadingAlert = UIAlertController(
            title: "Procesando apuesta",
            message: "\n\n\n",
            preferredStyle: .alert
        )
        
        // Agregar spinner
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = CGPoint(
            x: loadingAlert.view.bounds.midX,
            y: loadingAlert.view.bounds.midY
        )
        spinner.color = .bettingAccent
        spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        spinner.startAnimating()
        loadingAlert.view.addSubview(spinner)
        
        present(loadingAlert, animated: true) { [weak self] in
            // Ejecutar la apuesta después de mostrar el loading
            self?.viewModel.placeBet(match: match, pick: pick, stake: stake)
        }
    }
    
    func showBetPlacedAlert(message: String, betId: String) {
        let alert = UIAlertController(
            title: "Apuesta Realizada",
            message: message,
            preferredStyle: .alert
        )
        
        // Botón para ver detalle
        alert.addAction(UIAlertAction(title: "Ver Detalle", style: .default) { [weak self] _ in
            self?.onBetDetailRequested?(betId)
        })
        
        // Botón para cerrar
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel))
        
        present(alert, animated: true)
    }
}
