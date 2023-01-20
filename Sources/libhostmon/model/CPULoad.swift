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

    var asDictionary: [String: Double] {
        [
            "user": self.user,
            "system": self.system,
            "idle": self.idle,
            "nice": self.nice
        ]
    }
}
