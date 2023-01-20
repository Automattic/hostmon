import Foundation

/// An object that makes it easy to pass around a strongly-typed heterogenous collection of values
///
public struct KeyValuePair: Encodable {

    public enum ValueType: Encodable {
        case int(Int)
        case int32(Int32)
        case timeInterval(TimeInterval)
        case double(Double)
        case string(String)
        case uInt32(UInt32)
        case uInt64(UInt64)

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let value): try container.encode(value)
            case .int32(let value): try container.encode(value)
            case .timeInterval(let value): try container.encode(value)
            case .double(let value): try container.encode(value)
            case .string(let value): try container.encode(value)
            case .uInt32(let value): try container.encode(value)
            case .uInt64(let value): try container.encode(value)
            }
        }
    }

    public let key: String
    public let value: ValueType

    init(key: String, value: ValueType) {
        self.key = key
        self.value = value
    }

    enum CodingKeys: CodingKey {
        case key
        case value
    }
}

extension [KeyValuePair] {
    func prependingKeysWith(_ prefix: String) -> [KeyValuePair] {
        self.map { KeyValuePair(key: prefix + $0.key, value: $0.value) }
    }
}
