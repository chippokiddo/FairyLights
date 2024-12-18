import SwiftUI
import AppKit

struct LightsView: View {
    let width: CGFloat
    private let lightSpacing: CGFloat = 60
    private let verticalAmplitude: CGFloat = 10
    private let menuBarHeight = NSStatusBar.system.thickness
    private let bulbHeight: CGFloat = 30

    var body: some View {
        ZStack {
            let lightCount = Int((width / lightSpacing).rounded(.down)) + 1
            let totalSpacing = CGFloat(lightCount - 1) * lightSpacing
            let startingOffset = (width - totalSpacing) / 2

            // Wire path
            Path { path in
                let startX = startingOffset
                let startY = menuBarHeight + sin(0) * verticalAmplitude

                path.move(to: CGPoint(x: startX, y: startY))

                for index in 1..<lightCount {
                    let xOffset = startingOffset + CGFloat(index) * lightSpacing
                    let sineOffset = sin(CGFloat(index) * .pi / 4) * verticalAmplitude
                    let yOffset = menuBarHeight + sineOffset

                    let controlX = (xOffset + startingOffset + CGFloat(index - 1) * lightSpacing) / 2
                    let controlY = yOffset + 5

                    path.addQuadCurve(to: CGPoint(x: xOffset, y: yOffset),
                                      control: CGPoint(x: controlX, y: controlY))
                }
            }
            .stroke(Color.black, lineWidth: 3) // Draw the wire

            // Draw the bulbs with bottoms aligned to the wire
            ForEach(0..<lightCount, id: \.self) { index in
                let xOffset = startingOffset + CGFloat(index) * lightSpacing
                let sineOffset = sin(CGFloat(index) * .pi / 4) * verticalAmplitude

                // Determine if bulb is upside-down or upright
                let isUpsideDown = Bool.random()
                let yAdjustment = isUpsideDown ? 0 : -bulbHeight // Move upright bulbs up

                // Position bulbs
                let positionY = menuBarHeight + sineOffset + (bulbHeight / 2) + yAdjustment

                let baseRotation = CGFloat.random(in: -10...10)
                let finalRotation = isUpsideDown ? baseRotation + 180 : baseRotation

                BulbView()
                    .rotationEffect(.degrees(finalRotation)) // Slight rotation
                    .frame(width: bulbHeight, height: bulbHeight)
                    .position(x: xOffset, y: positionY)
            }
        }
        .frame(width: width, height: menuBarHeight + bulbHeight + verticalAmplitude)
        .background(Color.clear)
    }
}
