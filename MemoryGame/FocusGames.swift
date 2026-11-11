import SwiftUI

// MARK: - Pattern glance (letters on a grid)

struct PatternGame: View {
    let level: Double
    let onFinish: (GameResult) -> Void

    @State private var size = 3
    @State private var solution: [Int: String] = [:]
    @State private var placed: [Int: String] = [:]
    @State private var tray: [String] = []
    @State private var selected: String? = nil
    private enum Phase { case study, recall, review }
    @State private var phase: Phase = .study

    var body: some View {
        Group {
            switch phase {
            case .study:
                GameScreen(
                    eyebrow: t("Musterblick · Merken", "Pattern glance · Memorize"),
                    title: t("Wo stehen die Buchstaben?", "Where are the letters?"),
                    subtitle: t("Präg dir das Muster ein.", "Memorize the pattern.")
                ) {
                    grid(showing: solution, interactive: false)
                } footer: {
                    PrimaryButton(title: t("Gemerkt", "Got it")) { phase = .recall }
                }
            case .recall:
                GameScreen(
                    eyebrow: t("Musterblick · Abrufen", "Pattern glance · Recall"),
                    title: t("Setz die Buchstaben zurück.", "Put the letters back."),
                    subtitle: t("Buchstaben wählen, dann das Feld antippen.", "Pick a letter, then tap its field.")
                ) {
                    VStack(spacing: 18) {
                        grid(showing: placed, interactive: true)
                        HStack(spacing: 8) {
                            ForEach(tray, id: \.self) { letter in
                                let used = placed.values.contains(letter)
                                Button { selected = letter } label: {
                                    Text(letter)
                                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(selected == letter ? Theme.accent : Theme.card)
                                        .foregroundStyle(selected == letter ? Color.white : Theme.ink)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .opacity(used ? 0.35 : 1)
                                }
                                .buttonStyle(.plain)
                                .disabled(used)
                            }
                        }
                    }
                } footer: {
                    PrimaryButton(title: t("Fertig", "Done"), enabled: !placed.isEmpty) { phase = .review }
                }
            case .review:
                GameScreen(
                    eyebrow: t("Musterblick · Ergebnis", "Pattern glance · Result"),
                    title: t("\(correct) von \(solution.count) richtig.", "\(correct) of \(solution.count) right."),
                    subtitle: t("So war das Muster:", "This was the pattern:")
                ) {
                    grid(showing: solution, interactive: false, compare: true)
                } footer: {
                    PrimaryButton(title: t("Weiter", "Continue")) {
                        onFinish(GameResult(kind: .pattern, score: correct, max: solution.count))
                    }
                }
            }
        }
        .onAppear { if solution.isEmpty { setup() } }
    }

    private var correct: Int { solution.filter { placed[$0.key] == $0.value }.count }

    private func setup() {
        size = level < 5 ? 3 : 4
        let count = min(8, max(3, 3 + Int(level / 2)))
        let letters = Array("ABCDEFGHKLMNPRSTUVWZ").map(String.init).shuffled().prefix(count)
        let cells = Array(0..<(size * size)).shuffled().prefix(count)
        var map: [Int: String] = [:]
        for (cell, letter) in zip(cells, letters) { map[cell] = letter }
        solution = map
        tray = letters.shuffled()
    }

