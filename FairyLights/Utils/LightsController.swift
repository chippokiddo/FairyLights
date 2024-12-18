import SwiftUI
import Quartz

class LightsController: ObservableObject {
    @Published var isLightsOn = false
    
    private var windows: [NSWindow] = []
    private var observer: NSObjectProtocol?

    init() {
        observeScreenChanges()
    }

    func toggleLights() {
        objectWillChange.send()
        if isLightsOn {
            hideLights()
        } else {
            showLights()
        }
        isLightsOn.toggle()
    }

    private func showLights() {
        guard windows.isEmpty else { return }

        for screen in NSScreen.screens {
            positionLights(on: screen)
        }

        for window in windows {
            window.alphaValue = 0
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                window.animator().alphaValue = 1.0
            }
        }
    }


    private func hideLights() {
        for window in windows {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.5
                window.animator().alphaValue = 0
            } completionHandler: {
                window.contentView = nil
                window.close()
            }
        }
        windows.removeAll()
    }

    private func positionLights(on screen: NSScreen) {
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

    private func observeScreenChanges() {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.isLightsOn else { return }
            self.repositionLights()
        }
    }

    private func repositionLights() {
        hideLights()
        showLights()
    }

    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
