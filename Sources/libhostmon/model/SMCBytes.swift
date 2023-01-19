import Foundation
import IOKit
import libsmc

struct SMCBytes {
    let bytes: (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )

    static var zero: SMCBytes {
        SMCBytes(bytes: (
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ))
    }

    subscript(index: Int) -> UInt8 {
        withUnsafeBytes(of: self.bytes) { ptr in
            [UInt8](ptr)
        }[index]
    }

    subscript(range: ClosedRange<Int>) -> ArraySlice<UInt8> {
        withUnsafeBytes(of: self.bytes) { ptr in
            [UInt8](ptr)
        }[range]
    }

    init(bytes: SMCBytes_t){
        self.bytes = bytes
    }

    var uInt32Value: UInt32 {
        [UInt8]([bytes.0, bytes.1, bytes.2, bytes.3]).reduce(0) { $0 << 8 | UInt32($1) }
    }

    var sp78Value: Double {
        let intVal = UInt32(bytes.0) * UInt32(256) + UInt32(bytes.1)
        return Double(intVal / 256)
    }
}
