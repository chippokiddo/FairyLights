import SwiftUI

struct BulbView: View {
    let colors = ["red", "green", "yellow", "blue"]
    @State private var currentColor: String = "red"
    @State private var glowVisible: Bool = false
    
    var body: some View {
        ZStack {
            if glowVisible {
                Image("bulb_\(currentColor)_glow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }

            Image("bulb_\(currentColor)")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        .onAppear {
            startTwinkleEffect()
            startColorChangeEffect()
        }
    }
    
    private func startTwinkleEffect() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.5...1.5), repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(Animation.easeInOut(duration: 0.5)) {
                    glowVisible.toggle()
                }
            }
        }
    }

    private func startColorChangeEffect() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.0...4.0), repeats: true) { _ in
            let newColor = colors.randomElement() ?? "red"
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentColor = newColor
                }
            }
        }
    }
}
