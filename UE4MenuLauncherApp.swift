import SwiftUI

@main
struct UE4MenuLauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

private enum MenuPage: String, CaseIterable {
    case home = "控制台"
    case esp = "ESP 设置"
    case aim = "AIM 设置"
    case touch = "触控菜单"

    var symbol: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
        case .esp: return "viewfinder"
        case .aim: return "scope"
        case .touch: return "hand.tap.fill"
        }
    }
}

private enum Palette {
    static let background = Color(red: 0.025, green: 0.043, blue: 0.075)
    static let panel = Color(red: 0.055, green: 0.085, blue: 0.135)
    static let panel2 = Color(red: 0.075, green: 0.115, blue: 0.18)
    static let cyan = Color(red: 0.25, green: 0.82, blue: 1.0)
    static let blue = Color(red: 0.25, green: 0.43, blue: 0.95)
    static let muted = Color(red: 0.56, green: 0.65, blue: 0.76)
    static let green = Color(red: 0.20, green: 0.83, blue: 0.62)
}

struct ContentView: View {
    @AppStorage("espEnabled") private var espEnabled = false
    @AppStorage("espDistanceEnabled") private var espDistanceEnabled = true
    @AppStorage("espSkeletonEnabled") private var espSkeletonEnabled = false
    @AppStorage("espDistance") private var espDistance = 250.0

    @AppStorage("aimEnabled") private var aimEnabled = false
    @AppStorage("aimSensitivity") private var aimSensitivity = 50.0
    @AppStorage("aimRange") private var aimRange = 30.0

    @AppStorage("floatingMenuEnabled") private var floatingMenuEnabled = true
    @AppStorage("touchFeedbackEnabled") private var touchFeedbackEnabled = true

