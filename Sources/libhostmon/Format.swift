import Foundation

struct Format {

    private static let diskSpaceFormatter: ByteCountFormatter = {
        let fmt = ByteCountFormatter()
        fmt.countStyle = .file
        return fmt
    }()

    private static let memorySizeFormatter: ByteCountFormatter = {
        let fmt = ByteCountFormatter()
        fmt.countStyle = .memory
        return fmt
    }()

    static func diskSpace(_ int: UInt64) -> String {
        diskSpaceFormatter.string(fromByteCount: Int64(int))
    }

    static func memorySize(_ int: UInt32) -> String {
        memorySizeFormatter.string(fromByteCount: Int64(int))
    }

    static func memorySize(_ int: UInt64) -> String {
        memorySizeFormatter.string(fromByteCount: Int64(int))
    }

    static func osVersion(_ version: OperatingSystemVersion) -> String {
        let fmt = NumberFormatter()
        fmt.minimumIntegerDigits = 2
        fmt.maximumIntegerDigits = 2

        return [
            fmt.string(for: version.majorVersion),
            fmt.string(for: version.minorVersion),
            fmt.string(for: version.patchVersion)
        ].compactMap { $0 }.joined()
    }
}

extension OperatingSystemVersion: Encodable {

    enum CodingKeys: String, CodingKey {
        case major, minor, patch
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.majorVersion, forKey: .major)
        try container.encode(self.minorVersion, forKey: .minor)
        try container.encode(self.patchVersion, forKey: .patch)
    }

    var asDouble: Double {
        Double(self.patchVersion + self.minorVersion * 100 + self.majorVersion * 10_000)
    }
}
