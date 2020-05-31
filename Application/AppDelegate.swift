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

		// at fisrt run this will install the templates shipped with the bundle
		do
		{
			_ = try self.templateDirectoryURL()
		}
		catch let error
		{
			print(error)
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
	
	@IBAction func openTemplateFolder(_ sender:AnyObject!)
	{
		if let templateDirectoryURL = try? templateDirectoryURL()
		{
			NSWorkspace.shared.open(templateDirectoryURL)
		}
	}
	
	public func templateDirectoryURL() throws -> URL
	{
		let applicationSupportURL = URL(fileURLWithPath:"/Users/\(NSUserName())/Library/Application Support/com.boinx.XCDocumentation")
		
		let userTemplatesURL = applicationSupportURL.appendingPathComponent("Templates")
		
		if !FileManager.default.fileExists(atPath:userTemplatesURL.path)
		{
			// try FileManager.default.createDirectory(at:userTemplatesURL, withIntermediateDirectories:true, attributes:nil)
			
			if let bundleTemplatesURL = Bundle.main.url(forResource: "Templates", withExtension: nil)
			{
				try FileManager.default.copyItem(at: bundleTemplatesURL, to: userTemplatesURL)
			}
		}
		
		return userTemplatesURL
	}
	

}


//----------------------------------------------------------------------------------------------------------------------
	
	
