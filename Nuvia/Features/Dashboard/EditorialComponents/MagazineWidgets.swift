import SwiftUI

// MARK: - Magazine Widget Cards
// Editorial-style widget cards for dashboard metrics

// MARK: - Budget Snapshot Widget

struct BudgetSnapshotWidget: View {
    let totalBudget: Double
    let spent: Double
    let currency: String

    @Environment(\.colorScheme) private var colorScheme

    private var remaining: Double {
        max(0, totalBudget - spent)
    }

    private var progress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(1, spent / totalBudget)
    }

    private var formattedSpent: String {
        formatCurrency(spent)
    }

    private var formattedTotal: String {
        formatCurrency(totalBudget)
    }

    private var formattedRemaining: String {
        formatCurrency(remaining)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(currency)\(Int(value))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.nuviaChampagne)

                Text(L10n.Budget.title)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)

                Spacer()

                Text(L10n.Common.seeAll)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaChampagne)
            }

            // Progress Ring
            HStack(spacing: DesignTokens.Spacing.lg) {
                // Ring
                ZStack {
                    Circle()
                        .stroke(
                            DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme),
                            lineWidth: 8
                        )

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.nuviaChampagne,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(MotionCurves.gentle, value: progress)

                    VStack(spacing: 2) {
                        Text("\(Int(progress * 100))%")
                            .font(NuviaTypography.bodyBold())
                            .foregroundColor(.nuviaPrimaryText)

                        Text("used")
                            .font(NuviaTypography.caption2())
                            .foregroundColor(.nuviaSecondaryText)
                    }
                }
                .frame(width: 80, height: 80)

                // Amounts
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Budget.spent)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                        Text(formattedSpent)
                            .font(NuviaTypography.headline())
                            .foregroundColor(.nuviaPrimaryText)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.Budget.remaining)
                            .font(NuviaTypography.caption())
                            .foregroundColor(.nuviaSecondaryText)
                        Text(formattedRemaining)
                            .font(NuviaTypography.headline())
                            .foregroundColor(.nuviaSage)
                    }
                }
            }

            // Total footer
            HStack {
                Text(L10n.Budget.totalBudget)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaTertiaryText)
                Spacer()
                Text(formattedTotal)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaTertiaryText)
            }
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(Color.nuviaSurface)
        .cornerRadius(DesignTokens.Radius.card)
        .etherealShadow(.soft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Budget: \(formattedSpent) spent of \(formattedTotal), \(formattedRemaining) remaining")
    }
}

// MARK: - RSVP Tally Widget

struct RSVPTallyWidget: View {
    let attending: Int
    let notAttending: Int
    let pending: Int

    @Environment(\.colorScheme) private var colorScheme

    private var total: Int {
        attending + notAttending + pending
    }

    private var attendingProgress: Double {
        guard total > 0 else { return 0 }
        return Double(attending) / Double(total)
    }

    private var respondedProgress: Double {
        guard total > 0 else { return 0 }
        return Double(attending + notAttending) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.nuviaSage)

                Text(L10n.Guests.title)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)

                Spacer()

                Text(L10n.Common.seeAll)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaChampagne)
            }

            // Main count
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.xs) {
                Text("\(attending)")
                    .font(NuviaTypography.largeNumber())
                    .foregroundColor(.nuviaPrimaryText)

                Text("/ \(total)")
                    .font(NuviaTypography.headline())
                    .foregroundColor(.nuviaSecondaryText)

                Spacer()
            }

            Text(L10n.Guests.attending)
                .font(NuviaTypography.caption())
                .foregroundColor(.nuviaSage)

            // Progress bars
            VStack(spacing: DesignTokens.Spacing.xs) {
                // Attending bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.progressBar)
                            .fill(DSColors.Adaptive.surfaceTertiary.resolve(for: colorScheme))

                        RoundedRectangle(cornerRadius: DesignTokens.Radius.progressBar)
                            .fill(Color.nuviaSage)
                            .frame(width: geo.size.width * attendingProgress)
                            .animation(MotionCurves.gentle, value: attendingProgress)
                    }
                }
                .frame(height: 6)

                // Status breakdown
                HStack(spacing: DesignTokens.Spacing.md) {
                    RSVPStatusBadge(count: attending, label: L10n.Guests.attending, color: .nuviaSage)
                    RSVPStatusBadge(count: notAttending, label: L10n.Guests.notAttending, color: .nuviaRoseDust)
                    RSVPStatusBadge(count: pending, label: L10n.Guests.pending, color: .nuviaTertiaryText)
                }
            }
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(Color.nuviaSurface)
        .cornerRadius(DesignTokens.Radius.card)
        .etherealShadow(.soft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("RSVP: \(attending) attending, \(notAttending) not attending, \(pending) pending out of \(total) guests")
    }
}

