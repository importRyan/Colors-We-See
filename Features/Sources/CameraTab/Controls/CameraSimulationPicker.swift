import SwiftUI
import VisionType

#if DEBUG
#Preview {
  Demo()
}
private struct Demo: View {
  @State var vision = VisionType.typical
  
  var body: some View {
    CameraSimulationPicker(simulation: $vision)
      .scenePadding()
      .padding(.bottom, 80)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .background(Color.gray)
  }
}
#endif

struct CameraSimulationPicker: View {
  @Binding var simulation: VisionType

  var body: some View {
    HStack {
      LeftButton(simulation: $simulation)

      Menu {
        VisionPicker(simulation: $simulation)
      } label: {
        ZStack {
          PickerMaximumWidthSpacer()
          Text(simulation.localizedInfo.shortName)
        }
      }
      .menuIndicator(.hidden)

      RightButton(simulation: $simulation)
    }
    .animation(.smooth, value: simulation)
    .font(.title3.weight(.medium))
    .tint(.primary)
    .background(.thinMaterial, in: .capsule)
    .compositingGroup()
    .shadow(color: .black.opacity(0.12), radius: 16, x: 12, y: 12)
  }
}

private struct LeftButton: View {
  @Binding var simulation: VisionType
  var body: some View {
    Button(
      action: { simulation.moreCommon() },
      label: {
        Image(systemName: "chevron.left")
          .padding()
          .contentShape(.rect)
      }
    )
    .disabled(simulation == .mostCommon)
    .accessibilityLabel(String(localized: .SimulationPicker.axLabelChangeSimulation))
    .accessibilityValue(String(localized: .SimulationPicker.axValueMoreCommon))
  }
}

private struct RightButton: View {
  @Binding var simulation: VisionType
  var body: some View {
    Button(
      action: { simulation.lessCommon() },
      label: {
        Image(systemName: "chevron.right")
          .padding()
          .contentShape(.rect)
      }
    )
    .disabled(simulation == .leastCommon)
    .accessibilityLabel(String(localized: .SimulationPicker.axLabelChangeSimulation))
    .accessibilityValue(String(localized: .SimulationPicker.axValueLessCommon))
  }
}

private struct PickerMaximumWidthSpacer: View {
  var body: some View {
    Text(Self.longest ?? VisionType.monochromat.rawValue)
      .padding(.horizontal)
      .hidden()
      .accessibilityHidden(true)
  }

  static let longest = VisionType
    .allCases
    .map(\.localizedInfo.shortName)
    .max { $0.count < $1.count }
}

private struct VisionPicker: View {
  @Binding var simulation: VisionType
  var body: some View {
    Picker(selection: $simulation) {
      ForEach(VisionType.allCases) { vision in
        Text(vision.localizedInfo.shortName)
          .tag(vision)
      }
    } label: {
      Text(.SimulationPicker.axLabelChangeSimulation)
    }
  }
}
