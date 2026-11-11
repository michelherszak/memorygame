import SwiftUI

// MARK: - Today

struct HomeView: View {
    @Environment(AppState.self) private var state
    @State private var showSession = false
    private let plan = DailyPlan.today()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: Lang.code))))
                        .font(Theme.body(16))
                        .foregroundStyle(Theme.sub)
                    Spacer()
                    if state.streak > 0 {
                        Text(t("\(state.streak) Tage in Folge", "\(state.streak) days in a row"))
                            .font(Theme.body(15, .semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.tint)
                            .clipShape(Capsule())
                    }
                }
                Text(state.doneToday
                     ? t("Für heute geschafft.\nBis morgen.", "Done for today.\nSee you tomorrow.")
                     : t("Guten Tag.\nDeine 5 Minuten für heute.", "Hello.\nYour 5 minutes for today."))
                    .font(Theme.title(34))
                    .foregroundStyle(Theme.ink)
                    .padding(.top, 14)

                Card(padding: 22) {
                    VStack(alignment: .leading, spacing: 16) {
                        Eyebrow(text: t("Heutige Einheit · ca. 5 Min.", "Today's session · about 5 min"), color: Theme.sub)
                        stepRow(1, plan.technique.title, t("Technik lernen, 30 Sek.", "Learn a technique, 30 sec"), strong: true)
                        stepRow(2, plan.games[0].title, t("Technik gleich anwenden", "Use the technique right away"))
                        stepRow(3, plan.games[1].title, plan.games[1].subtitle)
                        PrimaryButton(title: state.doneToday ? t("Noch einmal spielen", "Play again") : t("Einheit starten", "Start session")) {
                            showSession = true
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.top, 26)

                Text(t("Jeden Tag neue Inhalte. Nichts wiederholt sich.", "New content every day. Nothing repeats."))
                    .font(Theme.body(15))
                    .foregroundStyle(Theme.sub)
                    .padding(.top, 16)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .background(Theme.bg)
        .fullScreenCover(isPresented: $showSession) {
            SessionView(plan: plan)
        }
    }

    private func stepRow(_ n: Int, _ title: String, _ sub: String, strong: Bool = false) -> some View {
        HStack(spacing: 14) {
            Text("\(n)")
                .font(Theme.body(17, .semibold))
                .frame(width: 36, height: 36)
                .background(strong ? Theme.accent : Theme.tint)
                .foregroundStyle(strong ? Color.white : Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.body(18, .semibold)).foregroundStyle(Theme.ink)
                Text(sub).font(Theme.body(15)).foregroundStyle(Theme.sub)
            }
        }
    }
}

// MARK: - Daily session

struct SessionView: View {
    let plan: DailyPlan
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var step = 0
    @State private var results: [GameResult] = []