    @State private var page: MenuPage = .home
    @State private var showQuickMenu = false
    @State private var floatOffset = CGSize(width: 0, height: 0)
    @State private var toast: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.14, blue: 0.25), Palette.background, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if page == .home { dashboard }
                        switch page {
                        case .home:
                            homeActions
                        case .esp:
                            espSettings
                        case .aim:
                            aimSettings
                        case .touch:
                            touchSettings
                        }
                        footer
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 110)
                }
            }

            if floatingMenuEnabled {
                floatingControl
            }

            if showQuickMenu {
                quickMenuOverlay
            }

            if let toast {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(Palette.panel2.opacity(0.98), in: Capsule())
                        .overlay(Capsule().stroke(Palette.cyan.opacity(0.5), lineWidth: 1))
                        .padding(.bottom, 90)
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            tabBar
        }
    }

    private var header: some View {
        HStack(spacing: 11) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(LinearGradient(colors: [Palette.panel2, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 13)
                    .stroke(Palette.cyan.opacity(0.55), lineWidth: 1)
                Text("U4")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.cyan)
            }
            .frame(width: 43, height: 43)

            VStack(alignment: .leading, spacing: 3) {
                Text("UE4 MENU LAUNCHER")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white)
                Text("NATIVE iOS CONTROL PANEL · 1.0")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1.2)
                    .foregroundStyle(Palette.muted)
            }
            Spacer()
            HStack(spacing: 5) {
                Circle().fill(Palette.green).frame(width: 6, height: 6)
                Text("LOCAL")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Palette.green)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Palette.green.opacity(0.10), in: Capsule())
            .overlay(Capsule().stroke(Palette.green.opacity(0.35), lineWidth: 1))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var dashboard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SYSTEM INTERFACE / MOBILE")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(Palette.cyan)
            Text("CONTROL CENTER")
                .font(.system(size: 25, weight: .black, design: .rounded))
                .tracking(0.7)
                .foregroundStyle(.white)
            Text("独立菜单控制面板。所有选项仅保存为本机配置。")
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
            HStack(spacing: 9) {
                statusTile(title: "ESP CONFIG", value: espEnabled ? "ON" : "OFF", active: espEnabled)
                statusTile(title: "AIM CONFIG", value: aimEnabled ? "ON" : "OFF", active: aimEnabled)
                statusTile(title: "TOUCH UI", value: floatingMenuEnabled ? "ON" : "OFF", active: floatingMenuEnabled)
            }
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Color(red: 0.08, green: 0.19, blue: 0.31), Palette.panel], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Palette.cyan.opacity(0.22), lineWidth: 1))
    }

    private func statusTile(title: String, value: String, active: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(active ? Palette.cyan : Palette.muted)
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.black.opacity(0.20), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.cyan.opacity(0.12), lineWidth: 1))
    }

    private var homeActions: some View {
        VStack(spacing: 11) {
            sectionHeading("QUICK SETTINGS", subtitle: "快速进入菜单设置")
            pageButton(.esp, detail: "显示参数与本地 ESP 配置")
            pageButton(.aim, detail: "灵敏度与范围参数")
            pageButton(.touch, detail: "悬浮入口与触控反馈")
        }
    }

    private var espSettings: some View {
        VStack(spacing: 12) {
            sectionHeading("ESP CONFIGURATION", subtitle: "显示参数配置 · 本地演示")
            settingsCard {
                ToggleRow(title: "ESP 总开关", detail: "启用或停用本地配置状态", isOn: $espEnabled)
                Divider().overlay(Palette.muted.opacity(0.15))
                ToggleRow(title: "显示距离", detail: "距离显示选项", isOn: $espDistanceEnabled)
                Divider().overlay(Palette.muted.opacity(0.15))
                ToggleRow(title: "骨骼显示", detail: "骨骼显示选项", isOn: $espSkeletonEnabled)
            }
            settingsCard {
                SliderRow(title: "最大显示距离", value: $espDistance, range: 50...500, suffix: " m", step: 10)
            }
        }
    }

    private var aimSettings: some View {
        VStack(spacing: 12) {
            sectionHeading("AIM CONFIGURATION", subtitle: "灵敏度与范围配置 · 本地演示")
            settingsCard {
                ToggleRow(title: "AIM 总开关", detail: "启用或停用本地配置状态", isOn: $aimEnabled)
            }
            settingsCard {
                SliderRow(title: "灵敏度", value: $aimSensitivity, range: 1...100, suffix: "%")
                Divider().overlay(Palette.muted.opacity(0.15))
                SliderRow(title: "配置范围", value: $aimRange, range: 5...100, suffix: "")
            }
        }
    }

    private var touchSettings: some View {
        VStack(spacing: 12) {
            sectionHeading("TOUCH MENU", subtitle: "菜单触控与显示行为")
            settingsCard {
                ToggleRow(title: "悬浮快捷按钮", detail: "显示屏幕右下角菜单入口", isOn: $floatingMenuEnabled)
                Divider().overlay(Palette.muted.opacity(0.15))
                ToggleRow(title: "触控反馈", detail: "点击菜单时显示轻提示", isOn: $touchFeedbackEnabled)
            }
            Button {
                showQuickMenu = false
                page = .home
                notify("已返回控制台")
            } label: {
                Label("收起快捷菜单", systemImage: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Palette.panel2, in: RoundedRectangle(cornerRadius: 13))
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.cyan.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func sectionHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 3)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .padding(.horizontal, 15)
            .padding(.vertical, 4)
            .background(Palette.panel, in: RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(Palette.muted.opacity(0.17), lineWidth: 1))
    }

    private func pageButton(_ target: MenuPage, detail: String) -> some View {
        Button {
            page = target
        } label: {
            HStack(spacing: 13) {
                Image(systemName: target.symbol)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Palette.cyan)
                    .frame(width: 39, height: 39)
                    .background(Palette.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 11))
                VStack(alignment: .leading, spacing: 4) {
                    Text(target.rawValue).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                    Text(detail).font(.system(size: 10)).foregroundStyle(Palette.muted)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold)).foregroundStyle(Palette.muted)
            }
            .padding(13)
            .background(Palette.panel, in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Palette.muted.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(MenuPage.allCases, id: \.self) { item in
                Button {
                    page = item
                    showQuickMenu = false
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol).font(.system(size: 16, weight: .semibold))
                        Text(item.rawValue).font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(page == item ? Palette.cyan : Palette.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 11)
                    .padding(.bottom, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(Palette.cyan.opacity(0.15)).frame(height: 1) }
    }

    private var floatingControl: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showQuickMenu.toggle()
                    if touchFeedbackEnabled { notify(showQuickMenu ? "快捷菜单已打开" : "快捷菜单已收起") }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: "square.grid.2x2.fill").font(.system(size: 16, weight: .bold))
                        Text("MENU").font(.system(size: 8, weight: .black)).tracking(1)
                    }
                    .foregroundStyle(Palette.cyan)
                    .frame(width: 58, height: 58)
                    .background(LinearGradient(colors: [Palette.panel2, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.cyan.opacity(0.7), lineWidth: 1))
                    .shadow(color: Palette.cyan.opacity(0.20), radius: 13)
                }
                .buttonStyle(.plain)
                .offset(floatOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in floatOffset = value.translation }
                        .onEnded { value in floatOffset = value.translation }
                )
                .padding(.trailing, 17)
                .padding(.bottom, 83)
            }
        }
        .ignoresSafeArea()
    }

    private var quickMenuOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text("QUICK MENU").font(.system(size: 10, weight: .black)).tracking(1.4).foregroundStyle(Palette.cyan)
                    ForEach([MenuPage.home, .esp, .aim, .touch], id: \.self) { item in
                        Button {
                            page = item
                            showQuickMenu = false
                        } label: {
                            Label(item.rawValue, systemImage: item.symbol)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 7)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(15)
                .frame(width: 180)
                .background(Palette.panel2, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.cyan.opacity(0.4), lineWidth: 1))
                .padding(.trailing, 18)
                .padding(.bottom, 151)
            }
        }
        .background(Color.black.opacity(0.15).ignoresSafeArea())
        .onTapGesture { showQuickMenu = false }
    }

    private var footer: some View {
        Text("LOCAL UI CONFIG ONLY · NO GAME PROCESS ACCESS")
            .font(.system(size: 8, weight: .medium))
            .tracking(1)
            .foregroundStyle(Palette.muted.opacity(0.75))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    private func notify(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.2)) { toast = nil }
        }
    }
}

private struct ToggleRow: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                Text(detail).font(.system(size: 10)).foregroundStyle(Palette.muted)
            }
        }
        .tint(Palette.cyan)
        .padding(.vertical, 11)
    }
}

private struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let suffix: String
    var step: Double = 1

    var body: some View {
        VStack(spacing: 9) {
            HStack {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Text("\(Int(value))\(suffix)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.cyan)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range, step: step).tint(Palette.cyan)
        }
        .padding(.vertical, 12)
    }
}
