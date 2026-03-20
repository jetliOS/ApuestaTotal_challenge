//
//  HomeView.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 18/03/26.
//

import SwiftUI

struct HomeView: View {
    let sections: [HomeMatchSection]
    let hasExistingBet: (String) -> Bool  // Nueva función
    let onBetSelected: (MatchModel, HomeBetPick) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BettingColors.textSecondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(section.matches, id: \.id) { match in
                                MatchCardView(
                                    match: match,
                                    hasExistingBet: hasExistingBet(match.id),
                                    onBetSelected: onBetSelected
                                )
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
}

struct HomeMatchSection: Identifiable {
    let id: String
    let title: String
    let matches: [MatchModel]
}

enum HomeBetPick: String {
    case home = "1"
    case draw = "X"
    case away = "2"
}

private struct MatchCardView: View {
    let match: MatchModel
    let hasExistingBet: Bool
    let onBetSelected: (MatchModel, HomeBetPick) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "sportscourt.fill")
                            .font(.caption)
                            .foregroundStyle(BettingColors.accent)
                        
                        Text(match.league.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BettingColors.textSecondary)
                    }

                    Text("\(match.homeTeam.name) vs \(match.awayTeam.name)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(BettingColors.textPrimary)
                }
                
                Spacer()
                
                if hasExistingBet {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Apostado")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(BettingColors.win)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(BettingColors.win.opacity(0.15))
                    .clipShape(Capsule())
                }
            }

            VStack(spacing: 6) {
                BetOptionButton(
                    title: match.homeTeam.name,
                    oddText: oddText(match.market.odds.home),
                    isDisabled: hasExistingBet
                ) {
                    onBetSelected(match, .home)
                }

                BetOptionButton(
                    title: "Empate",
                    oddText: oddText(match.market.odds.draw),
                    isDisabled: hasExistingBet
                ) {
                    onBetSelected(match, .draw)
                }

                BetOptionButton(
                    title: match.awayTeam.name,
                    oddText: oddText(match.market.odds.away),
                    isDisabled: hasExistingBet
                ) {
                    onBetSelected(match, .away)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BettingColors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(BettingColors.primary.opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: BettingColors.primary.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private func oddText(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

private struct BetOptionButton: View {
    let title: String
    let oddText: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isDisabled ? BettingColors.textMuted : BettingColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption2)
                        .foregroundStyle(isDisabled ? BettingColors.textMuted : BettingColors.oddHighlight)
                    
                    Text(oddText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(isDisabled ? BettingColors.textMuted : BettingColors.oddHighlight)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isDisabled ? BettingColors.textMuted.opacity(0.1) : BettingColors.oddHighlight.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isDisabled ? BettingColors.textMuted.opacity(0.1) : BettingColors.primary.opacity(0.3))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isDisabled ? BettingColors.textMuted.opacity(0.2) : BettingColors.accent.opacity(0.5), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}
