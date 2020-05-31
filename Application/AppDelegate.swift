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

		self.installTemplates(self)
	}


	func applicationWillTerminate(_ notification:Notification)
	{
		// Insert code here to tear down your application
	}


//----------------------------------------------------------------------------------------------------------------------
	
	
	@IBAction func installScript(_ sender:AnyObject!)
	{
		try? BXAppleScript.installScript(named:"XCDocumentation")
	}
	
	
	@IBAction func openTemplateFolder(_ sender:AnyObject!)
	{
		let folderURL = self.templateDirectoryURL

		if !folderURL.exists
		{
			try? FileManager.default.createDirectory(at:folderURL, withIntermediateDirectories:true, attributes:nil)
		}
		
		NSWorkspace.shared.open(folderURL)
	}
	

	@IBAction func installTemplates(_ sender:AnyObject!)
	{
		guard let srcFolderURL = Bundle.main.url(forResource: "Templates", withExtension: nil) else { return }
		let dstFolderURL = self.templateDirectoryURL
		
		if !dstFolderURL.exists
		{
			try? FileManager.default.createDirectory(at:dstFolderURL, withIntermediateDirectories:true, attributes:nil)
		}
		
		if let urls = try? FileManager.default.contentsOfDirectory(at:srcFolderURL, includingPropertiesForKeys:[.contentModificationDateKey], options:[])
		{
			for srcFileURL in urls
			{
				let filename = srcFileURL.lastPathComponent
				let dstFileURL = dstFolderURL.appendingPathComponent(filename)
				var shouldInstall = true
				
				if let srcDate = srcFileURL.modificationDate, let dstDate = dstFileURL.modificationDate, srcDate <= dstDate
				{
					shouldInstall = false
				}
				
				if shouldInstall
				{
					try? FileManager.default.removeItem(at:dstFileURL)
					try? FileManager.default.copyItem(at:srcFileURL, to:dstFileURL)
				}
			}
		}
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	public var templateDirectoryURL : URL
	{
		let applicationSupportURL = URL(fileURLWithPath:"/Users/\(NSUserName())/Library/Application Support/com.boinx.XCDocumentation")
		let userTemplatesURL = applicationSupportURL.appendingPathComponent("Templates")
		return userTemplatesURL
	}

}


//----------------------------------------------------------------------------------------------------------------------
	
	
