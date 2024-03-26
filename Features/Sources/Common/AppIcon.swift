#if DEBUG
import SwiftUI

#Preview {
  AppIcon()
}

package struct AppIcon: View {
  package var body: some View {
    ZStack {
      gradient(.rainbowDeutan)
      gradient(.rainbow)
        .mask {
          LinearGradient(
            stops: [
              .init(color: .black, location: 0.2),
              .init(color: .white, location: 0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          .luminanceToAlpha()
        }
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func gradient(_ colors: [Color]) -> LinearGradient {
    LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
  }
}
#endif
