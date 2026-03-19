//
//  BetInputSheet.swift
//  ApuestaTotal_challenge
//

import SwiftUI

struct BetInputSheet: View {
    let match: MatchModel
    let pick: HomeBetPick
    let validationMessage: String?
    let onConfirm: (Double) -> Void
    let onCancel: () -> Void

    @State private var stakeText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private var selectionName: String {
        switch pick {
        case .home: return match.homeTeam.name
        case .draw: return "Empate"
        case .away: return match.awayTeam.name
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Nueva apuesta")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(BettingColors.textPrimary)

                    Text("Ingresa el monto para \(selectionName) en:")
                        .font(.subheadline)
                        .foregroundStyle(BettingColors.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("\(match.homeTeam.shortName) vs \(match.awayTeam.shortName)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BettingColors.accent)
                }
                .padding(.top, 20)

                // Currency input
                HStack(spacing: 8) {
                    Text("S/")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(BettingColors.accent)

                    TextField("0.00", text: $stakeText)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(BettingColors.textPrimary)
                        .focused($isTextFieldFocused)
                }
                .padding()
                .background(BettingColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BettingColors.accent.opacity(0.5), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 24)

                // Validation error
                if let errorMsg = validationMessage {
                    Text(errorMsg)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BettingColors.loss)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Confirm button
                Button {
                    isTextFieldFocused = false
                    let sanitized = stakeText.replacingOccurrences(of: ",", with: ".")
                    let stake = Double(sanitized) ?? 0
                    onConfirm(stake)
                } label: {
                    Text("Confirmar")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BettingColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(BettingColors.surfaceBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        onCancel()
                    }
                    .foregroundStyle(BettingColors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { isTextFieldFocused = true }
    }
}
