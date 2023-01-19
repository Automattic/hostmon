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
}
