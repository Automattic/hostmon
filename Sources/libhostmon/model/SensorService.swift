import Foundation

public struct SensorService {

    private let smc: SMCService

    init() throws {
        self.smc = try SMCService()
    }

    public func fetchAllTemperatureSensorValues() throws -> [TemperatureSensorValue] {
        let codes = try self.smc.fetchAllKeys().map { $0.toString() }
        return try SensorCodes.temperatureSensors(in: codes).map {
            let value = try smc.fetchTemperature(forSensorWithCode: $0.code)
            return TemperatureSensorValue(sensorName: $0.label, temperature: Int(value))
        }// .filter { $0.temperature > 0 && $0.temperature < 100 }
    }

    public func fetchAllFanSpeeds() throws -> [FanSpeedValue] {
        let codes = try self.smc.fetchAllKeys().map { $0.toString() }
        return try SensorCodes.fans(in: codes).map {
            let value = try smc.fetchFanSpeed(forFanWithCode: $0.code)
            return FanSpeedValue(fanName: $0.label, rpm: value)
        }
    }
}

public struct TemperatureSensorValue: Codable {
    public let sensorName: String
    public let temperature: Int

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        try container.encode(self.temperature, forKey: DynamicCodingKey(stringValue: self.sensorName))
    }

    var asKeyValuePair: KeyValuePair {
        KeyValuePair(key: self.sensorName, value: .int(self.temperature))
    }
}

public struct FanSpeedValue: Codable {
    public let fanName: String
    public let rpm: Int

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        try container.encode(self.rpm, forKey: DynamicCodingKey(stringValue: self.fanName))
    }

    var asKeyValuePair: KeyValuePair {
        KeyValuePair(key: self.fanName, value: .int(self.rpm))
    }
}

enum SensorType {
    case cpu
    case pch
    case gpu
    case ram
    case ssd
    case psu
    case fan
    case airflow
    case ambient
    case thunderbolt
}

struct Sensor {
    let label: String
    let type: SensorType
    let code: FourCharCode
}

/// All sensor codes are from https://logi.wiki/index.php/SMC_Sensor_Codes
struct SensorCodes {
    static let ssdTempSensorCodes = [
        "TH0A",
        "TH0B",
        "TH0C",
        "Th0N",
        "TH0a",
        "TH0b",
        "TH1R",

        "TH0x" // Apple Silicon – m2
    ]

    static let cpuTempSensorCodes = [
        "TC1C",
        "TC2C",
        "TC3C",
        "TC4C",
        "TC5C",
        "TC6C",

        "TC0c",
        "TC1c",
        "TC2c",
        "TC3c",
        "TC4c",
        "TC5c",
        "TC6c",
        "TC7c",

        "Tp09", // Apple Silicon – m1
        "Tp0T", // Apple Silicon – m1
        "Tp01", // Apple Silicon – m1
        "Tp05", // Apple Silicon – m1
        "Tp0D", // Apple Silicon – m1
        "Tp0H", // Apple Silicon – m1
        "Tp0L", // Apple Silicon – m1
        "Tp0P", // Apple Silicon – m1
        "Tp0X", // Apple Silicon – m1
        "Tp0b", // Apple Silicon – m1

        "Tp0A", // Apple Silicon – m2
        "Tp0B", // Apple Silicon – m2
        "Tp0C", // Apple Silicon – m2
        "Tp0D", // Apple Silicon – m2
        "Tp0E", // Apple Silicon – m2
        "Tp0W", // Apple Silicon – m2
        "Tp0X", // Apple Silicon – m2
        "Tp0Y", // Apple Silicon – m2
        "Tp01", // Apple Silicon – m2
        "Tp02", // Apple Silicon – m2
        "Tp05", // Apple Silicon – m2
        "Tp06", // Apple Silicon – m2
        "Tp09" // Apple Silicon – m2
    ]

    static let gpuTempSensorCodes = [
        "TCGC",
        "TG0D",
        "TG1D",
        "TCGc",
        "TN0P",
        "TN1P",
        "TG0T",
        "TG0P",

        "Tg05", // Apple Silicon – m1
        "Tg0D", // Apple Silicon – m1
        "Tg0L", // Apple Silicon – m1
        "Tg0T", // Apple Silicon – m1

        "Tg0f", // Apple Silicon – m2
        "Tg0j" // Apple Silicon – m2
    ]

    static let memoryTempSensorCodes = [
        "TM0P"
    ]

    static let airflowTempSensorCodes = [
        "TA0P",
        "TaLC",
        "TaRC",
        "TA1P",

        "TaLP", // Apple Silicon – m2
        "TaRF" // Apple Silicon – m2
    ]

    static let ambientTempSensorCodes = [
        "TA0P",
        "TA1P",

        "TA0p",
        "TA1p",
        "TA2p",

        "Ta0P"
    ]

    static let thunderboltTempSensorCodes = [
        "TTLD",
        "TTRD",
        "TI0P",
        "TI1P",
        "TI0p",
        "Te0t",
        "THSP"
    ]

    static let fanCodes = [
        "F0Ac",
        "F1Ac"
    ]

    static func contains(_ code: String) -> Bool {
        ssdTempSensorCodes.contains(code)
    }

    struct Fan {
        let label: String
        let code: FourCharCode
    }

    static func fans(in list: [String]) -> [Fan] {
        return list.filter { fanCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Fan(
                    label: "fan-\($0.offset + 1)",
                    code: FourCharCode($0.element)
                )
            }
    }

    static func temperatureSensors(in list: [String]) -> [Sensor] {
        [
            cpuSensors(in: list),
            gpuSensors(in: list),
            memorySensors(in: list),
            ssdSensors(in: list),
            airflowSensors(in: list),
            ambientTemperatureSensors(in: list),
            thunderboltTemperatureSensors(in: list)
        ].reduce([Sensor](), +)
    }

    static func cpuSensors(in list: [String]) -> [Sensor] {
        list.filter { cpuTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "cpu-\($0.offset + 1)",
                    type: .cpu,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func memorySensors(in list: [String]) -> [Sensor] {
        list.filter { memoryTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "memory-\($0.offset + 1)",
                    type: .ram,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func ssdSensors(in list: [String]) -> [Sensor] {
        list.filter { ssdTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "ssd-\($0.offset + 1)",
                    type: .ssd,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func gpuSensors(in list: [String]) -> [Sensor] {
        list.filter { gpuTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "gpu-\($0.offset + 1)",
                    type: .gpu,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func airflowSensors(in list: [String]) -> [Sensor] {
        list.filter { airflowTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "airflow-\($0.offset+1)",
                    type: .airflow,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func ambientTemperatureSensors(in list: [String]) -> [Sensor] {
        list.filter { ambientTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "ambient-\($0.offset + 1)",
                    type: .ambient,
                    code: FourCharCode($0.element)
                )
            }
    }

    static func thunderboltTemperatureSensors(in list: [String]) -> [Sensor] {
        list.filter { thunderboltTempSensorCodes.contains($0) }
            .sorted()
            .enumerated()
            .map {
                Sensor(
                    label: "thunderbolt-\($0.offset + 1)",
                    type: .thunderbolt,
                    code: FourCharCode($0.element)
                )
            }
    }
}
