//
//  BetOverlays.swift
//  ApuestaTotal_challenge
//

import SwiftUI

// MARK: - Loading Overlay

struct BetLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(BettingColors.accent)

                Text("Procesando apuesta")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(BettingColors.textPrimary)
            }
            .padding(32)
            .background(BettingColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }
}

// MARK: - Result Overlay

struct BetResultOverlay: View {
    let message: String
    let onViewDetail: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { onClose() }

            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(BettingColors.win)

                Text("Apuesta Realizada")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(BettingColors.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(BettingColors.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button {
                        onViewDetail()
                    } label: {
                        Text("Ver Detalle")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(BettingColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Button {
                        onClose()
                    } label: {
                        Text("Cerrar")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BettingColors.textSecondary)
                    }
                }
            }
            .padding(24)
            .background(BettingColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(BettingColors.win.opacity(0.3), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20)
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Error Overlay

struct BetErrorOverlay: View {
    let title: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 16) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(BettingColors.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(BettingColors.textSecondary)
                    .multilineTextAlignment(.center)

                Button {
                    onDismiss()
                } label: {
                    Text("OK")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BettingColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(24)
            .background(BettingColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20)
            .padding(.horizontal, 32)
        }
    }
}
