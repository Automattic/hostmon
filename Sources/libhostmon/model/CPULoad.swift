import Foundation

public struct CPULoad: Codable {
    public let user: Double
    public let system: Double
    public let idle: Double
    public let nice: Double

    public init?(currentTicks: CPUTicks, previousTicks: CPUTicks) {
        let difference = currentTicks - previousTicks

        let user = difference.userPercentage * 100
        let system = difference.systemPercentage * 100
        let idle = difference.idlePercentage * 100
        let nice = difference.nicePercentage * 100

        guard
            !user.isNaN, !user.isInfinite,
            !system.isNaN, !system.isInfinite,
            !idle.isNaN, !idle.isInfinite,
            !nice.isNaN, !nice.isInfinite
        else {
            return nil
        }

        self.user = user
        self.system = system
        self.idle = idle
        self.nice = nice
    }

    var asKeyValuePairs: [KeyValuePair] {
        [
            KeyValuePair(key: "user", value: .double(self.user)),
            KeyValuePair(key: "system", value: .double(self.system)),
            KeyValuePair(key: "idle", value: .double(self.idle)),
            KeyValuePair(key: "nice", value: .double(self.nice))
        ]
    }
}
