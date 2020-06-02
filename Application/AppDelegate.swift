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
	
	
