import SwiftUI
import Quartz

@MainActor
class LightsController: ObservableObject {
    @Published var isLightsOn = false

    private var windows: [NSWindow] = []

    init() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleScreenChange()
            }
        }
    }

    func toggleLights() {
        isLightsOn.toggle()
        isLightsOn ? fadeInLights() : fadeOutLights()
    }

    private func fadeInLights() {
        if !windows.isEmpty {
            animateWindows(alpha: 1.0)
            return
        }

        for screen in NSScreen.screens {
            createLightWindow(for: screen)
        }

        windows.forEach { $0.alphaValue = 0.0 }
        animateWindows(alpha: 1.0)
    }

    private func fadeOutLights() {
        animateWindows(alpha: 0.0) {
            self.clearWindows()
        }
    }

    private func createLightWindow(for screen: NSScreen) {
        let menuBarHeight = NSStatusBar.system.thickness
        let lightsHeight: CGFloat = 50

        let windowFrame = NSRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y + screen.frame.height - menuBarHeight - lightsHeight,
            width: screen.frame.width,
            height: lightsHeight
        )

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [],
            backing: .buffered,
            defer: false
        )

        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.contentView = NSHostingView(rootView: LightsView(width: screen.frame.width))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isReleasedWhenClosed = false
        window.orderFront(nil)

        windows.append(window)
    }

    private func animateWindows(alpha: CGFloat, completion: (() -> Void)? = nil) {
        guard !windows.isEmpty else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            for window in windows {
                window.animator().alphaValue = alpha
            }
        } completionHandler: {
            completion?()
        }
    }

    private func clearWindows() {
        windows.forEach { $0.close() }
        windows.removeAll()
    }

    private func handleScreenChange() {
        guard isLightsOn else { return }
        refreshLights()
    }

    private func refreshLights() {
        if !windows.isEmpty {
            clearWindows()
        }
        fadeInLights()
    }
}
