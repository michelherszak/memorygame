import SwiftUI

// MARK: - Shopping list

struct ShoppingGame: View {
    let level: Double
    var hint: String? = nil
    let onFinish: (GameResult) -> Void

    @Environment(AppState.self) private var state
    private enum Phase { case study, distract, recall, review }
    @State private var phase: Phase = .study
    @State private var items: [String] = []
    @State private var options: [String] = []
    @State private var picked: Set<String> = []
    @State private var step = 3
    @State private var chain: [Int] = []
    @State private var entry = ""
    @State private var wrongEntry = false

    private let two = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        Group {
            switch phase {
            case .study: study
            case .distract: distract
            case .recall: recall
            case .review: review
            }
        }
        .onAppear { if items.isEmpty { setup() } }
    }

    private func setup() {
        let n = min(12, max(5, 4 + Int(level)))
        let all = state.fresh(pool: Content.shopping, key: "shopping." + Lang.code, count: n * 2)
        items = Array(all.prefix(n))
        options = all.shuffled()
        step = level < 4 ? 3 : (level < 7 ? 6 : 7)
        chain = [Int.random(in: 60...99)]
    }

    private var study: some View {
        GameScreen(
            eyebrow: t("Einkaufsliste · Merken", "Shopping list · Memorize"),
            title: t("Merk dir diese \(items.count) Dinge.", "Remember these \(items.count) things."),
            subtitle: t("Nimm dir so viel Zeit, wie du brauchst.", "Take as much time as you need.")
        ) {
            VStack(spacing: 16) {
                LazyVGrid(columns: two, spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(Theme.body(19, .semibold))
                            .foregroundStyle(Theme.ink)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .frame(height: 58)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                if let hint { Note(text: hint) }
            }
        } footer: {
            PrimaryButton(title: t("Ich hab sie mir gemerkt", "I've got them")) { phase = .distract }
        }
    }

    private var distract: some View {
        GameScreen(
            eyebrow: t("Kurze Ablenkung", "Short distraction"),
            title: t("Zähl in \(step)er-Schritten rückwärts.", "Count backwards in steps of \(step)."),
            subtitle: t("Danach fragen wir die Liste ab.", "After that we ask for the list.")
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(chain, id: \.self) { n in
                        Text("\(n)")
                            .font(Theme.body(20, .semibold))
                            .foregroundStyle(Theme.sub)
                            .frame(minWidth: 44, minHeight: 44)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Text(entry.isEmpty ? " " : entry)
                        .font(Theme.body(20, .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(minWidth: 44, minHeight: 44)
                        .background(Theme.card)
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.accent, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                if wrongEntry {
                    Text(t("Nicht ganz. Versuch es noch einmal.", "Not quite. Try again."))
                        .font(Theme.body(16, .semibold))
                        .foregroundStyle(Theme.warn)
                }
            }
        } footer: {
            Keypad(okTitle: "OK") { d in
                if entry.count < 2 { entry += "\(d)" }
                wrongEntry = false
            } onDelete: {
                if !entry.isEmpty { entry.removeLast() }
            } onOK: {
                guard let value = Int(entry), let last = chain.last else { return }
                if value == last - step {
                    chain.append(value)
                    entry = ""
                    if chain.count >= 5 { phase = .recall }
                } else {
                    wrongEntry = true
                    entry = ""
                }
            }
        }
    }

    private var recall: some View {
        GameScreen(
            eyebrow: t("Einkaufsliste · Abrufen", "Shopping list · Recall"),
            title: t("Was stand auf der Liste?", "What was on the list?"),
            subtitle: t("Tippe alles an, was dazugehört. \(picked.count) von \(items.count) gewählt.",
                        "Tap everything that belongs. \(picked.count) of \(items.count) chosen.")
        ) {
            LazyVGrid(columns: two, spacing: 10) {
                ForEach(options, id: \.self) { item in
                    let on = picked.contains(item)
                    Button {
                        if on { picked.remove(item) } else { picked.insert(item) }
                    } label: {
                        Text(item)
                            .font(Theme.body(18, .semibold))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(on ? Theme.accent : Theme.card)
                            .foregroundStyle(on ? Color.white : Theme.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        } footer: {
            PrimaryButton(title: t("Fertig", "Done"), enabled: !picked.isEmpty) { phase = .review }
        }
    }

    private var hits: Int { picked.filter { items.contains($0) }.count }
    private var falseAlarms: Int { picked.count - hits }

    private var review: some View {
        GameScreen(
            eyebrow: t("Einkaufsliste · Ergebnis", "Shopping list · Result"),
            title: t("\(hits) von \(items.count) gemerkt.", "\(hits) of \(items.count) remembered."),
            subtitle: falseAlarms > 0
                ? t("\(falseAlarms) davon standen nicht auf der Liste.", "\(falseAlarms) of your picks were not on the list.")
                : nil
        ) {
            LazyVGrid(columns: two, spacing: 10) {
                ForEach(options, id: \.self) { item in
                    let onList = items.contains(item)
                    let chosen = picked.contains(item)
                    HStack(spacing: 6) {
                        if onList || chosen {
                            Image(systemName: onList ? (chosen ? "checkmark.circle.fill" : "circle.dashed") : "xmark.circle.fill")
                                .foregroundStyle(onList ? Theme.accent : Theme.warn)
                        }
                        Text(item)
                            .font(Theme.body(17, .semibold))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .foregroundStyle(onList || chosen ? Theme.ink : Theme.sub.opacity(0.6))
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 52)
                    .background(onList ? Theme.tint : Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        } footer: {
            PrimaryButton(title: t("Weiter", "Continue")) {
                onFinish(GameResult(kind: .shopping, score: max(0, hits - falseAlarms), max: items.count))
            }
        }
    }
}

// MARK: - Names & faces

struct FacesGame: View {
    let level: Double
    let onFinish: (GameResult) -> Void

    @Environment(AppState.self) private var state

    private struct Person: Identifiable {
        let id = UUID()
        let face: FaceSpec
        let name: String
        var options: [String] = []
    }

    @State private var people: [Person] = []
    @State private var quiz: [Person] = []
    @State private var index = 0
    @State private var studying = true
    @State private var chosen: String? = nil
    @State private var correct = 0

    var body: some View {
        Group {
            if people.isEmpty {
                Theme.bg
            } else if studying {
                study(people[index])
            } else {
                question(quiz[index])
            }
        }
        .onAppear { if people.isEmpty { setup() } }
    }

    private func setup() {
        let count = min(6, max(3, 3 + Int(level / 3)))
        let withLast = level >= 4
        let firsts = state.fresh(pool: Content.firstNames, key: "first." + Lang.code, count: count)
        let lasts = Array(Content.lastNames.shuffled().prefix(count))
        var faces: [FaceSpec] = []
        while faces.count < count {
            var f = FaceSpec.random()
            if Content.femaleFirstNames.contains(firsts[faces.count]) {
                f.beard = false
            } else if f.hair == .bun {
                f.hair = .short
            }
            if !faces.contains(f) { faces.append(f) }
        }
        var built: [Person] = []
        for i in 0..<count {
            let name = withLast ? "\(firsts[i]) \(lasts[i])" : firsts[i]
            built.append(Person(face: faces[i], name: name))
        }
        let allNames = built.map(\.name)
        for i in built.indices {
            var lures: [String] = []
            let first = firsts[i]
            let similar = Content.firstNames.filter { $0.first == first.first && $0 != first }.shuffled()
            let pool = similar + Content.firstNames.shuffled()
            for candidate in pool where lures.count < 3 {
                let lure = withLast ? "\(candidate) \(Content.lastNames.randomElement() ?? "")" : candidate
                if candidate != first && !lures.contains(lure) && !allNames.contains(lure) { lures.append(lure) }
            }
            built[i].options = ([built[i].name] + lures).shuffled()
        }
        people = built
        quiz = built.shuffled()
    }

    private func study(_ p: Person) -> some View {
        GameScreen(
            eyebrow: t("Namen & Gesichter · \(index + 1) von \(people.count)", "Names & faces · \(index + 1) of \(people.count)"),
            title: p.name,
            subtitle: t("Präg dir Gesicht und Namen ein.", "Memorize the face and the name.")
        ) {
            VStack(spacing: 16) {
                FaceView(spec: p.face).frame(width: 220, height: 220).frame(maxWidth: .infinity)
                Note(text: t("Auffällig: \(p.face.features). Verbinde das mit dem Namen.",
                             "Stands out: \(p.face.features). Link that to the name."))
            }
        } footer: {
            PrimaryButton(title: t("Weiter", "Next")) {
                if index + 1 < people.count {
                    index += 1
                } else {
                    index = 0
                    studying = false
                }
            }
        }
    }

    private func question(_ p: Person) -> some View {
        GameScreen(
            eyebrow: t("Namen & Gesichter · \(index + 1) von \(quiz.count)", "Names & faces · \(index + 1) of \(quiz.count)"),
            title: t("Wer ist das?", "Who is this?")
        ) {
            VStack(spacing: 16) {
                FaceView(spec: p.face).frame(width: 170, height: 170).frame(maxWidth: .infinity)
                VStack(spacing: 10) {
                    ForEach(p.options, id: \.self) { option in
                        let isRight = option == p.name
                        let isChosen = option == chosen
                        Button {
                            if chosen == nil {
                                chosen = option
                                if isRight { correct += 1 }
                            }
                        } label: {
                            HStack {
                                Text(option).font(Theme.body(19, .semibold))
                                Spacer()
                                if chosen != nil && isRight {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.accent)
                                } else if isChosen {
                                    Image(systemName: "xmark.circle.fill").foregroundStyle(Theme.warn)
                                }
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 58)
                            .foregroundStyle(Theme.ink)
                            .background(chosen != nil && isRight ? Theme.tint : Theme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(chosen != nil && isRight ? Theme.accent : (isChosen ? Theme.warn : Theme.line), lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } footer: {
            PrimaryButton(title: t("Weiter", "Next"), enabled: chosen != nil) {
                if index + 1 < quiz.count {
                    index += 1
                    chosen = nil
                } else {
                    onFinish(GameResult(kind: .faces, score: correct, max: quiz.count))
                }
            }
        }
    }
}

// MARK: - Number code

struct CodeGame: View {
    let level: Double
    let onFinish: (GameResult) -> Void

    private let rounds = 3
    @State private var round = 0
    @State private var code: [Int] = []
    @State private var entry: [Int] = []
    @State private var showing = true
    @State private var checked = false
    @State private var score = 0
    @State private var total = 0

    private var length: Int { min(12, max(4, 4 + Int(level * 0.8))) }

    var body: some View {
        Group {
            if showing { show } else { type }
        }
        .onAppear { if code.isEmpty { newCode() } }
    }

    private func newCode() {
        var digits: [Int] = []
        while digits.count < length {
            let d = Int.random(in: 0...9)
            if digits.last != d { digits.append(d) }
        }
        code = digits
        entry = []
        showing = true
        checked = false
    }

    /// Splits digits into groups of three or four, the way chunking teaches it.
    private func groups(_ digits: [Int]) -> [[Int]] {
        var result: [[Int]] = []
        var rest = digits
        while !rest.isEmpty {
            let size = (rest.count == 4 || rest.count == 8 || rest.count % 3 == 1) ? 4 : 3
            result.append(Array(rest.prefix(size)))
            rest.removeFirst(min(size, rest.count))
        }
        return result
    }

    private var show: some View {
        GameScreen(
            eyebrow: t("Zahlencode · \(round + 1) von \(rounds)", "Number code · \(round + 1) of \(rounds)"),
            title: t("Merk dir diese Zahl.", "Remember this number."),
            subtitle: t("Sie ist schon in Päckchen geteilt.", "It is already split into packs.")
        ) {
            HStack(spacing: 10) {
                ForEach(Array(groups(code).enumerated()), id: \.offset) { _, group in
                    Text(group.map(String.init).joined())
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Theme.ink)
                        .padding(.horizontal, 12)
                        .frame(height: 64)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity)
        } footer: {
            PrimaryButton(title: t("Gemerkt", "Got it")) { showing = false }
        }
    }

    private var matches: Int {
        zip(code, entry).filter { $0 == $1 }.count
    }

    private var type: some View {
        GameScreen(
            eyebrow: t("Zahlencode · \(round + 1) von \(rounds)", "Number code · \(round + 1) of \(rounds)"),
            title: checked
                ? t("\(matches) von \(code.count) Ziffern richtig.", "\(matches) of \(code.count) digits right.")
                : t("Wie lautete die Zahl?", "What was the number?")
        ) {
            VStack(alignment: .leading, spacing: 12) {
                digitRow(entry, compare: checked)
                if checked {
                    Text(t("Richtig war:", "Correct was:")).font(Theme.body(15, .semibold)).foregroundStyle(Theme.sub)
                    digitRow(code, compare: false)
                }
            }
        } footer: {
            if checked {
                PrimaryButton(title: t("Weiter", "Continue")) {
                    if round + 1 < rounds {
                        round += 1
                        newCode()
                    } else {
                        onFinish(GameResult(kind: .code, score: score, max: total))
                    }
                }
            } else {
                Keypad(okTitle: "OK") { d in
                    if entry.count < code.count { entry.append(d) }
                } onDelete: {
                    if !entry.isEmpty { entry.removeLast() }
                } onOK: {
                    guard !entry.isEmpty else { return }
                    score += matches
                    total += code.count
                    checked = true
                }
            }
        }
    }

    private func digitRow(_ digits: [Int], compare: Bool) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 6)
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<code.count, id: \.self) { i in
                let filled = i < digits.count
                let right = filled && digits[i] == code[i]
                Text(filled ? "\(digits[i])" : " ")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(compare && filled ? (right ? Theme.tint : Theme.card) : Theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(compare && filled && !right ? Theme.warn : Theme.line, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
