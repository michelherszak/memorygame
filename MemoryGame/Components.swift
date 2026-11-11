import SwiftUI

struct PrimaryButton: View {
    let title: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.body(19, .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(enabled ? Theme.accent : Theme.line)
                .foregroundStyle(enabled ? Color.white : Theme.sub)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct Eyebrow: View {
    let text: String
    var color: Color = Theme.accent
    var body: some View {
        Text(text.uppercased())
            .font(Theme.body(14, .semibold))
            .kerning(0.4)
            .foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Shared frame for every game step: small label, big question, content, one button at the bottom.
struct GameScreen<Content: View, Footer: View>: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var content: () -> Content
    @ViewBuilder var footer: () -> Footer

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Eyebrow(text: eyebrow)
                    Text(title)
                        .font(Theme.title(30))
                        .foregroundStyle(Theme.ink)
                        .padding(.top, 8)
                        .fixedSize(horizontal: false, vertical: true)
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.body(17))
                            .foregroundStyle(Theme.sub)
                            .padding(.top, 10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    content().padding(.top, 22)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .scrollBounceBehavior(.basedOnSize)
            footer()
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .background(Theme.bg)
    }
}

struct Card<Content: View>: View {
    var padding: CGFloat = 20
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct Keypad: View {
    let okTitle: String
    let onDigit: (Int) -> Void
    let onDelete: () -> Void
    let onOK: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(1...9, id: \.self) { n in key("\(n)") { onDigit(n) } }
            Button(action: onDelete) {
                Image(systemName: "delete.left")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Theme.line)
                    .foregroundStyle(Theme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(t("Löschen", "Delete"))
            key("0") { onDigit(0) }
            Button(action: onOK) {
                Text(okTitle)
                    .font(Theme.body(18, .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Theme.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func key(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 26, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Theme.card)
                .foregroundStyle(Theme.ink)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Small coloured note used for hints and feedback.
struct Note: View {
    let text: String
    var icon: String = "lightbulb"
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.accent)
            Text(text)
                .font(Theme.body(16))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.tint)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Generated faces

struct FaceSpec: Equatable {
    enum Hair: CaseIterable { case short, long, curly, bun, bald }
    var skin: Int
    var hairColor: Int
    var hair: Hair
    var glasses: Bool
    var beard: Bool
    var shirt: Int

    static func random() -> FaceSpec {
        let hair = Hair.allCases.randomElement() ?? .short
        return FaceSpec(
            skin: Int.random(in: 0..<5),
            hairColor: Int.random(in: 0..<6),
            hair: hair,
            glasses: Int.random(in: 0..<3) == 0,
            beard: (hair == .short || hair == .bald) && Int.random(in: 0..<3) == 0,
            shirt: Int.random(in: 0..<5)
        )
    }

    /// What stands out in this face, as words. Used for the hint and for VoiceOver.
    var features: String {
        var parts: [String] = []
        let colors = [t("schwarze", "black"), t("braune", "brown"), t("rotbraune", "auburn"),
                      t("blonde", "blond"), t("graue", "grey"), t("weiße", "white")]
        let c = colors[hairColor % colors.count]
        switch hair {
        case .short: parts.append(t("kurze \(c) Haare", "short \(c) hair"))
        case .long: parts.append(t("lange \(c) Haare", "long \(c) hair"))
        case .curly: parts.append(t("\(c) Locken", "\(c) curls"))
        case .bun: parts.append(t("\(c) Haare im Dutt", "\(c) hair in a bun"))
        case .bald: parts.append(t("Glatze", "bald head"))
        }
        if glasses { parts.append(t("runde Brille", "round glasses")) }
        if beard { parts.append(t("Bart", "beard")) }
        return parts.joined(separator: ", ")
    }
}

struct FaceView: View {
    let spec: FaceSpec

    private static let skins: [Color] = [
        Color(red: 0.98, green: 0.86, blue: 0.76), Color(red: 0.93, green: 0.76, blue: 0.62),
        Color(red: 0.82, green: 0.62, blue: 0.47), Color(red: 0.63, green: 0.44, blue: 0.32),
        Color(red: 0.42, green: 0.29, blue: 0.22)
    ]
    private static let hairs: [Color] = [
        Color(red: 0.13, green: 0.12, blue: 0.12), Color(red: 0.36, green: 0.24, blue: 0.16),
        Color(red: 0.60, green: 0.29, blue: 0.16), Color(red: 0.85, green: 0.70, blue: 0.38),
        Color(red: 0.62, green: 0.62, blue: 0.63), Color(red: 0.90, green: 0.89, blue: 0.87)
    ]
    private static let shirts: [Color] = [
        Theme.accent, Color(red: 0.78, green: 0.47, blue: 0.17), Color(red: 0.25, green: 0.33, blue: 0.55),
        Color(red: 0.55, green: 0.25, blue: 0.33), Color(red: 0.35, green: 0.36, blue: 0.38)
    ]

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / 120
            func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
                CGRect(x: x * s, y: y * s, width: w * s, height: h * s)
            }
            let skin = Self.skins[spec.skin % Self.skins.count]
            let hair = Self.hairs[spec.hairColor % Self.hairs.count]
            let shirt = Self.shirts[spec.shirt % Self.shirts.count]
            let ink = Color(red: 0.11, green: 0.106, blue: 0.098)

            // Hair behind the head
            switch spec.hair {
            case .long:
                ctx.fill(Path(roundedRect: rect(28, 20, 64, 84), cornerRadius: 28 * s), with: .color(hair))
            case .curly:
                for (x, y) in [(30, 34), (38, 22), (52, 16), (68, 16), (82, 22), (90, 34), (28, 50), (92, 50), (30, 64), (90, 64)] {
                    ctx.fill(Path(ellipseIn: rect(CGFloat(x) - 11, CGFloat(y) - 11, 22, 22)), with: .color(hair))
                }
            case .bun:
                ctx.fill(Path(ellipseIn: rect(48, 4, 24, 22)), with: .color(hair))
                ctx.fill(Path(ellipseIn: rect(32, 18, 56, 50)), with: .color(hair))
            case .short:
                ctx.fill(Path(ellipseIn: rect(32, 18, 56, 48)), with: .color(hair))
            case .bald:
                break
            }

            // Shirt, neck, head
            ctx.fill(Path(ellipseIn: rect(18, 92, 84, 64)), with: .color(shirt))
            ctx.fill(Path(roundedRect: rect(52, 80, 16, 20), cornerRadius: 6 * s), with: .color(skin))
            ctx.fill(Path(ellipseIn: rect(36, 28, 48, 60)), with: .color(skin))

            // Fringe
            if spec.hair == .short || spec.hair == .long || spec.hair == .bun {
                var fringe = Path()
                fringe.move(to: CGPoint(x: 36 * s, y: 52 * s))
                fringe.addQuadCurve(to: CGPoint(x: 60 * s, y: 24 * s), control: CGPoint(x: 36 * s, y: 26 * s))
                fringe.addQuadCurve(to: CGPoint(x: 84 * s, y: 52 * s), control: CGPoint(x: 84 * s, y: 26 * s))
                fringe.addQuadCurve(to: CGPoint(x: 36 * s, y: 52 * s), control: CGPoint(x: 60 * s, y: 34 * s))
                ctx.fill(fringe, with: .color(hair))
            }

            // Beard
            if spec.beard {
                var beard = Path()
                beard.move(to: CGPoint(x: 38 * s, y: 66 * s))
                beard.addQuadCurve(to: CGPoint(x: 82 * s, y: 66 * s), control: CGPoint(x: 60 * s, y: 76 * s))
                beard.addQuadCurve(to: CGPoint(x: 60 * s, y: 92 * s), control: CGPoint(x: 82 * s, y: 90 * s))
                beard.addQuadCurve(to: CGPoint(x: 38 * s, y: 66 * s), control: CGPoint(x: 38 * s, y: 90 * s))
                ctx.fill(beard, with: .color(hair))
            }

            // Eyes
            ctx.fill(Path(ellipseIn: rect(48, 55, 5, 5)), with: .color(ink))
            ctx.fill(Path(ellipseIn: rect(67, 55, 5, 5)), with: .color(ink))

            // Glasses
            if spec.glasses {
                let style = StrokeStyle(lineWidth: 2.2 * s)
                ctx.stroke(Path(ellipseIn: rect(42, 49, 16, 16)), with: .color(ink), style: style)
                ctx.stroke(Path(ellipseIn: rect(62, 49, 16, 16)), with: .color(ink), style: style)
                var bridge = Path()
                bridge.move(to: CGPoint(x: 58 * s, y: 57 * s))
                bridge.addLine(to: CGPoint(x: 62 * s, y: 57 * s))
                ctx.stroke(bridge, with: .color(ink), style: style)
            }

            // Mouth
            var mouth = Path()
            mouth.move(to: CGPoint(x: 53 * s, y: 74 * s))
            mouth.addQuadCurve(to: CGPoint(x: 67 * s, y: 74 * s), control: CGPoint(x: 60 * s, y: 80 * s))
            ctx.stroke(mouth, with: .color(spec.beard ? Color.white.opacity(0.9) : Color(red: 0.55, green: 0.23, blue: 0.18)),
                       style: StrokeStyle(lineWidth: 2.4 * s, lineCap: .round))
        }
        .aspectRatio(1, contentMode: .fit)
        .background(Theme.tint)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel(t("Porträt: \(spec.features)", "Portrait: \(spec.features)"))
    }
}
