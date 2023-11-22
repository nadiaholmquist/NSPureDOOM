
import Darwin
import Foundation
import CPureDOOM

extension UnsafeMutableRawPointer {
    func asFileHandle() -> UnsafeMutablePointer<FILE> {
        return UnsafeMutablePointer<FILE>(OpaquePointer(self))
    }
}

internal func doomPrint(str: Optional<UnsafePointer<CChar>>) {
    print(String(cString: str!), terminator: "")
}

internal func doomMalloc(size: Int32) -> UnsafeMutableRawPointer? {
    return UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: 0)
}
    
internal func doomFree(pointer: UnsafeMutableRawPointer?) {
    pointer?.deallocate()
}

internal func doomGetEnv(cString: UnsafePointer<CChar>?) -> Optional<UnsafeMutablePointer<CChar>> {
    guard let cString else { return nil }
    let name = String(cString: cString)
    
    return switch name {
    case "DOOMWADDIR": DOOM.$wadDir
    case "HOME": DOOM.$homeDir
    default: nil
    }
}

internal func doomGetTime(seconds: Optional<UnsafeMutablePointer<Int32>>, microseconds: Optional<UnsafeMutablePointer<Int32>>) {
    let now = DispatchTime.now()
    let distance = (now.uptimeNanoseconds - DOOM.startTime.uptimeNanoseconds) / 1000
    microseconds?.pointee = Int32(distance % 1000000)
    seconds?.pointee = Int32(distance / 1000000)
}

internal func doomOpen(fileName: UnsafePointer<CChar>?, mode: UnsafePointer<CChar>?) -> UnsafeMutableRawPointer? {
    guard let fileName else { return nil }
    guard let url = URL(string: String(cString: fileName)) else { return nil }
    let pathPtr = url.path.toCStringPointer()
    defer { pathPtr.deallocate() }
    
    let fileHandle = fopen(pathPtr, mode)
    return UnsafeMutableRawPointer(fileHandle)
}

internal func doomClose(filePointer: UnsafeMutableRawPointer?) {
    fclose(filePointer?.asFileHandle())
}

internal func doomRead(filePointer: UnsafeMutableRawPointer?, buffer: UnsafeMutableRawPointer?, count: Int32) -> Int32 {
    return Int32(fread(buffer, 1, Int(count), filePointer?.asFileHandle()))
}

internal func doomWrite(filePointer: UnsafeMutableRawPointer?, buffer: UnsafeRawPointer?, count: Int32) -> Int32 {
    return Int32(fwrite(buffer, 1, Int(count), filePointer?.asFileHandle()))
}

internal func doomSeek(filePointer: UnsafeMutableRawPointer?, offset: Int32, origin: doom_seek_t) -> Int32 {
    let seekVal = switch origin {
    case DOOM_SEEK_CUR: SEEK_CUR
    case DOOM_SEEK_END: SEEK_END
    case DOOM_SEEK_SET: SEEK_SET
    default: fatalError("Unknown file seek mode")
    }
    
    return fseek(filePointer?.asFileHandle(), Int(offset), seekVal)
}

internal func doomTell(filePointer: UnsafeMutableRawPointer?) -> Int32 {
    return Int32(ftell(filePointer?.asFileHandle()))
}

internal func doomEOF(filePointer: UnsafeMutableRawPointer?) -> Int32 {
    return Int32(feof(filePointer?.asFileHandle()))
}

internal func doomExit(exitCode: Int32) {
    if let exitCallback = DOOM.exitCallback {
        exitCallback(Int(exitCode))
    } else {
        fatalError("The game exited with code \(exitCode)")
    }
}

public enum DoomMouseButton {
	case left, right, middle
	
	func toDoomButton() -> doom_button_t {
		return switch self {
			case .left: DOOM_LEFT_BUTTON
			case .right: DOOM_RIGHT_BUTTON
			case .middle: DOOM_MIDDLE_BUTTON
		}
	}
}

public struct DOOM {
    @WrappedCString static public var wadDir = nil
    @WrappedCString static public var homeDir = nil
    static internal var startTime = DispatchTime.now()
    static public var exitCallback: ((Int) -> ())? = nil
	static private var defaultStrings = [String:UnsafeMutablePointer<CChar>]()
	
	public static func getDefaultWadDir() -> URL? {
		let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		let bundleIdentifier = Bundle.main.bundleIdentifier
		
		if let bundleIdentifier {
			let supportPath = appSupportDir[0].appendingPathComponent(bundleIdentifier)
			if let _ = try? FileManager.default.createDirectory(at: supportPath, withIntermediateDirectories: true) {
				return supportPath
			}
		}
		return nil
	}
    
    public static func initialize(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) {
        doom_set_print(doomPrint)
        doom_set_malloc(doomMalloc, doomFree)
        doom_set_getenv(doomGetEnv)
        doom_set_gettime(doomGetTime)
        doom_set_file_io(doomOpen, doomClose, doomRead, doomWrite, doomSeek, doomTell, doomEOF)
        doom_set_exit(doomExit)
        
        if wadDir == nil || homeDir == nil {
			if let defaultDir = getDefaultWadDir() {
				if homeDir == nil { homeDir = defaultDir.absoluteString }
				if wadDir == nil { wadDir = defaultDir.absoluteString }
			}
        }
        
        startTime = DispatchTime.now()
        doom_init(argc, argv, 0)
    }
    
    public static func update() {
        doom_update()
    }
    
    public static func getFrame() -> UnsafePointer<UInt8>? {
        return doom_get_framebuffer(4)
    }
    
    public static func getAudio() -> UnsafeMutablePointer<Int16> {
        return doom_get_sound_buffer()
    }
	
	public static func keyUp(key: Int) {
		doom_key_up(doom_key_t.init(Int32(key)))
	}
	
	public static func keyDown(key: Int) {
		doom_key_down(doom_key_t.init(Int32(key)))
	}
	
	public static func setDefault(option: String, value: Int32) {
		let optionCStr = option.toCStringPointer()
		doom_set_default_int(optionCStr, value)
		optionCStr.deallocate()
	}
	
	public static func setDefault(option: String, value: String) {
		let optionCStr = option.toCStringPointer()
		let valueCStr = option.toCStringPointer()
		doom_set_default_string(optionCStr, valueCStr)
		optionCStr.deallocate()
		
		if let cStr = defaultStrings[option] {
			cStr.deallocate()
		}
		
		defaultStrings[option] = valueCStr
	}
	
	public static func gameWantsMouseInput() -> Bool {
		let doomTrue = doom_boolean.init(rawValue: 1)
		return !(paused == doomTrue || menuactive == doomTrue || usergame != doomTrue)
	}
	
	public static func mouseMove(dx: Int32, dy: Int32) {
		doom_mouse_move(dx, dy)
	}
	
	public static func setMouseButton(_ button: DoomMouseButton, state: Bool) {
		let doomBtn = button.toDoomButton()
		if state {
			doom_button_down(doomBtn)
		} else {
			doom_button_up(doomBtn)
		}
	}
}
