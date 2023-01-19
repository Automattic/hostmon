import Foundation
import libhostmon

struct StatsPackage: Encodable {

    let hostname = ProcessInfo.processInfo.hostName.replacingOccurrences(of: ".local", with: "")
    let username = ProcessInfo.processInfo.userName
    let uptime = Int(ProcessInfo.processInfo.systemUptime)

    let osversion: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion

    let cpuLoad: CPULoad?
    let memoryUsage: MemoryUsage
    let diskUsage: DiskUsage
    let networkUsage: NetworkUsage?
    let temperatures: [TemperatureSensorValue]
    let fanSpeeds: [FanSpeedValue]

    let sampleTime = Date()

    func printStats() {
        print("--- Memory Usage")
        print("Wired: \(Format.memorySize(memoryUsage.wiredBytes))")
        print("Active: \(Format.memorySize(memoryUsage.activeBytes))")
        print("Compressed: \(Format.memorySize(memoryUsage.compressedBytes))")
        print("Free: \(Format.memorySize(memoryUsage.freeBytes))")

        print("--- Disk Usage")
        print("Total: \(Format.diskSpace(diskUsage.totalCapacity))")
        print("Available: \(Format.diskSpace(diskUsage.availableCapacity))")

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

        print("--- Temperature")
        for sensor in temperatures {
            print("\(sensor.sensorName): \(sensor.temperature)")
        }

        print("--- Fan Speeds")
        for fan in fanSpeeds {
            print("\(fan.fanName)L \(fan.rpm)RPM")
        }
    }

    enum CodingKeys: CodingKey {
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

    func encode(to encoder: Encoder) throws {

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
}
