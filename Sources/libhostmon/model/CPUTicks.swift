import Foundation

public struct CPUTicks {

    let user: UInt64
    let system: UInt64
    let idle: UInt64
    let nice: UInt64
    let total: UInt64

    init(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64) {
        self.user = user
        self.system = system
        self.idle = idle
        self.nice = nice

        self.total = user + system + idle + nice
    }

    static func from(_ loadInfo: host_cpu_load_info) -> CPUTicks {
        CPUTicks(
            user: UInt64(loadInfo.cpu_ticks.0),
            system: UInt64(loadInfo.cpu_ticks.1),
            idle: UInt64(loadInfo.cpu_ticks.2),
            nice: UInt64(loadInfo.cpu_ticks.3)
        )
    }

    var userPercentage: Double {
        Double(user) / Double(total)
    }

    var systemPercentage: Double {
        Double(system) / Double(total)
    }

    var idlePercentage: Double {
        Double(idle) / Double(total)
    }

    var nicePercentage: Double {
        Double(nice) / Double(total)
    }
}

extension CPUTicks: AdditiveArithmetic {
    public static let zero = CPUTicks(user: 0, system: 0, idle: 0, nice: 0)

    public static func + (lhs: CPUTicks, rhs: CPUTicks) -> CPUTicks {
        CPUTicks(
            user: lhs.user + rhs.user,
            system: lhs.system + rhs.system,
            idle: lhs.idle + rhs.idle,
            nice: lhs.nice + rhs.nice
        )
    }

    public static func - (lhs: CPUTicks, rhs: CPUTicks) -> CPUTicks {
        CPUTicks(
            user: lhs.user - rhs.user,
            system: lhs.system - rhs.system,
            idle: lhs.idle - rhs.idle,
            nice: lhs.nice - rhs.nice
        )
    }
}