struct RSVPStatusBadge: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(NuviaTypography.bodyBold())
                .foregroundColor(.nuviaPrimaryText)

            Text(label)
                .font(NuviaTypography.caption2())
                .foregroundColor(color)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Next Milestone Widget

struct NextMilestoneWidget: View {
    let taskTitle: String
    let category: String
    let categoryColor: Color
    let dueDate: Date?

    @Environment(\.colorScheme) private var colorScheme

    private var dueDateText: String {
        guard let date = dueDate else { return "No due date" }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let taskDate = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: taskDate).day ?? 0

        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        if days < 7 { return "In \(days) days" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: "flag.fill")
                    .font(.system(size: 20))
                    .foregroundColor(categoryColor)
            }

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxxs) {
                Text(L10n.Dashboard.upcomingTasks)
                    .font(NuviaTypography.caption())
                    .foregroundColor(.nuviaSecondaryText)

                Text(taskTitle)
                    .font(NuviaTypography.headline())
                    .foregroundColor(.nuviaPrimaryText)
                    .lineLimit(1)

                HStack(spacing: DesignTokens.Spacing.xxs) {
                    Circle()
                        .fill(categoryColor)
                        .frame(width: 6, height: 6)

                    Text(category)
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaTertiaryText)

                    Text("•")
                        .foregroundColor(.nuviaTertiaryText)

                    Text(dueDateText)
                        .font(NuviaTypography.caption2())
                        .foregroundColor(.nuviaSecondaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.nuviaTertiaryText)
        }
        .padding(DesignTokens.Spacing.cardPadding)
        .background(Color.nuviaSurface)
        .cornerRadius(DesignTokens.Radius.card)
        .etherealShadow(.whisper)
    }
}

// MARK: - Weekly Brief Mini Widget

struct WeeklyBriefMiniWidget: View {
    let tasksCount: Int
    let paymentsCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.etherealGradient)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxxs) {
                    Text(L10n.WeeklyBrief.title)
                        .font(NuviaTypography.headline())
                        .foregroundColor(.nuviaPrimaryText)

                    Text("\(tasksCount) tasks • \(paymentsCount) payments")
                        .font(NuviaTypography.caption())
                        .foregroundColor(.nuviaSecondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.nuviaTertiaryText)
            }
            .padding(DesignTokens.Spacing.cardPadding)
            .background(
                LinearGradient(
                    colors: [
                        Color.nuviaChampagne.opacity(0.08),
                        Color.nuviaRoseDust.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(DesignTokens.Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.nuviaChampagne.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(DSButtonPressStyle(scale: 0.98))
    }
}

// MARK: - Preview

#Preview("Magazine Widgets") {
    ScrollView {
        VStack(spacing: 20) {
            BudgetSnapshotWidget(
                totalBudget: 50000,
                spent: 18500,
                currency: "₺"
            )

            RSVPTallyWidget(
                attending: 127,
                notAttending: 12,
                pending: 35
            )

            NextMilestoneWidget(
                taskTitle: "Confirm venue booking",
                category: "Venue",
                categoryColor: Color(hex: "B5A3C4"),
                dueDate: Date().addingTimeInterval(86400 * 3)
            )

            WeeklyBriefMiniWidget(
                tasksCount: 5,
                paymentsCount: 2
            ) {}
        }
        .padding(24)
    }
    .background(Color(hex: "FAFAF9"))
}
