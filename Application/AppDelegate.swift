//**********************************************************************************************************************
//
//  AppDelegate.swift
//	General application behavior
//  Copyright ©2020 by IMAGINE GbR & Boinx Software International GmbH. All rights reserved.
//
//**********************************************************************************************************************
	
	
import Cocoa


//----------------------------------------------------------------------------------------------------------------------
	
	
@NSApplicationMain class AppDelegate : NSObject, NSApplicationDelegate
{

	func applicationDidFinishLaunching(_ notification:Notification)
	{
		if BXAppleScript.needsInstalling(for:"XCDocumentation")
		{
			self.installScript(self)
		}
	}


	func applicationWillTerminate(_ notification:Notification)
	{
		// Insert code here to tear down your application
	}


	@IBAction func installScript(_ sender:AnyObject!)
	{
		try? BXAppleScript.installScript(named:"XCDocumentation")
	}
	
}


//----------------------------------------------------------------------------------------------------------------------
	
	
