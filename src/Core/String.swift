
// Since the embedded mode doesn't yet have String support I need a placeholder implementation.

struct CString {
    var buffer: [CChar]
}

extension CString: ExpressibleByStringLiteral {
    init(stringLiteral value: StaticString) {
        self.buffer = [CChar]()
        value.withUTF8Buffer { ptr in
            self.buffer.reserveCapacity(ptr.count + 1)
            for char in ptr { self.buffer.append(CChar(char)) }
            self.buffer.append(0)
        }
    }
    
    init(_ value: StaticString) {
        self.buffer = []
        assert(value.isASCII)
        value.withUTF8Buffer { ptr in
            self.buffer.reserveCapacity(ptr.count + 1)
            for char in ptr {
                self.buffer.append(CChar(char))
            }
            self.buffer.append(0)
        }
    }
}
