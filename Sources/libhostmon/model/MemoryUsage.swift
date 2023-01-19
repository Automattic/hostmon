import Foundation

public struct MemoryUsage: Codable {

    public let freeBytes: UInt64
    public let activeBytes: UInt64
    public let wiredBytes: UInt64
    public let compressedBytes: UInt64

    static func from(_ stats: vm_statistics64) -> MemoryUsage {
        let pageSize = UInt64(vm_page_size)

        return MemoryUsage(
            freeBytes: UInt64(stats.free_count + stats.inactive_count) * pageSize,
            activeBytes: UInt64(stats.active_count) * pageSize,
            wiredBytes: UInt64(stats.wire_count) * pageSize,
            compressedBytes: UInt64(stats.compressor_page_count) * pageSize
        )
    }
}
