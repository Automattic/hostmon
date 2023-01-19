import Foundation

public class HostStatistics {
    private let machPort = mach_host_self()

    enum Errors: Error {
        case unableToFetchCPULoad
        case unableToFetchMemoryUsage
        case unableToFetchDiskUsage
        case unableToFetchNetworkInterfaces
        case noNetworkInterfacesFound
        case noMatchingNetworkInterface(for: String)
    }

    private let cpuLoadInfoSize = MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<Int32>.stride
    private let memoryInfoSize = MemoryLayout<vm_statistics64>.stride / MemoryLayout<Int32>.stride

    /// Used to compare CPU tick counts between invocations of `cpuLoad`
    private var previousCPUTicks: CPUTicks!

    /// Used to compare network traffic counts between invocations of `networkStatistics(forInterfaceNamed:)`
    private var networkTrafficCache = [String: NetworkInterfaceStatistics]()

    public init() {}

    public var cpuLoad: CPULoad? {
        get throws {
            var cpuLoadInfo = host_cpu_load_info()
            var size = mach_msg_type_number_t(cpuLoadInfoSize)

            let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: cpuLoadInfoSize) {
                    host_statistics(machPort, HOST_CPU_LOAD_INFO, $0, &size)
                }
            }

            guard result == KERN_SUCCESS else {
                throw Errors.unableToFetchCPULoad
            }

            let currentTicks = CPUTicks.from(cpuLoadInfo)

            guard let previousTicks = self.previousCPUTicks else {
                self.previousCPUTicks = currentTicks
                return nil
            }

            self.previousCPUTicks = currentTicks
            return CPULoad(currentTicks: currentTicks, previousTicks: previousTicks)
        }
    }

    public var memoryUsage: MemoryUsage {
        get throws {
            var memoryInfo = vm_statistics64_data_t()
            var size = mach_msg_type_number_t(memoryInfoSize)

            let result = withUnsafeMutablePointer(to: &memoryInfo) {
                $0.withMemoryRebound(to: Int32.self, capacity: memoryInfoSize) {
                    host_statistics64(machPort, HOST_VM_INFO64, $0, &size)
                }
            }

            guard result == KERN_SUCCESS else {
                throw Errors.unableToFetchMemoryUsage
            }

            return MemoryUsage.from(memoryInfo)
        }
    }

    public func diskUsage(
        forVolumeContainingUrl url: URL = URL(fileURLWithPath: NSHomeDirectory())
    ) throws -> DiskUsage {
        let values = try url.resourceValues(forKeys: [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey
        ])

        guard
            let availableCapacity = values.volumeAvailableCapacityForImportantUsage,
            let totalCapacity = values.volumeTotalCapacity
        else {
            throw Errors.unableToFetchDiskUsage
        }

        return DiskUsage(
            availableCapacity: UInt64(availableCapacity),
            totalCapacity: UInt64(totalCapacity)
        )
    }

    public func networkStatistics(forInterfaceNamed name: String) throws -> NetworkUsage? {

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            throw Errors.unableToFetchNetworkInterfaces
        }

        guard let firstAddr = ifaddr else {
            throw Errors.noNetworkInterfacesFound
        }

        defer {
            freeifaddrs(ifaddr)
        }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            guard ifptr.pointee.ifa_addr.pointee.sa_family == AF_LINK else {
                continue
            }

            guard String(cString: ifptr.pointee.ifa_name) == name else {
                continue
            }

            let currentStats = try NetworkInterfaceStatistics.from(ifptr)
            guard let previousStats = self.networkTrafficCache[name] else {
                self.networkTrafficCache[name] = currentStats
                return nil
            }

            self.networkTrafficCache[name] = currentStats
            return NetworkUsage(currentUsageStatistics: currentStats, previousUsageStatistics: previousStats)
        }

        throw Errors.noMatchingNetworkInterface(for: name)
    }

    public func temperatureSensorValues() throws -> [TemperatureSensorValue] {
        try SensorService().fetchAllTemperatureSensorValues()
    }

    public func fanSpeedValues() throws -> [FanSpeedValue] {
        try SensorService().fetchAllFanSpeeds()
    }
}
