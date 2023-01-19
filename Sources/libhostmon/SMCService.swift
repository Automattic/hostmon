import Foundation
import libsmc
import IOKit

extension FourCharCode: ExpressibleByStringLiteral {
    public init(stringLiteral string: String) {
        precondition(string.utf8.count == 4)
        self = FourCharCode(bytes: [UInt8](string.utf8))
    }

    public init(_ string: String) {
        precondition(string.utf8.count == 4)
        self = FourCharCode(bytes: [UInt8](string.utf8))
    }

    public init(bytes: [UInt8]) {
        precondition(bytes.count == 4)
        self = UInt32(bytes[0]) << 24 | UInt32(bytes[1]) << 16 | UInt32(bytes[2]) << 8 |  UInt32(bytes[3])
    }

    var dataValue: Data {
        Data(withUnsafeBytes(of: self) { Array($0) }.reversed())
    }

    func toString() -> String {
        String(data: dataValue, encoding: .utf8)!
    }

    func asUInt32Char_t() -> UInt32Char_t {
        let bytes = self.toString().utf8CString
        return (bytes[0], bytes[1], bytes[2], bytes[3], 0)
    }
}

public struct SMCService {

    enum Errors: Error {
        case unableToConnectToSMCService
        case unableToFetchKey
        case unableToReadKey
    }

    private let conn: io_connect_t

    public init() throws {
        var conn = io_connect_t()

        guard SMCOpen(&conn) == kIOReturnSuccess else {
            throw Errors.unableToConnectToSMCService
        }

        self.conn = conn
    }

    func closeConnection() throws {
        SMCClose(self.conn)
    }

    public func fetchValidKeyCount() throws -> UInt32 {
        let val = try read(key: "#KEY")
        return SMCBytes(bytes: val.bytes).uInt32Value
    }

    public func fetchAllKeys() throws -> [FourCharCode] {
        try (0..<fetchValidKeyCount()).map { try fetchKey(at: $0) }
    }

    public func fetchKey(at index: UInt32) throws -> FourCharCode {
        var inputStructure = SMCKeyData_t()
        inputStructure.data8 = CChar(SMC_CMD_READ_INDEX)
        inputStructure.data32 = index

        var outputStructure = SMCKeyData_t()

        let result = SMCCall2(KERNEL_INDEX_SMC, &inputStructure, &outputStructure, self.conn)

        guard result == kIOReturnSuccess else {
            throw Errors.unableToFetchKey
        }

        return outputStructure.key
    }

    public func fetchTemperature(forSensorWithCode code: FourCharCode) throws -> Double {
        let val = try read(key: code)
        return SMCBytes(bytes: val.bytes).sp78Value
    }

    public func fetchFanSpeed(forFanWithCode code: FourCharCode) throws -> Int {
        let val = try read(key: code)
        return Int(getFloatFromVal(val))
    }

    private func read(key: FourCharCode) throws -> SMCVal_t {
        var val = SMCVal_t()
        var mutableKey = key.asUInt32Char_t()

        let result = withUnsafeMutablePointer(to: &mutableKey) {
            SMCReadKey2($0, &val, self.conn)
        }

        guard result == kIOReturnSuccess else {
            throw Errors.unableToReadKey
        }

        return val
    }
}