    var body: some View {
        VStack(spacing: 0) {
            if step < 3 {
                HStack(spacing: 16) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 44, height: 44)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .accessibilityLabel(t("Einheit schließen", "Close session"))
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            Capsule()
                                .fill(i < step ? Theme.accent : (i == step ? Theme.accentSoft : Theme.line))
                                .frame(height: 6)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }

            switch step {
            case 0:
                TechniqueView(technique: plan.technique, buttonTitle: t("Jetzt ausprobieren", "Try it now")) {
                    state.markLearned(plan.technique.id)
                    step = 1
                }
            case 1:
                GameHost(kind: plan.games[0], hint: hint) { finish($0) }.id(1)
            case 2:
                GameHost(kind: plan.games[1]) { finish($0) }.id(2)
            default:
                SummaryView(results: results, technique: plan.technique) { dismiss() }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private var hint: String {
        t("Nutze heute: \(plan.technique.title).", "Use today: \(plan.technique.title).")
    }

    private func finish(_ result: GameResult) {
        results.append(state.record(result))
        step += 1
        if step == 3 { state.completeToday() }
    }
}

struct TechniqueView: View {
    let technique: Technique
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        GameScreen(
            eyebrow: t("Technik des Tages", "Technique of the day"),
            title: technique.title,
            subtitle: technique.body
        ) {
            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Eyebrow(text: t("Beispiel", "Example"), color: Theme.sub)
                    HStack(spacing: 8) {
                        ForEach(technique.exampleParts, id: \.self) { part in
                            Text(part)
                                .font(Theme.body(16, .semibold))
                                .foregroundStyle(Theme.accent)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Theme.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    Text("„\(technique.example)“")
                        .font(Theme.body(18).italic())
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(technique.tip)
                        .font(Theme.body(15))
                        .foregroundStyle(Theme.sub)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } footer: {
            PrimaryButton(title: buttonTitle, action: action)
        }
    }
}

struct SummaryView: View {
    let results: [GameResult]
    var technique: Technique? = nil
    let action: () -> Void
    @Environment(AppState.self) private var state

    var body: some View {
        GameScreen(
            eyebrow: t("Einheit abgeschlossen", "Session complete"),
            title: t("Geschafft.", "Well done.")
        ) {
            VStack(spacing: 16) {
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(results) { r in
                            HStack {
                                Text(r.kind.title).font(Theme.body(18, .semibold)).foregroundStyle(Theme.ink)
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(t("\(r.score) von \(r.max)", "\(r.score) of \(r.max)"))
                                        .font(Theme.body(18, .semibold)).foregroundStyle(Theme.ink)
                                    if r.isBest {
                                        Text(t("Persönlicher Bestwert", "Personal best"))
                                            .font(Theme.body(14, .semibold)).foregroundStyle(Theme.accent)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            Divider().overlay(Theme.line)
                        }
                        if let technique {
                            HStack {
                                Text(t("Technik", "Technique")).font(Theme.body(18, .semibold)).foregroundStyle(Theme.ink)
                                Spacer()
                                Text(technique.title).font(Theme.body(16)).foregroundStyle(Theme.sub)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t("\(state.streak) Tage in Folge", "\(state.streak) days in a row"))
                            .font(Theme.body(18, .semibold)).foregroundStyle(Theme.ink)
                        WeekDots()
                        Text(t("Ein Ruhetag pro Woche bricht die Serie nicht.", "One rest day a week does not break the streak."))
                            .font(Theme.body(15)).foregroundStyle(Theme.sub)
                    }
                }
                Text(t("Morgen gibt es neue Inhalte und eine andere Technik.", "Tomorrow brings new content and a different technique."))
                    .font(Theme.body(16)).foregroundStyle(Theme.sub)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } footer: {
            PrimaryButton(title: t("Zur Übersicht", "Back to overview"), action: action)
        }
    }
}

struct WeekDots: View {
    @Environment(AppState.self) private var state

    var body: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let days: [Date] = (0..<7).reversed().compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
        return HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                VStack(spacing: 6) {
                    Text(day.formatted(.dateTime.weekday(.short).locale(Locale(identifier: Lang.code))))
                        .font(Theme.body(13))
                        .foregroundStyle(Theme.sub)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(state.isDone(day) ? (day == today ? Theme.accent : Theme.accentSoft) : Theme.line)
                        .frame(height: 30)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Training (free play)

struct LibraryView: View {
    @Environment(AppState.self) private var state
    @State private var playing: GameKind? = nil
    @State private var reading: Technique? = nil
    private let two = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(t("Training", "Training")).font(Theme.title(34)).foregroundStyle(Theme.ink)

                Eyebrow(text: t("Techniken", "Techniques"), color: Theme.sub).padding(.top, 22).padding(.bottom, 10)
                LazyVGrid(columns: two, spacing: 10) {
                    ForEach(Technique.all) { tech in
                        let learned = state.hasLearned(tech.id)
                        Button { reading = tech } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(tech.title)
                                    .font(Theme.body(16, .semibold))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                Text(learned ? t("Gelernt", "Learned") : tech.useFor)
                                    .font(Theme.body(13, .medium))
                                    .opacity(0.8)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
                            .background(learned ? Theme.accent : Theme.card)
                            .foregroundStyle(learned ? Color.white : Theme.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Eyebrow(text: t("Spiele", "Games"), color: Theme.sub).padding(.top, 22).padding(.bottom, 10)
                Card(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(GameKind.allCases) { kind in
                            Button { playing = kind } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(kind.title).font(Theme.body(17, .semibold)).foregroundStyle(Theme.ink)
                                        Text(kind.subtitle).font(Theme.body(14)).foregroundStyle(Theme.sub)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.sub)
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 13)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if kind != GameKind.allCases.last { Divider().overlay(Theme.line).padding(.leading, 18) }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
        .fullScreenCover(item: $playing) { kind in
            FreePlayView(kind: kind)
        }
        .sheet(item: $reading) { tech in
            TechniqueView(technique: tech, buttonTitle: t("Schließen", "Close")) {
                state.markLearned(tech.id)
                reading = nil
            }
            .padding(.top, 12)
            .background(Theme.bg)
        }
    }
}

struct FreePlayView: View {
    let kind: GameKind
    @Environment(AppState.self) private var state
    @Environment(\.dismiss) private var dismiss
    @State private var result: GameResult? = nil
    @State private var run = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 44, height: 44)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .accessibilityLabel(t("Schließen", "Close"))
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            if let result {
                GameScreen(
                    eyebrow: kind.title,
                    title: t("\(result.score) von \(result.max) \(kind.unit).", "\(result.score) of \(result.max) \(kind.unit)."),
                    subtitle: result.isBest
                        ? t("Das ist dein persönlicher Bestwert.", "That is your personal best.")
                        : t("Dein Bestwert: \(state.best(kind)).", "Your best: \(state.best(kind)).")
                ) {
                    Note(text: t("Die nächste Runde hat neue Inhalte.", "The next round has new content."), icon: "sparkles")
                } footer: {
                    VStack(spacing: 10) {
                        PrimaryButton(title: t("Noch eine Runde", "One more round")) {
                            self.result = nil
                            run += 1
                        }
                        Button(t("Fertig", "Done")) { dismiss() }
                            .font(Theme.body(17, .semibold))
                            .frame(height: 44)
                    }
                }
            } else {
                GameHost(kind: kind) { r in
                    result = state.record(r)
                }
                .id(run)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

// MARK: - Progress

struct ProgressScreen: View {
    @Environment(AppState.self) private var state

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(t("Fortschritt", "Progress")).font(Theme.title(34)).foregroundStyle(Theme.ink)

                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t("\(state.streak) Tage in Folge", "\(state.streak) days in a row"))
                            .font(Theme.body(20, .semibold)).foregroundStyle(Theme.ink)
                        WeekDots()
                        Text(t("\(state.data.days.count) Einheiten insgesamt", "\(state.data.days.count) sessions in total"))
                            .font(Theme.body(15)).foregroundStyle(Theme.sub)
                    }
                }

                Card(padding: 0) {
                    VStack(spacing: 0) {
                        Eyebrow(text: t("Persönliche Bestwerte", "Personal bests"), color: Theme.sub)
                            .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 6)
                        ForEach(GameKind.allCases) { kind in
                            HStack {
                                Text(kind.title).font(Theme.body(17, .semibold)).foregroundStyle(Theme.ink)
                                Spacer()
                                Text(state.best(kind) > 0 ? "\(state.best(kind)) \(kind.unit)" : "–")
                                    .font(Theme.body(17)).foregroundStyle(Theme.sub)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 13)
                        }
                    }
                    .padding(.bottom, 6)
                }

                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t("Sprache", "Language")).font(Theme.body(17, .semibold)).foregroundStyle(Theme.ink)
                        Picker(t("Sprache", "Language"), selection: Binding(
                            get: { state.langCode },
                            set: { state.setLanguage($0) }
                        )) {
                            Text("Deutsch").tag("de")
                            Text("English").tag("en")
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Text(t("Tägliches Üben, das Spaß machen soll. Kein medizinisches Produkt.",
                       "Daily practice that is meant to be fun. Not a medical product."))
                    .font(Theme.body(14)).foregroundStyle(Theme.sub)
                    .padding(.horizontal, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
        .background(Theme.bg)
    }
}
