//
//  ProductDetailView.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 19/03/26.
//

import SwiftUI

struct ProductDetailView: View {
    let bet: BetModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                statusHeader
                matchInfoSection
                betDetailsSection
                if bet.homeScore != nil && bet.awayScore != nil {
                    matchResultSection
                }
                financialSection
                metadataSection
            }
            .padding(.vertical, 20)
        }
        .background(BettingColors.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Detalle de Apuesta")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var statusHeader: some View {
        VStack(spacing: 12) {
            statusIcon
                .font(.system(size: 60))
                .foregroundStyle(statusColor)
            
            Text(statusText)
                .font(.title2.weight(.bold))
                .foregroundStyle(BettingColors.textPrimary)
            
            if let returnAmount = bet.return {
                Text(returnAmount > 0 ? "+S/ \(String(format: "%.2f", returnAmount))" : "S/ 0.00")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(BettingColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [statusColor.opacity(0.2), statusColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(statusColor.opacity(0.4), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 16)
    }
    
    private var matchInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Partido", icon: "sportscourt")
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Local")
                            .font(.caption)
                            .foregroundStyle(BettingColors.textSecondary)
                        Text(bet.homeTeamName ?? "Equipo Local")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BettingColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("VS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BettingColors.accent)
                        .padding(8)
                        .background(BettingColors.accent.opacity(0.1))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Visitante")
                            .font(.caption)
                            .foregroundStyle(BettingColors.textSecondary)
                        Text(bet.awayTeamName ?? "Equipo Visitante")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(BettingColors.textPrimary)
                    }
                }
                
                if let competition = bet.competition {
                    Divider()
                    
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(BettingColors.oddHighlight)
                        Text(competition)
                            .font(.subheadline)
                            .foregroundStyle(BettingColors.textPrimary)
                        Spacer()
                    }
                }
                
                if let matchDate = bet.matchDate {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(BettingColors.accent)
                        Text(matchDate)
                            .font(.subheadline)
                            .foregroundStyle(BettingColors.textPrimary)
                        Spacer()
                    }
                }
            }
            .padding(16)
            .cardStyle()
        }
        .padding(.horizontal, 16)
    }
    
    private var betDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Tu Apuesta", icon: "ticket")
            
            VStack(spacing: 12) {
                DetailRow(
                    label: "Tipo de apuesta",
                    value: bet.betType ?? "1X2",
                    icon: "list.bullet"
                )
                
                Divider()
                
                DetailRow(
                    label: "Tu selección",
                    value: selectionText,
                    icon: "hand.point.up.left",
                    valueColor: BettingColors.selection
                )
                
                Divider()
                
                DetailRow(
                    label: "Cuota",
                    value: String(format: "%.2f", bet.odd),
                    icon: "chart.line.uptrend.xyaxis",
                    valueColor: BettingColors.oddHighlight
                )
            }
            .padding(16)
            .cardStyle()
        }
        .padding(.horizontal, 16)
    }
    
    private var matchResultSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Resultado Final", icon: "flag.checkered")
            
            HStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text(bet.homeTeamName ?? "Local")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BettingColors.textSecondary)
                    Text("\(bet.homeScore ?? 0)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(BettingColors.textPrimary)
                        .padding(12)
                        .background(BettingColors.primary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text("-")
                    .font(.title.weight(.bold))
                    .foregroundStyle(BettingColors.accent)
                
                VStack(spacing: 8) {
                    Text(bet.awayTeamName ?? "Visitante")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BettingColors.textSecondary)
                    Text("\(bet.awayScore ?? 0)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(BettingColors.textPrimary)
                        .padding(12)
                        .background(BettingColors.primary.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
            }
            .padding(.vertical, 24)
            .cardStyle(borderColor: statusColor)
        }
        .padding(.horizontal, 16)
    }
    
    private var financialSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Resumen Financiero", icon: "dollarsign.circle")
            
            VStack(spacing: 12) {
                DetailRow(
                    label: "Monto apostado",
                    value: "S/ \(String(format: "%.2f", bet.stake))",
                    icon: "banknote"
                )
                
                Divider()
                
                if let returnAmount = bet.return {
                    DetailRow(
                        label: "Ganancia potencial",
                        value: "S/ \(String(format: "%.2f", returnAmount))",
                        icon: "arrow.up.circle.fill",
                        valueColor: returnAmount > 0 ? BettingColors.win : BettingColors.textSecondary
                    )
                }
            }
            .padding(16)
            .cardStyle(borderColor: BettingColors.win)
        }
        .padding(.horizontal, 16)
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Información Adicional", icon: "info.circle")
            
            VStack(spacing: 12) {
                DetailRow(
                    label: "Fecha de creación",
                    value: formatDate(bet.createdAt),
                    icon: "clock"
                )
                Divider()
                DetailRow(
                    label: "Estado",
                    value: bet.status,
                    icon: "checkmark.seal",
                    valueColor: statusColor
                )
            }
            .padding(16)
            .cardStyle()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helpers
    
    private var statusIcon: Image {
        switch bet.status.uppercased() {
        case "WON":
            return Image(systemName: "checkmark.circle.fill")
        case "LOST":
            return Image(systemName: "xmark.circle.fill")
        case "PENDING":
            return Image(systemName: "clock.fill")
        default:
            return Image(systemName: "questionmark.circle.fill")
        }
    }
    
    private var statusColor: Color {
        switch bet.status.uppercased() {
        case "WON":
            return BettingColors.win
        case "LOST":
            return BettingColors.loss
        case "PENDING":
            return BettingColors.pending
        default:
            return BettingColors.textMuted
        }
    }
    
    private var statusText: String {
        switch bet.status.uppercased() {
        case "WON":
            return "¡Apuesta Ganada!"
        case "LOST":
            return "Apuesta Perdida"
        case "PENDING":
            return "Apuesta Pendiente"
        default:
            return bet.status
        }
    }
    
    private var selectionText: String {
        switch bet.pick.uppercased() {
        case "HOME":
            return "\(bet.homeTeamName ?? "Local") gana"
        case "DRAW":
            return "Empate"
        case "AWAY":
            return "\(bet.awayTeamName ?? "Visitante") gana"
        default:
            return bet.pick
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

private struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(BettingColors.accent)
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(BettingColors.textPrimary)
            Spacer()
        }
    }
}

