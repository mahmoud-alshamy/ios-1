import AppKit
import Foundation

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, NSImage>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let appCache = paths[0].appendingPathComponent("com.elshamy.dynamicwin")
        try? fileManager.createDirectory(at: appCache, withIntermediateDirectories: true)
        return appCache
    }()

    private init() {
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB
        Logger.log("ImageCache initialized", category: "ImageCache")
    }

    func image(forKey key: String) -> NSImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            Logger.log("Image cache hit (memory): \(key)", category: "ImageCache")
            return image
        }

        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let image = NSImage(contentsOf: fileURL) {
            // Restore to memory cache
            cache.setObject(image, forKey: key as NSString, cost: estimatedCost(image))
            Logger.log("Image cache hit (disk): \(key)", category: "ImageCache")
            return image
        }

        return nil
    }

    func setImage(_ image: NSImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: estimatedCost(image))

        // Save to disk
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            try? pngData.write(to: fileURL)
            Logger.log("Image cached (disk): \(key)", category: "ImageCache")
        }
    }

    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        Logger.log("Image cache cleared", category: "ImageCache")
    }

    private func estimatedCost(_ image: NSImage) -> Int {
        guard let tiffData = image.tiffRepresentation else { return 0 }
        return tiffData.count
    }
}
