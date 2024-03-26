// Copyright © 2023 by Ryan Ferrell. GitHub: importRyan

import Foundation

extension VisionType {
  public struct LocalizedInformation {
    public let colloquialType: String?
    public let explanation: String
    public let frequency: (men: Double, women: Double)
    public let fullIntensityName: String
    public let shortName: String
  }

  public var localizedInfo: LocalizedInformation {
    switch self {
    case .typical: return .typical
    case .deutan: return .deutan
    case .protan: return .protan
    case .tritan: return .tritan
    case .monochromat: return .monochromacy
    }
  }
}

extension VisionType.LocalizedInformation {

  static let typical = Self.init(
    colloquialType: nil,
    explanation: String(localized: .Typical.explanation),
    frequency: (men: 0.92, women: 0.99),
    fullIntensityName: String(localized: .Typical.fullIntensityName),
    shortName: String(localized: .Typical.shortName)
  )

  static let deutan = Self.init(
    colloquialType: String(localized: .Deutan.colloquialType),
    explanation: String(localized: .Deutan.explanation),
    frequency: (men: 0.06, women: 0.004),
    fullIntensityName: String(localized: .Deutan.fullIntensityName),
    shortName: String(localized: .Deutan.shortName)
  )

  static let protan = Self.init(
    colloquialType: String(localized: .Protan.colloquialType),
    explanation: String(localized: .Protan.explanation),
    frequency: (men: 0.025, women: 0.0005),
    fullIntensityName: String(localized: .Protan.fullIntensityName),
    shortName: String(localized: .Protan.shortName)
  )

  static let tritan = Self.init(
    colloquialType: String(localized: .Tritan.colloquialType),
    explanation: String(localized: .Tritan.explanation),
    frequency: (men: 0.01, women: 0.04),
    fullIntensityName: String(localized: .Tritan.fullIntensityName),
    shortName: String(localized: .Tritan.shortName)
  )

  static let monochromacy = Self.init(
    colloquialType: String(localized: .Mono.colloquialType),
    explanation: String(localized: .Mono.explanation),
    frequency: (men: 0.003, women: 0.003),
    fullIntensityName: String(localized: .Mono.fullIntensityName),
    shortName: String(localized: .Mono.shortName)
  )
}
