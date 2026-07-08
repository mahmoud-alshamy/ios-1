import Foundation
import AppKit

struct FileTrayItem: Identifiable, Codable {
    let id: String
    let url: URL
    let name: String
    let fileType: String
    let addedDate: Date
    let size: Int64

    var icon: NSImage? { NSWorkspace.shared.icon(forFile: url.path) }

    enum CodingKeys: String, CodingKey {
        case id, name, fileType, addedDate, size, urlPath = "url"
    }

    init(url: URL, name: String? = nil, fileType: String? = nil) {
        self.id = UUID().uuidString
        self.url = url
        self.name = name ?? url.lastPathComponent
        self.fileType = fileType ?? url.pathExtension
        self.addedDate = Date()
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            self.size = attributes[.size] as? Int64 ?? 0
        } catch {
            self.size = 0
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fileType = try container.decode(String.self, forKey: .fileType)
        addedDate = try container.decode(Date.self, forKey: .addedDate)
        size = try container.decode(Int64.self, forKey: .size)
        let urlPath = try container.decode(String.self, forKey: .urlPath)
        url = URL(fileURLWithPath: urlPath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fileType, forKey: .fileType)
        try container.encode(addedDate, forKey: .addedDate)
        try container.encode(size, forKey: .size)
        try container.encode(url.path, forKey: .urlPath)
    }

    var formattedSize: String {
        let bytes = Double(size)
        let kb = bytes / 1024
        let mb = kb / 1024
        let gb = mb / 1024
        if gb >= 1 { return String(format: "%.2f GB", gb) }
        else if mb >= 1 { return String(format: "%.2f MB", mb) }
        else if kb >= 1 { return String(format: "%.2f KB", kb) }
        else { return String(format: "%.0f B", bytes) }
    }
}
