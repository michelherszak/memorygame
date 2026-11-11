import SwiftUI
import Observation

// MARK: - Language

enum Lang {
    static var code: String {
        if let saved = UserDefaults.standard.string(forKey: "lang") { return saved }
        let sys = Locale.preferredLanguages.first ?? "en"
        return sys.hasPrefix("de") ? "de" : "en"
    }
    static var isGerman: Bool { code == "de" }
}

/// Picks the German or English text. All UI copy goes through this.
func t(_ de: String, _ en: String) -> String { Lang.isGerman ? de : en }

// MARK: - Theme

enum Theme {
    static let bg = Color(red: 0.961, green: 0.953, blue: 0.933)
    static let ink = Color(red: 0.110, green: 0.106, blue: 0.098)
    static let sub = Color(red: 0.360, green: 0.353, blue: 0.333)
    static let accent = Color(red: 0.122, green: 0.373, blue: 0.357)
    static let accentSoft = Color(red: 0.498, green: 0.663, blue: 0.647)
    static let tint = Color(red: 0.890, green: 0.933, blue: 0.925)
    static let card = Color.white
    static let line = Color(red: 0.902, green: 0.890, blue: 0.863)
    static let warn = Color(red: 0.706, green: 0.325, blue: 0.035)

    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .rounded) }
    static func body(_ size: CGFloat = 18, _ weight: Font.Weight = .regular) -> Font { .system(size: size, weight: weight) }
}

// MARK: - Games

enum GameKind: String, Codable, CaseIterable, Identifiable {
    case shopping, faces, pattern, code, zigzag, mirror
    var id: String { rawValue }

    var title: String {
        switch self {
        case .shopping: return t("Einkaufsliste", "Shopping list")
        case .faces: return t("Namen & Gesichter", "Names & faces")
        case .pattern: return t("Musterblick", "Pattern glance")
        case .code: return t("Zahlencode", "Number code")
        case .zigzag: return t("Zickzack", "Zigzag")
        case .mirror: return t("Spiegelbild", "Mirror image")
        }
    }

    var subtitle: String {
        switch self {
        case .shopping: return t("Dinge merken und abrufen", "Remember things and recall them")
        case .faces: return t("Wer war wer?", "Who was who?")
        case .pattern: return t("Wo standen die Buchstaben?", "Where were the letters?")
        case .code: return t("Zahlen im Kopf behalten", "Keep numbers in mind")
        case .zigzag: return t("1, A, 2, B … der Reihe nach", "1, A, 2, B … in order")
        case .mirror: return t("Welche Form ist gespiegelt?", "Which shape is flipped?")
        }
    }

    var unit: String {
        switch self {
        case .shopping: return t("Dinge", "items")
        case .faces: return t("Namen", "names")
        case .pattern: return t("Buchstaben", "letters")
        case .code: return t("Ziffern", "digits")
        case .zigzag: return t("Felder", "fields")
        case .mirror: return t("Formen", "shapes")
        }
    }
}

struct GameResult: Identifiable {
    let id = UUID()
    let kind: GameKind
    let score: Int
    let max: Int
    var isBest = false
    var ratio: Double { max == 0 ? 0 : Double(score) / Double(max) }
}

// MARK: - Saved state

struct SaveData: Codable {
    var levels: [String: Double] = [:]
    var bests: [String: Int] = [:]
    var days: [String] = []
    var learned: [String] = []
    var recent: [String: [String]] = [:]
}

@Observable
final class AppState {
    private(set) var data: SaveData
    var langCode: String

    init() {
        if let raw = UserDefaults.standard.data(forKey: "save.v1"),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: raw) {
            data = decoded
        } else {
            data = SaveData()
        }
        langCode = Lang.code
    }

    private func save() {
        if let raw = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(raw, forKey: "save.v1")
        }
    }

    func setLanguage(_ code: String) {
        UserDefaults.standard.set(code, forKey: "lang")
        langCode = code
    }

    // Difficulty: one hidden level per game, from 1 (easy) to 10 (hard).
    func level(_ kind: GameKind) -> Double { data.levels[kind.rawValue] ?? 2 }

    /// Stores a result, moves the hidden level, and reports whether it is a personal best.
    @discardableResult
    func record(_ result: GameResult) -> GameResult {
        var r = result
        var lvl = level(result.kind)
        if result.ratio >= 0.85 { lvl += 0.6 } else if result.ratio >= 0.6 { lvl += 0.1 } else { lvl -= 0.5 }
        data.levels[result.kind.rawValue] = Swift.min(10, Swift.max(1, lvl))
        let old = data.bests[result.kind.rawValue] ?? 0
        if result.score > old {
            data.bests[result.kind.rawValue] = result.score
            r.isBest = old > 0
        }
        save()
        return r
    }

    func best(_ kind: GameKind) -> Int { data.bests[kind.rawValue] ?? 0 }

    func markLearned(_ techniqueID: String) {
        if !data.learned.contains(techniqueID) {
            data.learned.append(techniqueID)
            save()
        }
    }

    func hasLearned(_ techniqueID: String) -> Bool { data.learned.contains(techniqueID) }

    /// Returns `count` entries from the pool that were not used recently, so content does not repeat.
    func fresh(pool: [String], key: String, count: Int) -> [String] {
        var recent = data.recent[key] ?? []
        var candidates = pool.filter { !recent.contains($0) }
        if candidates.count < count {
            recent = []
            candidates = pool
        }
        let chosen = Array(candidates.shuffled().prefix(count))
        recent.append(contentsOf: chosen)
        let cap = Swift.max(count, pool.count / 2)
        if recent.count > cap { recent.removeFirst(recent.count - cap) }
        data.recent[key] = recent
        save()
        return chosen
    }

    // MARK: Days and streak

    static func dayKey(_ date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var doneToday: Bool { data.days.contains(Self.dayKey(Date())) }

    func completeToday() {
        let key = Self.dayKey(Date())
        if !data.days.contains(key) {
            data.days.append(key)
            save()
        }
    }

    func isDone(_ date: Date) -> Bool { data.days.contains(Self.dayKey(date)) }

    /// Days in a row. One missed day per week does not break the streak.
    var streak: Int {
        let cal = Calendar.current
        let done = Set(data.days)
        var count = 0
        var sinceGrace = 7
        var day = cal.startOfDay(for: Date())
        if !done.contains(Self.dayKey(day)) {
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        for _ in 0..<3650 {
            if done.contains(Self.dayKey(day)) {
                count += 1
                sinceGrace += 1
            } else if sinceGrace >= 6 {
                let prev = cal.date(byAdding: .day, value: -1, to: day) ?? day
                if done.contains(Self.dayKey(prev)) { sinceGrace = 0 } else { break }
            } else {
                break
            }
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return count
    }
}

// MARK: - Daily plan

struct DailyPlan {
    let technique: Technique
    let games: [GameKind]

    static func today() -> DailyPlan {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let techniques = Technique.all
        let technique = techniques[day % techniques.count]
        let others = GameKind.allCases.filter { $0 != technique.game }
        let second = others[(day / techniques.count + day) % others.count]
        return DailyPlan(technique: technique, games: [technique.game, second])
    }
}
