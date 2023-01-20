import Foundation

public struct StatsPackage: Encodable {

    public let hostname = ProcessInfo.processInfo.hostName.replacingOccurrences(of: ".local", with: "")
    public let username = ProcessInfo.processInfo.userName
    public let uptime = Int(ProcessInfo.processInfo.systemUptime)

    public let osversion: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion

    public let cpuLoad: CPULoad?
    public let memoryUsage: MemoryUsage?
    public let diskUsage: DiskUsage?
    public let networkUsage: NetworkUsage?
    public let temperatures: [TemperatureSensorValue]
    public let fanSpeeds: [FanSpeedValue]

    public let sampleTime = Date()

    public init(
        cpuLoad: CPULoad? = nil,
        memoryUsage: MemoryUsage? = nil,
        diskUsage: DiskUsage? = nil,
        networkUsage: NetworkUsage? = nil,
        temperatures: [TemperatureSensorValue] = [],
        fanSpeeds: [FanSpeedValue] = []
    ) {
        self.cpuLoad = cpuLoad
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.networkUsage = networkUsage
        self.temperatures = temperatures
        self.fanSpeeds = fanSpeeds
    }

    public func printStats() {
        if let memoryUsage {
            print("--- Memory Usage")
            print("Wired: \(Format.memorySize(memoryUsage.wiredBytes))")
            print("Active: \(Format.memorySize(memoryUsage.activeBytes))")
            print("Compressed: \(Format.memorySize(memoryUsage.compressedBytes))")
            print("Free: \(Format.memorySize(memoryUsage.freeBytes))")
        }

        if let diskUsage {
            print("--- Disk Usage")
            print("Total: \(Format.diskSpace(diskUsage.totalCapacity))")
            print("Available: \(Format.diskSpace(diskUsage.availableCapacity))")
        }

        if let cpuLoad {
            print("--- CPU Load")
            print("User: \(cpuLoad.user)")
            print("System: \(cpuLoad.system)")
            print("Idle: \(cpuLoad.idle)")
        }

        if let networkUsage {
            print("--- Network Usage")
            print("Sent: \(Format.memorySize(networkUsage.bytesSent))")
            print("Received: \(Format.memorySize(networkUsage.bytesReceieved))")
        }

        if !temperatures.isEmpty {
            print("--- Temperature")
            for sensor in temperatures {
                print("\(sensor.sensorName): \(sensor.temperature)")
            }
        }

        if !fanSpeeds.isEmpty {
            print("--- Fan Speeds")
            for fan in fanSpeeds {
                print("\(fan.fanName)L \(fan.rpm)RPM")
            }
        }
    }

    enum CodingKeys: CodingKey, CaseIterable {
        case hostname
        case username
        case uptime
        case osversion
        case cpuLoad
        case memoryUsage
        case diskUsage
        case networkUsage
        case temperatures
        case fanSpeeds
        case sampleTime
    }

    public func encode(to encoder: Encoder) throws {

        let tempMap = self.temperatures.reduce(into: [String: Int]()) { $0[$1.sensorName] = $1.temperature }
        let fanMap = self.fanSpeeds.reduce(into: [String: Int]()) { $0[$1.fanName] = $1.rpm }

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.hostname, forKey: .hostname)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.uptime, forKey: .uptime)
        try container.encode(self.osversion, forKey: .osversion)
        try container.encode(self.sampleTime, forKey: .sampleTime)
        try container.encodeIfPresent(self.cpuLoad, forKey: .cpuLoad)
        try container.encode(self.memoryUsage, forKey: .memoryUsage)
        try container.encode(self.diskUsage, forKey: .diskUsage)
        try container.encodeIfPresent(self.networkUsage, forKey: .networkUsage)
        try container.encode(tempMap, forKey: .temperatures)
        try container.encode(fanMap, forKey: .fanSpeeds)
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
