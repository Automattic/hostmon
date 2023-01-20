import Foundation

/// A dynamic `CodingKey` useful for creating custom `Encodable` implementations
struct DynamicCodingKey: CodingKey {
    var intValue: Int?
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    var stringValue: String
    init(stringValue: String) {
        self.intValue = nil
        self.stringValue = stringValue
    }
}
