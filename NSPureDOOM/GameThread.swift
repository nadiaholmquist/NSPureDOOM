//
//  GameThread.swift
//  NSPureDOOM
//
//  Created by Nadia on 19/11/2023.
//

import Foundation
import Cocoa
import CoreGraphics
import SwiftPureDOOM
import AudioToolbox
import Carbon.HIToolbox

class GameThread : Thread {
    public let gameSemaphore = DispatchSemaphore(value: 1)
    private let audioPlayer = AudioPlayer()
    private var audioBuffer: UnsafeMutablePointer<Int16>? = nil
    private var haveSamples = 0
	private var shouldRun = true
    
    override init() {
        super.init()
        audioPlayer.callback = { wantSamples in
            if wantSamples > self.haveSamples {
                self.gameSemaphore.wait()
                defer { self.gameSemaphore.signal() }
                self.audioBuffer = DOOM.getAudio()
                self.haveSamples = 1024
            }
            
            let currBuf = self.audioBuffer
            let newBuf = currBuf?.advanced(by: wantSamples)
            self.audioBuffer = newBuf
            self.haveSamples -= wantSamples
            
            return (currBuf!, wantSamples)
        }
    }
    
    override func main() {
		DOOM.setDefault(option: "key_up", value: DOOM.getDoomKey(kVK_ANSI_W)!)
		DOOM.setDefault(option: "key_down", value: DOOM.getDoomKey(kVK_ANSI_S)!)
		DOOM.setDefault(option: "key_strafeleft", value: DOOM.getDoomKey(kVK_ANSI_A)!)
		DOOM.setDefault(option: "key_straferight", value: DOOM.getDoomKey(kVK_ANSI_D)!)
		DOOM.setDefault(option: "key_fire", value: DOOM.getDoomKey(kVK_Space)!)
		DOOM.setDefault(option: "key_use", value: DOOM.getDoomKey(kVK_ANSI_E)!)
		
		DOOM.exitCallback = { exitCode in
			print("DOOM exited with code \(exitCode)")
			self.shouldRun = false
			
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: Notification.Name("GameExit"), object: self)
			}
			
			Thread.exit()
		}
		
        DOOM.initialize(argc: CommandLine.argc, argv: CommandLine.unsafeArgv)
        
        while shouldRun {
            gameSemaphore.wait()
            DOOM.update()
            gameSemaphore.signal()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("GameFrame"), object: self)
            }
            
            Thread.sleep(forTimeInterval: 1 / 70)
        }
    }
    
    func getFramebuffer() -> CGImage? {
        gameSemaphore.wait()
        defer { gameSemaphore.signal() }
        
        let frame = DOOM.getFrame()
        let rawPtr = UnsafeRawPointer(OpaquePointer(frame))
        let data = NSData(bytes: rawPtr!, length: 320*200*4)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let provider = CGDataProvider(data: data) else {fatalError()}
        
        let image = CGImage(width: 320, height: 200, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 320*4, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        
        guard let image else { fatalError() }
        
        return image
    }
	
	func setKey(_ key: UInt16, pressed: Bool) {
		if pressed {
			DOOM.macKeyDown(Int(key))
		} else {
			DOOM.macKeyUp(Int(key))
		}
	}
	
	func gameWantsMouseInput() -> Bool {
		return DOOM.gameWantsMouseInput()
	}
	
	func stop() {
		shouldRun = false
	}
	
	func mouseMove(dx: Int, dy: Int) {
		DOOM.mouseMove(dx: Int32(dx), dy: Int32(dy))
	}
	
	func setMouseButton(_ button: DoomMouseButton, state: Bool) {
		DOOM.setMouseButton(button, state: state)
	}
}
