import SwiftUI
import AppKit

class DraggablePanel: NSPanel {
    var onDragStarted: (() -> Void)?
    var onDragEnded: (() -> Void)?
    override func mouseDown(with event: NSEvent) { onDragStarted?(); super.mouseDown(with: event) }
    override func mouseUp(with event: NSEvent) { super.mouseUp(with: event); onDragEnded?() }
}

class HUDController {
    private var window: DraggablePanel?
    private var timer: Timer?

    func show(dbValue: String, rawValue: Double, theme: HUDTheme, port: Int) {
        if window == nil { setupWindow() }
        window?.contentView = NSHostingView(rootView: HUDView(dbValue: dbValue, rawValue: rawValue, theme: theme, port: port))
        window?.orderFrontRegardless()
        window?.alphaValue = 1.0
        resetTimer()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.6
                self?.window?.animator().alphaValue = 0
            }
        }
    }
    
    private func savePosition() {
        guard let window = window else { return }
        UserDefaults.standard.set(NSStringFromRect(window.frame), forKey: DefaultsKeys.hudFrame)
    }
    
    private func setupWindow() {
        var initialRect = NSRect(x: 0, y: 0, width: 340, height: 140)
        if let savedFrame = UserDefaults.standard.string(forKey: DefaultsKeys.hudFrame) {
            initialRect = NSRectFromString(savedFrame)
        }
        let panel = DraggablePanel(contentRect: initialRect, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.level = .mainMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.onDragStarted = { [weak self] in self?.timer?.invalidate(); self?.window?.alphaValue = 1.0 }
        panel.onDragEnded = { [weak self] in self?.savePosition(); self?.resetTimer() }
        if UserDefaults.standard.string(forKey: DefaultsKeys.hudFrame) == nil { panel.center() }
        self.window = panel
    }
}
