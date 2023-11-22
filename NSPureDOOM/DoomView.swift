//
//  DoomView.swift
//  NSPureDOOM
//
//  Created by Nadia on 18/11/2023.
//

import Cocoa

class DoomView: NSView {
    public var framebuffer: CGImage? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current else { return }
        
        context.cgContext.setFillColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        context.cgContext.fill([frame])
        context.imageInterpolation = .none
        
        if let framebuffer {
            let aspect = frame.width / frame.height
			let gameAspect: CGFloat = 8.0/5.0
            let gameWidth, gameHeight: CGFloat
			var gameRect: NSRect = .infinite
            
            if aspect >= gameAspect {
                let center = frame.width / 2
                gameHeight = frame.height
				gameWidth = gameHeight * gameAspect
                gameRect = .init(x: center - (gameWidth / 2), y: 0, width: gameWidth, height: gameHeight)
            } else {
                let center = frame.height / 2
                gameWidth = frame.width
				gameHeight = gameWidth / gameAspect
				gameRect = .init(x: 0, y: center - (gameHeight / 2), width: gameWidth, height: gameHeight)
            }
			
			context.cgContext.draw(framebuffer, in: gameRect)
        }
    }
    
}
