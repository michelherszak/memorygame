import SwiftUI

@main
struct MemoryGameApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(state)
                .id(state.langCode)
                .preferredColorScheme(.light)
                .tint(Theme.accent)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label(t("Heute", "Today"), systemImage: "sun.max") }
            LibraryView()
                .tabItem { Label(t("Training", "Training"), systemImage: "square.grid.2x2") }
            ProgressScreen()
                .tabItem { Label(t("Fortschritt", "Progress"), systemImage: "chart.bar") }
        }
    }
}

/// Shows the right game for a kind. The level is read once when the game starts.
struct GameHost: View {
    let kind: GameKind
    var hint: String? = nil
    let onFinish: (GameResult) -> Void

    @Environment(AppState.self) private var state
    @State private var level: Double? = nil

    var body: some View {
        Group {
            if let level {
                switch kind {
                case .shopping: ShoppingGame(level: level, hint: hint, onFinish: onFinish)
                case .faces: FacesGame(level: level, onFinish: onFinish)
                case .pattern: PatternGame(level: level, onFinish: onFinish)
                case .code: CodeGame(level: level, onFinish: onFinish)
                case .zigzag: ZigzagGame(level: level, onFinish: onFinish)
                case .mirror: MirrorGame(level: level, onFinish: onFinish)
                }
            } else {
                Theme.bg.ignoresSafeArea()
            }
        }
        .onAppear { if level == nil { level = state.level(kind) } }
    }
}
