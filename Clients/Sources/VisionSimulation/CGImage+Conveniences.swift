import VisionType

#if os(macOS)
import AppKit

extension [VisionType: CIImage] {
  public func asPlatformImages() -> [VisionType: NSImage] {
    self
      .mapValues(NSBitmapImageRep.init(ciImage:))
      .mapValues(NSImage.init(bitmapRep:))
  }
}

extension CGImage {
  public static func `from`(fileURL: URL) throws -> CGImage {
    guard let loadedImage = NSImage(contentsOf: fileURL) else {
      throw CocoaError(.fileReadUnknown)
    }
    var rect = NSRect(
      origin: .zero,
      size: loadedImage.size
    )
    guard let cgImage = loadedImage .cgImage(
      forProposedRect: &rect,
      context: .current,
      hints: nil
    ) else {
      throw CocoaError(.fileReadUnsupportedScheme)
    }
    return cgImage
  }
}

extension NSImage {
  public convenience init(bitmapRep: NSBitmapImageRep) {
    self.init(size: bitmapRep.size)
    self.addRepresentation(bitmapRep)
  }
}

#elseif os(iOS)
import UIKit

extension [VisionType: CIImage] {
  public func asPlatformImages() -> [VisionType: UIImage] {
    self
      .compactMapValues { ciImage in
        UIGraphicsBeginImageContextWithOptions(ciImage.extent.size, true, 0)
        UIImage(ciImage: ciImage).draw(in: ciImage.extent)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
      }
  }
}
extension CGImage {
  public static func `from`(fileURL: URL) throws -> CGImage {
    guard fileURL.startAccessingSecurityScopedResource() else {
      throw CocoaError(.fileReadNoPermission)
    }
    let data = try Data(contentsOf: fileURL)
    fileURL.stopAccessingSecurityScopedResource()

    guard let imageFromFile = UIImage(data: data) else {
      throw CocoaError(.fileReadUnsupportedScheme)
    }
    guard let cgImage = imageFromFile.cgImage else {
      throw CocoaError(.fileReadUnknown)
    }
    return cgImage
  }
}
#endif
