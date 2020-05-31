//**********************************************************************************************************************
//
//  NSOpenPanel+selectFolder.swift
//	Convenience function to select a folder
//  Copyright ©2020 by IMAGINE GbR & Boinx Software International GmbH. All rights reserved.
//
//**********************************************************************************************************************


import AppKit


//----------------------------------------------------------------------------------------------------------------------
	
	
extension NSOpenPanel
{
	public class func selectFolder(url:URL? = nil, promt:String? = nil, message:String? = nil, completionHandler:(URL) throws ->Void) rethrows
	{
		let panel = NSOpenPanel()
		panel.directoryURL = url
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.prompt = promt
		panel.message = message
		
		let button = panel.runModal()
		
		if button == .OK, let url = panel.url
		{
			try completionHandler(url)
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
	
