
import Foundation

internal extension String {
    func toCStringPointer() -> UnsafeMutablePointer<CChar> {
        guard let cString = self.cString(using: .utf8) else {
            return UnsafeMutablePointer(bitPattern: 0)!
        }
        
        let capacity = cString.count + 1
        let ptr = UnsafeMutablePointer<CChar>.allocate(capacity: capacity)
        let bufferPtr = UnsafeMutableBufferPointer(start: ptr, count: capacity)
        let (_, endIndex) = bufferPtr.initialize(from: cString)
        bufferPtr[endIndex] = 0
        
        return ptr
    }
}

@propertyWrapper struct WrappedCString {
    private(set) var cString: Optional<UnsafeMutablePointer<CChar>> = nil
    private var swiftString: String? = nil
    
    var wrappedValue: String? {
        get {
            return swiftString
        }
        set(value) {
            cString?.deallocate()
            swiftString = value
            cString = value?.toCStringPointer()
        }
    }
    
    var projectedValue: Optional<UnsafeMutablePointer<CChar>> {
        cString
    }
    
    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }
}
