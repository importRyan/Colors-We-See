import CPUColorVisionSimulation
import Oklab
import SwiftUI

private let simulator: ColorBlindnessSimulation = MachadoColorBlindnessSimulator()

package extension [Color] {
  private static let offset = 15
  static let rainbow: [Color] = (Self.offset...(Self.offset + 360))
    .map {
      OklabColorPolar(
        lightness: 0.7,
        chroma: 0.25,
        hueDegrees: .init($0)
      )
    }
    .map(Color.init)

  static let rainbowDeutan = [Color].rainbow.map { simulator.simulate(.deutan, severity: 1, for: $0) ?? $0 }
  static let rainbowTritan = [Color].rainbow.map { simulator.simulate(.tritan, severity: 1, for: $0) ?? $0 }
  static let rainbowMonochromat = [Color].rainbow.map { simulator.simulate(.monochromat, severity: 1, for: $0) ?? $0 }
}
