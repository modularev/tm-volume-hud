import SwiftUI
import Combine
import OSCKit
import ServiceManagement
import CoreText

enum DefaultsKeys {
    static let theme = "selected_Theme"
    static let oscAddress = "TM_OSC_Address"
    static let oscPort = "TM_OSC_Port"
    static let hudFrame = "HUD_Frame"
}

@main
struct TMOSCHUDApp: App {
    @StateObject private var oscManager = OSCManager()
    
    init() {
        FontRegistrar.registerBundledFonts()
    }
    
    @State private var isStartAtLoginEnabled: Bool = {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }()
    
    var body: some Scene {
        MenuBarExtra(oscManager.lastDbString) {
            Toggle("Start at Login", isOn: Binding(
                get: { isStartAtLoginEnabled },
                set: { toggleLaunchAtLogin(enabled: $0) }
            ))
            Picker("Styles", selection: $oscManager.theme) {
                ForEach(HUDTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.inline) // Removes the extra submenu/label and shows items directly

            Divider()
            Button("OSC Port: \(String(oscManager.oscPort))") { showPortChangeAlert() }
            Button("OSC Address: \(oscManager.oscAddress)") { showAddressChangeAlert() }
            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
        }
    }
    
    private func toggleLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if enabled { try service.register() }
                else { try service.unregister() }
                isStartAtLoginEnabled = enabled
            } catch { print("Error updating login status: \(error)") }
        }
    }
    
    private func showPortChangeAlert() {
        let alert = NSAlert()
        alert.messageText = "Change OSC Port"
        alert.icon = NSImage(size: NSSize(width: 1, height: 1), flipped: false) { _ in true }
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = String(oscManager.oscPort)
        alert.accessoryView = input
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            if let newPort = Int(input.stringValue) { oscManager.updatePort(newPort) }
        }
    }
    
    private func showAddressChangeAlert() {
        let alert = NSAlert()
        alert.messageText = "Change OSC Address"
        alert.icon = NSImage(size: NSSize(width: 1, height: 1), flipped: false) { _ in true }
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Restore Default")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 250, height: 24))
        input.stringValue = oscManager.oscAddress
        alert.accessoryView = input
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            oscManager.updateAddress(input.stringValue)
        } else if response == .alertSecondButtonReturn {
            oscManager.updateAddress("/1/mastervolumeVal")
        }
    }
}

enum FontRegistrar {
    static func registerBundledFonts() {
        guard let resourceURL = Bundle.main.resourceURL,
              let fileEnumerator = FileManager.default.enumerator(
                at: resourceURL,
                includingPropertiesForKeys: nil
              ) else { return }
        
        for case let fileURL as URL in fileEnumerator {
            let ext = fileURL.pathExtension.lowercased()
            guard ext == "ttf" || ext == "otf" else { continue }
            CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, nil)
        }
    }
}

class OSCManager: NSObject, ObservableObject {
    private var server: OSCUDPServer?
    private let hud = HUDController()

    @AppStorage(DefaultsKeys.theme) var theme: HUDTheme = .classicBlue
    @AppStorage(DefaultsKeys.oscAddress) var oscAddress: String = "/1/mastervolumeVal"
    @AppStorage(DefaultsKeys.oscPort) var oscPort: Int = 9001
    @Published var lastDbString: String = "-∞ dB"
    
    override init() {
        super.init()
        setupServer(port: oscPort)
    }

    func updateAddress(_ newAddress: String) {
        let trimmed = newAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { self.oscAddress = trimmed }
    }

    func updatePort(_ newPort: Int) {
        oscPort = newPort
        setupServer(port: newPort)
    }
    
    private func setupServer(port: Int) {
        server?.stop()
        server = OSCUDPServer(port: UInt16(port))
        server?.setReceiveHandler { [weak self] message, _, _, _ in
            Task { [weak self] in
                guard let self = self else { return }
                await MainActor.run {
                    if message.addressPattern.description == self.oscAddress,
                       var dbString = message.values.first as? String {
                        
                        dbString = dbString.replacingOccurrences(of: "-oo", with: "-∞ dB")
                        self.lastDbString = dbString
                        
                        let cleanValue = dbString.replacingOccurrences(of: " dB", with: "")
                                                .replacingOccurrences(of: "∞", with: "-100")
                                                .replacingOccurrences(of: "oo", with: "-100")
                        
                        let rawValue = Double(cleanValue) ?? -100.0
                        self.hud.show(dbValue: dbString, rawValue: rawValue, theme: self.theme, port: self.oscPort)
                    }
                }
            }
        }
        try? server?.start()
    }
}
