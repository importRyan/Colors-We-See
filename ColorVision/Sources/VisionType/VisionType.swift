// Copyright 2022 by Ryan Ferrell. @importRyan

import Foundation

public enum VisionType: String, CaseIterable, Sendable, Codable {
  case typical, deutan, protan, tritan, monochromat

  public static let allColorBlindCases: [Self] = [
    .deutan, .protan, .tritan, .monochromat
  ]
}

extension VisionType: Identifiable {
  public var id: Self { self }
}
