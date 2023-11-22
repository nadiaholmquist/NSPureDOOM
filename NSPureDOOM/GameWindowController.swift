//
//  GameWindowController.swift
//  NSPureDOOM
//
//  Created by Nadia on 21/11/2023.
//

import Cocoa
import Carbon.HIToolbox

class GameWindowController: NSWindowController, NSWindowDelegate {
	override var windowNibName: NSNib.Name? { "GameWindow" }
	var gameThread: GameThread!
	private var shouldCaptureMouse = false
	private var mouseRect: NSView.TrackingRectTag? = nil
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		gameThread.start()
		
		window!.makeFirstResponder(self)
		//mouseRect = window!.contentView?.addTrackingRect(.infinite, owner: self, userData: nil, assumeInside: false)
		window!.contentView?.addTrackingArea(NSTrackingArea(rect: .infinite, options: .mouseMoved.union(.activeInKeyWindow), owner: self))
		
		NotificationCenter.default.addObserver(forName: Notification.Name("GameFrame"), object: nil, queue: nil) { notification in
			guard let doomView = self.window?.contentView as? DoomView else { return }
			
			doomView.framebuffer = self.gameThread.getFramebuffer()
			doomView.needsDisplay = true
			
			let wantsCapture = self.gameThread.gameWantsMouseInput()
			guard let window = self.window else { return }
			
			if wantsCapture && !self.shouldCaptureMouse {
				if window.isKeyWindow {
					self.setMouseCapture(true)
				}
			} else if !wantsCapture && self.shouldCaptureMouse {
				self.setMouseCapture(false)
			}
		}
		
		NotificationCenter.default.addObserver(forName: Notification.Name("GameExit"), object: nil, queue: nil) { notification in
			self.window?.close()
		}
		
		window?.makeKeyAndOrderFront(self)
    }
	
	override func windowWillLoad() {
		gameThread = GameThread()
	}
	
	func windowWillClose(_ notification: Notification) {
		gameThread.stop()
	}
	
	override func keyDown(with event: NSEvent) {
		gameThread.setKey(event.keyCode, pressed: true)
	}
	
	override func keyUp(with event: NSEvent) {
		gameThread.setKey(event.keyCode, pressed: false)
	}
	
	override func flagsChanged(with event: NSEvent) {
		let flag: NSEvent.ModifierFlags
		
		switch Int(event.keyCode) {
			case kVK_Control, kVK_RightControl: flag = .control
			case kVK_Option, kVK_RightOption: flag = .option
			case kVK_Command, kVK_RightCommand: flag = .command
			case kVK_Shift, kVK_RightShift: flag = .shift
			default: return
		}
		
		gameThread.setKey(event.keyCode, pressed: event.modifierFlags.contains(flag))
	}

	func windowDidResignKey(_ notification: Notification) {
		setMouseCapture(false)
	}
	
	override func mouseUp(with event: NSEvent) {
		gameThread.setMouseButton(.left, state: false)
	}
	
	override func mouseDown(with event: NSEvent) {
		gameThread.setMouseButton(.left, state: true)
	}
	
	override func rightMouseUp(with event: NSEvent) {
		gameThread.setMouseButton(.right, state: false)
	}
	
	override func rightMouseDown(with event: NSEvent) {
		gameThread.setMouseButton(.left, state: true)
	}
	
	override func mouseMoved(with event: NSEvent) {
		handleMouseMove(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		handleMouseMove(with: event)
	}
	
	override func rightMouseDragged(with event: NSEvent) {
		handleMouseMove(with: event)
	}
	
	override func otherMouseDragged(with event: NSEvent) {
		handleMouseMove(with: event)
	}
	
	func handleMouseMove(with event: NSEvent) {
		gameThread.mouseMove(dx: Int(event.deltaX.rounded()) * 2, dy: Int(event.deltaY.rounded()) * 2)
	}
	
	func setMouseCapture(_ capture: Bool) {
		shouldCaptureMouse = capture
		
		if capture {
			CGAssociateMouseAndMouseCursorPosition(.zero)
			NSCursor.hide()
			CGWarpMouseCursorPosition(CGPoint(x: window!.frame.midX, y: window!.frame.midY))
		} else {
			CGAssociateMouseAndMouseCursorPosition(.max)
			NSCursor.unhide()
		}
	}
	
	deinit {
		gameThread.stop()
	}
}
