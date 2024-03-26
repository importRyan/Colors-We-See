import Common
import SwiftUI

#if DEBUG
#Preview {
  ColorVisionSimulationWaves()
}
#endif

struct ColorVisionSimulationWaves: View {
  var body: some View {
    ZStack {
      gradient(.rainbowMonochromat)
        .mask { SinWave.monochromat.strokeMask() }
        .offset(y: 55)
        .opacity(0.5)

      gradient(.rainbow)
        .mask { SinWave.typical.strokeMask(80) }

      gradient(.rainbowTritan)
        .mask { SinWave.tritan.strokeMask() }
        .offset(y: -70)

      gradient(.rainbowDeutan)
        .mask { SinWave.deutan.strokeMask() }
        .offset(y: 55)
    }
    .padding(.horizontal, -10)
  }

  private func gradient(_ colors: [Color]) -> LinearGradient {
    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
  }
}

private extension Shape {
  func strokeMask(_ lineWidth: CGFloat = 50) -> StrokeShapeView<Self, Color, EmptyView> {
    stroke(
      .black,
      style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round),
      antialiased: true
    )
  }
}

// MARK: - Wave Shapes
// TODO: - Create mesh animation

private struct SinWave: Shape {

  static let deutan = Wave(
    amplitude: 55.37141793909605,
    frequency: 0.012186089103276013,
    verticalOffset: -4.448894575906419,
    horizontalOffset: 27.39359210392206
  )

  static let typical = Wave(
    amplitude: 46.77894537361254,
    frequency: 0.01274958326643165,
    verticalOffset: 9.155811134005386,
    horizontalOffset: -318.35550368898356
  )

  static let tritan = Wave(
    amplitude: 29.587242735430006,
    frequency: 0.01443512844358108,
    verticalOffset: -9.689308424712328,
    horizontalOffset: -359.8320661882735
  )

  static let monochromat = Wave(
    amplitude: 54.51518995686293,
    frequency: 0.010533089326873142,
    verticalOffset: -8.41792845075505,
    horizontalOffset: -74.51102410102453
  )

  func path(in rect: CGRect) -> Path {
    let amplitude = CGFloat.random(in: rect.height * 0.01...rect.height * 0.15)
    let frequency = CGFloat.random(in: 0.01...0.018)
    let verticalOffset = CGFloat.random(in: -rect.height * 0.05...rect.height * 0.05)
    let horizontalOffset = CGFloat.random(in: -500...50)
    return Wave(
      amplitude: amplitude,
      frequency: frequency,
      verticalOffset: verticalOffset,
      horizontalOffset: horizontalOffset
    ).path(in: rect)
  }

  fileprivate struct Wave: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var verticalOffset: CGFloat
    var horizontalOffset: CGFloat

    func path(in rect: CGRect) -> Path {
      var path = Path()
      let startX = rect.minX
      let endX = rect.maxX
      let midY = rect.midY + verticalOffset

      for x in stride(from: startX, through: endX, by: 1) {
        let y = sin((x + horizontalOffset) * frequency) * amplitude + midY
        let point = CGPoint(x: x, y: y)
        if path.isEmpty {
          path.move(to: point)
        } else {
          path.addLine(to: point)
        }
      }
      return path
    }
  }
}
