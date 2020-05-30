//
//  AppDelegate.swift
//  XCDocumentation
//
//  Created by peter on 29.05.20.
//  Copyright © 2020 Peter Baumgartner. All rights reserved.
//

//----------------------------------------------------------------------------------------------------------------------
	
	
import Cocoa
//import SwiftUI


//----------------------------------------------------------------------------------------------------------------------
	
	
@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate
{

	var window: NSWindow!


//----------------------------------------------------------------------------------------------------------------------
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification)
	{
		if BXAppleScript.needsInstalling(for:"XCDocumentation")
		{
			self.installScript(self)
		}
//		// Create the SwiftUI view that provides the window contents
//
//		let contentView = ContentView()
//
//		// Create the window and set the content view
//
//		window = NSWindow(
//		    contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//		    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//		    backing: .buffered, defer: false)
//		window.center()
//		window.setFrameAutosaveName("Main Window")
//		window.contentView = NSHostingView(rootView: contentView)
//		window.makeKeyAndOrderFront(nil)
	}


	func applicationWillTerminate(_ aNotification: Notification)
	{
		// Insert code here to tear down your application
	}


//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: - Actions
	
	@IBAction func installScript(_ sender:AnyObject!)
	{
		try? BXAppleScript.installScript(named:"XCDocumentation")
	}
}


//----------------------------------------------------------------------------------------------------------------------
	
	
