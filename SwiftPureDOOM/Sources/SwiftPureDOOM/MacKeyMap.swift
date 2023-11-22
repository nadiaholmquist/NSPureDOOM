#if os(macOS)

import Foundation
import CPureDOOM
import Carbon

extension DOOM {
	static let carbonKeyMap: [Int:doom_key_t] = [
		kVK_Tab: DOOM_KEY_TAB,
		kVK_Return: DOOM_KEY_ENTER,
		kVK_Escape: DOOM_KEY_ESCAPE,
		kVK_Space: DOOM_KEY_SPACE,
		kVK_ANSI_Quote: DOOM_KEY_APOSTROPHE,
		kVK_ANSI_KeypadMultiply: DOOM_KEY_MULTIPLY,
		kVK_ANSI_Comma: DOOM_KEY_COMMA,
		kVK_ANSI_Minus: DOOM_KEY_MINUS,
		kVK_ANSI_Period: DOOM_KEY_PERIOD,
		kVK_ANSI_Slash: DOOM_KEY_SLASH,
		kVK_ANSI_0: DOOM_KEY_0,
		kVK_ANSI_1: DOOM_KEY_1,
		kVK_ANSI_2: DOOM_KEY_2,
		kVK_ANSI_3: DOOM_KEY_3,
		kVK_ANSI_4: DOOM_KEY_4,
		kVK_ANSI_5: DOOM_KEY_5,
		kVK_ANSI_6: DOOM_KEY_6,
		kVK_ANSI_7: DOOM_KEY_7,
		kVK_ANSI_8: DOOM_KEY_8,
		kVK_ANSI_9: DOOM_KEY_9,
		kVK_ANSI_Semicolon: DOOM_KEY_SEMICOLON,
		kVK_ANSI_Equal: DOOM_KEY_EQUALS,
		kVK_ANSI_LeftBracket: DOOM_KEY_LEFT_BRACKET,
		kVK_ANSI_RightBracket: DOOM_KEY_RIGHT_BRACKET,
		kVK_ANSI_A: DOOM_KEY_A,
		kVK_ANSI_B: DOOM_KEY_B,
		kVK_ANSI_C: DOOM_KEY_C,
		kVK_ANSI_D: DOOM_KEY_D,
		kVK_ANSI_E: DOOM_KEY_E,
		kVK_ANSI_F: DOOM_KEY_F,
		kVK_ANSI_G: DOOM_KEY_G,
		kVK_ANSI_H: DOOM_KEY_H,
		kVK_ANSI_I: DOOM_KEY_I,
		kVK_ANSI_J: DOOM_KEY_J,
		kVK_ANSI_K: DOOM_KEY_K,
		kVK_ANSI_L: DOOM_KEY_L,
		kVK_ANSI_M: DOOM_KEY_M,
		kVK_ANSI_N: DOOM_KEY_N,
		kVK_ANSI_O: DOOM_KEY_O,
		kVK_ANSI_P: DOOM_KEY_P,
		kVK_ANSI_Q: DOOM_KEY_Q,
		kVK_ANSI_R: DOOM_KEY_R,
		kVK_ANSI_S: DOOM_KEY_S,
		kVK_ANSI_T: DOOM_KEY_T,
		kVK_ANSI_U: DOOM_KEY_U,
		kVK_ANSI_V: DOOM_KEY_V,
		kVK_ANSI_W: DOOM_KEY_W,
		kVK_ANSI_X: DOOM_KEY_X,
		kVK_ANSI_Y: DOOM_KEY_Y,
		kVK_ANSI_Z: DOOM_KEY_Z,
		kVK_Delete: DOOM_KEY_BACKSPACE,
		kVK_Control: DOOM_KEY_CTRL,
		kVK_RightControl: DOOM_KEY_CTRL,
		kVK_LeftArrow: DOOM_KEY_LEFT_ARROW,
		kVK_UpArrow: DOOM_KEY_UP_ARROW,
		kVK_RightArrow: DOOM_KEY_RIGHT_ARROW,
		kVK_DownArrow: DOOM_KEY_DOWN_ARROW,
		kVK_Shift: DOOM_KEY_SHIFT,
		kVK_RightShift: DOOM_KEY_SHIFT,
		kVK_Option: DOOM_KEY_ALT,
		kVK_RightOption: DOOM_KEY_ALT,
		kVK_F1: DOOM_KEY_F1,
		kVK_F2: DOOM_KEY_F2,
		kVK_F3: DOOM_KEY_F3,
		kVK_F4: DOOM_KEY_F4,
		kVK_F5: DOOM_KEY_F5,
		kVK_F6: DOOM_KEY_F6,
		kVK_F7: DOOM_KEY_F7,
		kVK_F8: DOOM_KEY_F8,
		kVK_F9: DOOM_KEY_F9,
		kVK_F10: DOOM_KEY_F10,
		kVK_F11: DOOM_KEY_F11,
		kVK_F12: DOOM_KEY_F12,
		kVK_F15: DOOM_KEY_PAUSE,
	]
	
	public static func macKeyUp(_ keyCode: Int) {
		if let doomKey = carbonKeyMap[keyCode] {
			doom_key_up(doomKey)
		}
	}
	
	public static func macKeyDown(_ keyCode: Int) {
		if let doomKey = carbonKeyMap[keyCode] {
			doom_key_down(doomKey)
		}
	}
	
	public static func getDoomKey(_ keyCode: Int) -> Int32? {
		return carbonKeyMap[keyCode]?.rawValue
	}
}

#endif
