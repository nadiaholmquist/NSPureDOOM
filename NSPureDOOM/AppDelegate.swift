//
//  AppDelegate.swift
//  NSPureDOOM
//
//  Created by Nadia on 18/11/2023.
//

import Foundation
import Cocoa
import SwiftPureDOOM

let validDoomWads = [
	"doom2f.wad", "doom2.wad", "plutonia.wad", "tnt.wad", "doomu.wad", "doom.wad", "doom1.wad"
]

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet var gameWindowController: GameWindowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		guard let wadURL = DOOM.getDefaultWadDir() else {
			fatalError("Couldn't find the WAD dir. This shouldn't ever happen!")
		}
		
		let foundWad = validDoomWads.contains { wad in
			FileManager.default.fileExists(atPath: wadURL.appendingPathComponent(wad).path)
		}
		
		if !foundWad {
			let alert = NSAlert()
			alert.messageText = "Could not find any DOOM WADs"
			alert.informativeText = "You need a DOOM or DOOM 2 WAD to run NSPureDOOM. Please provide a WAD file and relaunch the app."
			alert.alertStyle = .critical
			alert.addButton(withTitle: "Open WAD Directory")
			alert.addButton(withTitle: "Quit")
			let response = alert.runModal()
			
			if response == .alertFirstButtonReturn {
				NSWorkspace.shared.open(wadURL)
			}
			
			NSApplication.shared.terminate(self)
		}
		
		gameWindowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		true
	}
}
