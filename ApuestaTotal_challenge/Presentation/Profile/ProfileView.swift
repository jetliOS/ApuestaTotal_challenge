//
//  ProfileView.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import SwiftUI

struct ProfileView: View {
    let bets: [BetModel]
    let onBetSelected: (BetModel) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if bets.isEmpty {
                    emptyState
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Apuestas realizadas")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BettingColors.textPrimary)
                            .padding(.horizontal, 20)

                        LazyVStack(spacing: 12) {
                            ForEach(bets, id: \.id) { bet in
                                Button {
                                    onBetSelected(bet)
                                } label: {
                                    ProfileBetCardView(bet: bet)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(BettingColors.surfaceBackground.ignoresSafeArea())
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "ticket")
                .font(.system(size: 48))
                .foregroundStyle(BettingColors.textMuted)

            Text("Aún no hay apuestas")
                .font(.headline.weight(.bold))
                .foregroundStyle(BettingColors.textPrimary)

            Text("Tus apuestas simuladas aparecerán aquí.")
                .font(.subheadline)
                .foregroundStyle(BettingColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(BettingColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(BettingColors.primary.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
    }
}

private struct ProfileBetCardView: View {
    let bet: BetModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamNames)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(BettingColors.textPrimary)
                    
                    Text("ID: \(bet.id)")
                        .font(.caption2)
                        .foregroundStyle(BettingColors.textMuted)
                }
                Spacer()
                statusBadge
            }

            HStack(spacing: 8) {
                badge(title: selectionTitle, tint: BettingColors.selection, icon: "hand.point.up.left.fill")
                badge(title: "Cuota \(oddText)", tint: BettingColors.oddHighlight, icon: "chart.line.uptrend.xyaxis")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(BettingColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(statusColor.opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var teamNames: String {
        if let homeTeamName = bet.homeTeamName, let awayTeamName = bet.awayTeamName {
            return "\(homeTeamName) vs \(awayTeamName)"
        }
        return "Partido \(bet.matchId)"
    }

    private var selectionTitle: String {
        switch bet.pick.uppercased() {
        case "HOME":
            return "Local gana"
        case "DRAW":
            return "Empate"
        case "AWAY":
            return "Visitante gana"
        default:
            return bet.pick
        }
    }

    private var oddText: String {
        String(format: "%.2f", bet.odd)
    }

    private var statusColor: Color {
        switch bet.status.uppercased() {
        case "WON":
            return BettingColors.win
        case "LOST":
            return BettingColors.loss
        default:
            return BettingColors.pending
        }
    }
    
    private var statusIcon: String {
        switch bet.status.uppercased() {
        case "WON":
            return "checkmark.circle.fill"
        case "LOST":
            return "xmark.circle.fill"
        default:
            return "clock.fill"
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption)
            Text(bet.status.uppercased())
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.15))
        .clipShape(Capsule())
    }

    private func badge(title: String, tint: Color, icon: String? = nil) -> some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.15))
        .clipShape(Capsule())
    }
}
