import SwiftUI

/// Represents all NYC subway lines with their official MTA colors
enum SubwayLine: String, CaseIterable, Identifiable {
    // IRT Broadway-Seventh Avenue Line (Red)
    case one = "1"
    case two = "2"
    case three = "3"

    // IRT Lexington Avenue Line (Green)
    case four = "4"
    case five = "5"
    case six = "6"
    case sixExpress = "6X"

    // IRT Flushing Line (Purple)
    case seven = "7"
    case sevenExpress = "7X"

    // BMT Canarsie Line (Gray)
    case l = "L"

    // BMT Nassau Street/Jamaica Line (Brown)
    case j = "J"
    case z = "Z"

    // BMT Broadway Line (Yellow)
    case n = "N"
    case q = "Q"
    case r = "R"
    case w = "W"

    // IND Eighth Avenue Line (Blue)
    case a = "A"
    case c = "C"
    case e = "E"

    // IND Sixth Avenue Line (Orange)
    case b = "B"
    case d = "D"
    case f = "F"
    case fExpress = "FX"
    case m = "M"

    // IND Crosstown Line (Light Green)
    case g = "G"

    // Shuttles (Dark Gray)
    case gs = "GS"   // 42 St Shuttle (Grand Central)
    case fs = "FS"   // Franklin Avenue Shuttle
    case rs = "RS"   // Rockaway Park Shuttle

    // Staten Island Railway (Blue)
    case sir = "SIR"

    var id: String { rawValue }

    /// Display name for the line
    var displayName: String {
        switch self {
        case .sixExpress: return "6"
        case .sevenExpress: return "7"
        case .fExpress: return "F"
        case .gs: return "S"
        case .fs: return "S"
        case .rs: return "S"
        case .sir: return "SIR"
        default: return rawValue
        }
    }

    /// Official MTA color for each line
    var color: Color {
        switch self {
        // Red lines
        case .one, .two, .three:
            return Color(red: 238/255, green: 53/255, blue: 46/255)

        // Green lines (Lexington)
        case .four, .five, .six, .sixExpress:
            return Color(red: 0/255, green: 147/255, blue: 60/255)

        // Purple (Flushing)
        case .seven, .sevenExpress:
            return Color(red: 185/255, green: 51/255, blue: 173/255)

        // Gray (Canarsie)
        case .l:
            return Color(red: 167/255, green: 169/255, blue: 172/255)

        // Brown (Nassau)
        case .j, .z:
            return Color(red: 153/255, green: 102/255, blue: 51/255)

        // Yellow (Broadway BMT)
        case .n, .q, .r, .w:
            return Color(red: 252/255, green: 204/255, blue: 10/255)

        // Blue (Eighth Avenue)
        case .a, .c, .e:
            return Color(red: 0/255, green: 57/255, blue: 166/255)

        // Orange (Sixth Avenue)
        case .b, .d, .f, .fExpress, .m:
            return Color(red: 255/255, green: 99/255, blue: 25/255)

        // Light Green (Crosstown)
        case .g:
            return Color(red: 108/255, green: 190/255, blue: 69/255)

        // Dark Gray (Shuttles)
        case .gs, .fs, .rs:
            return Color(red: 128/255, green: 129/255, blue: 131/255)

        // Blue (SIR)
        case .sir:
            return Color(red: 0/255, green: 57/255, blue: 166/255)
        }
    }

    /// Text color for contrast (white or black depending on background)
    var textColor: Color {
        switch self {
        case .n, .q, .r, .w:
            return .black
        default:
            return .white
        }
    }

    /// Create from a string (handles various formats)
    static func from(_ string: String) -> SubwayLine? {
        let normalized = string.uppercased().trimmingCharacters(in: .whitespaces)
        return SubwayLine(rawValue: normalized) ?? SubwayLine(rawValue: string)
    }
}

// MARK: - Line Badge View
struct LineBadge: View {
    let line: String
    var size: CGFloat = 24

    private var subwayLine: SubwayLine? {
        SubwayLine.from(line)
    }

    private var hasSuperscript: Bool {
        line == "FS" || line == "RS"
    }

    private var superscriptLetter: String {
        switch line {
        case "FS": return "F"
        case "RS": return "R"
        default: return ""
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(subwayLine?.color ?? .gray)
                .frame(width: size, height: size)

            if hasSuperscript {
                HStack(alignment: .top, spacing: 0) {
                    Text("S")
                        .font(.system(size: size * 0.45, weight: .bold))
                    Text(superscriptLetter)
                        .font(.system(size: size * 0.25, weight: .bold))
                        .baselineOffset(size * 0.15)
                }
                .foregroundColor(subwayLine?.textColor ?? .white)
            } else {
                Text(subwayLine?.displayName ?? line)
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(subwayLine?.textColor ?? .white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 4) {
            LineBadge(line: "1")
            LineBadge(line: "2")
            LineBadge(line: "3")
            LineBadge(line: "A")
            LineBadge(line: "N")
            LineBadge(line: "Q")
            LineBadge(line: "G")
        }
        HStack(spacing: 8) {
            LineBadge(line: "FS", size: 44)
            LineBadge(line: "GS", size: 44)
            LineBadge(line: "RS", size: 44)
        }
    }
    .padding()
}