// Card modifier for consistent styling
extension View {
    func cardStyle(borderColor: Color = BettingColors.primary) -> some View {
        self
            .background(BettingColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(borderColor.opacity(0.3), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = BettingColors.textPrimary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(BettingColors.textSecondary)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(BettingColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(valueColor)
        }
    }
}

// MARK: - Preview

#Preview("Apuesta Ganada") {
    NavigationStack {
        ProductDetailView(
            bet: BetModel(
                id: "BET001",
                matchId: "MATCH123",
                homeTeamName: "Manchester United",
                awayTeamName: "Liverpool",
                placedAt: "2026-03-19T14:30:00Z",
                pick: "HOME",
                odd: 2.50,
                stake: 50.0,
                status: "WON",
                return: 125.0,
                competition: "Premier League",
                matchDate: "2026-03-20 15:00",
                homeScore: 2,
                awayScore: 1,
                betType: "1X2",
                createdAt: Date()
            )
        )
    }
}

#Preview("Apuesta Perdida") {
    NavigationStack {
        ProductDetailView(
            bet: BetModel(
                id: "BET002",
                matchId: "MATCH124",
                homeTeamName: "Barcelona",
                awayTeamName: "Real Madrid",
                placedAt: "2026-03-18T18:00:00Z",
                pick: "AWAY",
                odd: 3.20,
                stake: 30.0,
                status: "LOST",
                return: 0.0,
                competition: "La Liga",
                matchDate: "2026-03-19 20:00",
                homeScore: 2,
                awayScore: 2,
                betType: "1X2",
                createdAt: Date()
            )
        )
    }
}

#Preview("Apuesta Pendiente") {
    NavigationStack {
        ProductDetailView(
            bet: BetModel(
                id: "BET003",
                matchId: "MATCH125",
                homeTeamName: "Bayern Munich",
                awayTeamName: "Borussia Dortmund",
                placedAt: "2026-03-19T10:00:00Z",
                pick: "DRAW",
                odd: 3.50,
                stake: 20.0,
                status: "PENDING",
                return: 70.0,
                competition: "Bundesliga",
                matchDate: "2026-03-21 16:30",
                betType: "1X2",
                createdAt: Date()
            )
        )
    }
}