    private func grid(showing: [Int: String], interactive: Bool, compare: Bool = false) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: size)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<(size * size), id: \.self) { cell in
                let letter = showing[cell]
                let hit = compare && letter != nil && placed[cell] == letter
                let cellView = Text(letter ?? " ")
                    .font(.system(size: size == 3 ? 34 : 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(hit ? Theme.tint : Theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(compare && letter != nil ? (hit ? Theme.accent : Theme.warn) : Theme.line, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                if interactive {
                    Button {
                        if placed[cell] != nil {
                            placed[cell] = nil
                        } else if let s = selected {
                            placed[cell] = s
                            selected = nil
                        }
                    } label: { cellView }
                    .buttonStyle(.plain)
                } else {
                    cellView
                }
            }
        }
    }
}

// MARK: - Zigzag (1, A, 2, B …)

struct ZigzagGame: View {
    let level: Double
    let onFinish: (GameResult) -> Void

    private struct Token: Identifiable {
        let id: Int
        let label: String
        let cell: Int
        let dx: CGFloat
        let dy: CGFloat
    }

    @State private var tokens: [Token] = []
    @State private var next = 0
    @State private var errors = 0
    @State private var wrongID: Int? = nil
    @State private var start = Date()
    @State private var seconds = 0
    private let cols = 4

    var body: some View {
        let finished = !tokens.isEmpty && next >= tokens.count
        return GameScreen(
            eyebrow: t("Zickzack", "Zigzag"),
            title: finished
                ? t("Geschafft in \(seconds) Sekunden.", "Done in \(seconds) seconds.")
                : t("Tippe abwechselnd: 1, A, 2, B …", "Tap in turns: 1, A, 2, B …"),
            subtitle: finished
                ? (errors == 0 ? t("Ohne Fehler.", "No mistakes.") : t("\(errors) Fehltipps.", "\(errors) wrong taps."))
                : t("Immer Zahl, dann Buchstabe, der Reihe nach.", "Always a number, then a letter, in order.")
        ) {
            GeometryReader { geo in
                let rows = Int(ceil(Double(tokens.count) / Double(cols)))
                let cw = geo.size.width / CGFloat(cols)
                let ch = geo.size.height / CGFloat(max(rows, 1))
                ForEach(tokens) { token in
                    let done = token.id < next
                    Button { tap(token) } label: {
                        Text(token.label)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .frame(width: 54, height: 54)
                            .background(done ? Theme.accent : Theme.card)
                            .foregroundStyle(done ? Color.white : Theme.ink)
                            .overlay(Circle().stroke(wrongID == token.id ? Theme.warn : Theme.line, lineWidth: wrongID == token.id ? 3 : 1.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: (CGFloat(token.cell % cols) + 0.5) * cw + token.dx * (cw - 58) / 2,
                        y: (CGFloat(token.cell / cols) + 0.5) * ch + token.dy * (ch - 58) / 2
                    )
                }
            }
            .frame(height: 440)
        } footer: {
            PrimaryButton(title: t("Weiter", "Continue"), enabled: finished) {
                onFinish(GameResult(kind: .zigzag, score: max(0, tokens.count - errors), max: tokens.count))
            }
        }
        .onAppear { if tokens.isEmpty { setup() } }
    }

    private func setup() {
        let pairs = min(10, max(4, 4 + Int(level)))
        let letters = Array("ABCDEFGHIJ").map(String.init)
        var labels: [String] = []
        for i in 0..<pairs {
            labels.append("\(i + 1)")
            labels.append(letters[i])
        }
        let rows = Int(ceil(Double(labels.count) / Double(cols)))
        let cells = Array(0..<(rows * cols)).shuffled()
        tokens = labels.enumerated().map { i, label in
            Token(id: i, label: label, cell: cells[i], dx: CGFloat.random(in: -0.8...0.8), dy: CGFloat.random(in: -0.8...0.8))
        }
        next = 0
        errors = 0
        start = Date()
    }

    private func tap(_ token: Token) {
        guard next < tokens.count, token.id >= next else { return }
        if token.id == next {
            next += 1
            wrongID = nil
            if next >= tokens.count { seconds = Int(Date().timeIntervalSince(start).rounded()) }
        } else {
            errors += 1
            wrongID = token.id
        }
    }
}

// MARK: - Mirror image (find the flipped shape)

struct GridShape: Equatable {
    var cells: [[Int]]   // list of [x, y]
    let size: Int

    /// Moves the shape to the top left and sorts it, so equal shapes compare equal.
    func normalized() -> GridShape {
        let minX = cells.map { $0[0] }.min() ?? 0
        let minY = cells.map { $0[1] }.min() ?? 0
        let shifted: [[Int]] = cells.map { (c: [Int]) -> [Int] in [c[0] - minX, c[1] - minY] }
        let moved: [[Int]] = shifted.sorted { (a: [Int], b: [Int]) -> Bool in
            a[1] == b[1] ? a[0] < b[0] : a[1] < b[1]
        }
        return GridShape(cells: moved, size: size)
    }

    func rotated() -> GridShape {
        GridShape(cells: cells.map { [size - 1 - $0[1], $0[0]] }, size: size).normalized()
    }

    func mirrored() -> GridShape {
        GridShape(cells: cells.map { [size - 1 - $0[0], $0[1]] }, size: size).normalized()
    }

    var rotations: [GridShape] {
        var list = [normalized()]
        for _ in 0..<3 { list.append(list[list.count - 1].rotated()) }
        return list
    }

    /// A shape whose mirror image cannot be reached by turning it.
    static func randomChiral(size: Int, count: Int) -> GridShape {
        for _ in 0..<500 {
            var cells: [[Int]] = [[Int.random(in: 0..<size), Int.random(in: 0..<size)]]
            var guardCount = 0
            while cells.count < count && guardCount < 200 {
                guardCount += 1
                let base = cells.randomElement() ?? [0, 0]
                let step = [[1, 0], [-1, 0], [0, 1], [0, -1]].randomElement() ?? [1, 0]
                let cand = [base[0] + step[0], base[1] + step[1]]
                if cand[0] >= 0, cand[0] < size, cand[1] >= 0, cand[1] < size, !cells.contains(cand) {
                    cells.append(cand)
                }
            }
            let shape = GridShape(cells: cells, size: size).normalized()
            if cells.count == count && !shape.rotations.contains(shape.mirrored()) { return shape }
        }
        return GridShape(cells: [[0, 0], [0, 1], [0, 2], [1, 2]], size: size).normalized()
    }
}

struct ShapeTile: View {
    let shape: GridShape
    var color: Color = Theme.accent

    var body: some View {
        Canvas { ctx, canvasSize in
            let n = CGFloat(shape.size)
            let unit = canvasSize.width / (n + 1)
            let maxX = CGFloat(shape.cells.map { $0[0] }.max() ?? 0) + 1
            let maxY = CGFloat(shape.cells.map { $0[1] }.max() ?? 0) + 1
            let ox = (canvasSize.width - maxX * unit) / 2
            let oy = (canvasSize.height - maxY * unit) / 2
            for cell in shape.cells {
                let r = CGRect(x: ox + CGFloat(cell[0]) * unit + 1.5, y: oy + CGFloat(cell[1]) * unit + 1.5,
                               width: unit - 3, height: unit - 3)
                ctx.fill(Path(roundedRect: r, cornerRadius: unit * 0.18), with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct MirrorGame: View {
    let level: Double
    let onFinish: (GameResult) -> Void

    private let rounds = 5
    @State private var round = 0
    @State private var original: GridShape? = nil
    @State private var options: [GridShape] = []
    @State private var oddIndex = 0
    @State private var chosen: Int? = nil
    @State private var correct = 0

    private let two = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        GameScreen(
            eyebrow: t("Spiegelbild · \(round + 1) von \(rounds)", "Mirror image · \(round + 1) of \(rounds)"),
            title: t("Welche Form ist gespiegelt?", "Which shape is flipped?"),
            subtitle: t("Drei sind nur gedreht. Eine passt nicht.", "Three are only turned. One does not fit.")
        ) {
            VStack(spacing: 16) {
                if let original {
                    HStack(spacing: 14) {
                        ShapeTile(shape: original, color: Theme.ink)
                            .frame(width: 96, height: 96)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        Text(t("Vorlage", "Original")).font(Theme.body(17, .semibold)).foregroundStyle(Theme.sub)
                        Spacer()
                    }
                }
                LazyVGrid(columns: two, spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { i, shape in
                        let reveal = chosen != nil
                        let isOdd = i == oddIndex
                        Button {
                            if chosen == nil {
                                chosen = i
                                if isOdd { correct += 1 }
                            }
                        } label: {
                            ShapeTile(shape: shape)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(reveal && isOdd ? Theme.tint : Theme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(reveal && isOdd ? Theme.accent : (chosen == i ? Theme.warn : Theme.line), lineWidth: reveal && (isOdd || chosen == i) ? 3 : 1.5)
                                )
                                .overlay(alignment: .topTrailing) {
                                    if reveal && isOdd {
                                        Image(systemName: "checkmark.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.accent).padding(8)
                                    } else if reveal && chosen == i {
                                        Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundStyle(Theme.warn).padding(8)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(t("Form \(i + 1)", "Shape \(i + 1)"))
                    }
                }
            }
        } footer: {
            PrimaryButton(title: t("Weiter", "Next"), enabled: chosen != nil) {
                if round + 1 < rounds {
                    round += 1
                    newRound()
                } else {
                    onFinish(GameResult(kind: .mirror, score: correct, max: rounds))
                }
            }
        }
        .onAppear { if original == nil { newRound() } }
    }

    private func newRound() {
        let size = level < 5 ? 3 : 4
        let count = min(7, max(4, 4 + Int(level / 3)))
        let shape = GridShape.randomChiral(size: size, count: count)
        let turns = shape.rotations
        let flipped = shape.mirrored().rotations.randomElement() ?? shape.mirrored()
        var list = [turns[1], turns[2], turns[3]].shuffled()
        let odd = Int.random(in: 0...3)
        list.insert(flipped, at: odd)
        original = shape
        options = list
        oddIndex = odd
        chosen = nil
    }
}
