//**********************************************************************************************************************
//
//  BXAppleScript.swift
//	Helper class for installing and running AppleScripts from sandboxed applications
//  Copyright ©2020 by IMAGINE GbR & Boinx Software International GmbH. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import AppKit
import Carbon


//----------------------------------------------------------------------------------------------------------------------
	
	
public class BXAppleScript
{
	private var script:NSUserAppleScriptTask
	
	public enum Error : Swift.Error
	{
		case missingScript
		case incorrectDirectory
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: -
	
	/// Returns a URL to the "Application Scripts" folder for the extension
	
	public class func scriptsDirectoryURL() throws -> URL
	{
		var scriptsDirectoryURL = try FileManager.default.url(for:.applicationScriptsDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
		
		if !scriptsDirectoryURL.path.hasSuffix(".Extension")
		{
			scriptsDirectoryURL = scriptsDirectoryURL.appendingPathExtension("Extension")
			
			if !FileManager.default.fileExists(atPath:scriptsDirectoryURL.path)
			{
				try FileManager.default.createDirectory(at:scriptsDirectoryURL, withIntermediateDirectories:true, attributes:nil)
			}
		}
		
		return scriptsDirectoryURL
	}
	
	
	/// Returns true if the script with the specified name needs to be installed
	
	public class func needsInstalling(for name:String) -> Bool
	{
		guard let srcURL = Bundle.main.url(forResource:name, withExtension:"scpt") else { return false }
		
		if let directoryURL = try? scriptsDirectoryURL()
		{
			let dstURL = directoryURL.appendingPathComponent(name).appendingPathExtension("scpt")
			
			if !dstURL.exists
			{
				return true
			}
			
			if let srcDate = srcURL.modificationDate, let dstDate = dstURL.modificationDate, srcDate > dstDate
			{
				return true
			}
			
			return false
		}
		
		return true
	}
	
	
	/// Installs the script with the specified name
	
	public class func installScript(named name:String) throws
	{
		guard let srcURL = Bundle.main.url(forResource:name, withExtension:"scpt") else { throw Error.missingScript }

		let directoryURL = try self.scriptsDirectoryURL()
//		let prompt = "Select Script Folder"
//		let message = "Please select the User > Library > Application Scripts > com.boinx.XCDocumentation.Extension folder"
//
//		try NSOpenPanel.selectFolder(url:directoryURL, promt:prompt, message:message)
//		{
//			(url:URL) throws -> Void in
//
//			if url == directoryURL
//			{
				let dstURL = directoryURL.appendingPathComponent(name).appendingPathExtension("scpt")
				try? FileManager.default.removeItem(at:dstURL)
				try FileManager.default.copyItem(at:srcURL, to:dstURL)
//			}
//			else
//			{
//				throw Error.incorrectDirectory
//			}
//		}
	}
	

//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: -
	
	
	/// Loads and instantiates the script with the specified name
	
	public init(named name:String) throws
	{
		let scriptsDirectoryURL = try FileManager.default.url(for:.applicationScriptsDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
		let scriptURL = scriptsDirectoryURL.appendingPathComponent(name).appendingPathExtension("scpt")
		self.script = try NSUserAppleScriptTask(url:scriptURL)
	}
    
    
//----------------------------------------------------------------------------------------------------------------------
	
	
	/// Executes the function with the specified name and argument.
	/// - parameter functionName: The name of the AppleScript function
	/// - parameter argument: This String is passed to the function as the first argument
	/// - parameter completionHandler: This closure returns the String result or an error if the script failed
	
	public func run(function functionName:String? = nil, argument:String? = nil, completionHandler:@escaping (String?,Swift.Error?)->Void)
	{
		var functionDesc:NSAppleEventDescriptor? = nil
		
		if let functionName = functionName
		{
			var psn = ProcessSerialNumber(highLongOfPSN:0, lowLongOfPSN:UInt32(kCurrentProcess))
			
			let target = NSAppleEventDescriptor(
				descriptorType: typeProcessSerialNumber,
				bytes: &psn,
				length: MemoryLayout<ProcessSerialNumber>.size)

			functionDesc = NSAppleEventDescriptor(
				eventClass: UInt32(kASAppleScriptSuite),
				eventID: UInt32(kASSubroutineEvent),
				targetDescriptor: target,
				returnID: Int16(kAutoGenerateReturnID),
				transactionID: Int32(kAnyTransactionID))

			let function = NSAppleEventDescriptor(string:functionName)
			
			functionDesc?.setParam(function, forKeyword:AEKeyword(keyASSubroutineName))

			if let argument = argument
			{
				let arg1 = NSAppleEventDescriptor(string:argument)
				let args = NSAppleEventDescriptor.list()
				args.insert(arg1, at:1) // Index starts at 1!
				functionDesc?.setParam(args, forKeyword:AEKeyword(keyDirectObject))
			}
		}

		self.script.execute(withAppleEvent:functionDesc)
		{
			result,error in

			if let error = error
			{
				NSLog("Script error: \(error)")
				completionHandler(nil,error)
			}
			else if let stringResult = result?.stringValue
			{
				completionHandler(stringResult,nil)
			}
			else
			{
				NSLog("got nil result")
				completionHandler(nil,nil)
			}
		}
	}
}


//----------------------------------------------------------------------------------------------------------------------
	
