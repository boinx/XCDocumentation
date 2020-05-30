//**********************************************************************************************************************
//
//  SourceEditorCommand.swift
//	Implementation for the editor commands
//  Copyright ©2020 by IMAGINE GbR & Boinx Software International GmbH. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import XcodeKit
import AppKit


// Find details at documentation://Architecture.pdf to get the big picture.


//----------------------------------------------------------------------------------------------------------------------
	
	
class SourceEditorCommand : NSObject, XCSourceEditorCommand
{

	/// This is the entry point when menu commands are selected in the Xcode editor menu
	
    func perform(with invocation:XCSourceEditorCommandInvocation, completionHandler:@escaping (Error?)->Void) -> Void
    {
		let identifier = invocation.commandIdentifier
		
		// Open existing documentation
		
		if identifier == "com.boinx.XCDocumentation.Extension.open"
		{
			let relativePath = self.selectedString(for:invocation)
			
			self.openDocumentation(for:relativePath)
			{
				_,error in
				completionHandler(error)
			}
		}
		
		// Create a new documentation file and insert the text at the current selection
		
		else if identifier == "com.boinx.XCDocumentation.Extension.new"
		{
			self.newDocumentation()
			{
				relativePath,error in
				completionHandler(error)
			}
		}
		
		// Insert a documentation:// comment for an existing file at the current selection
		
		else if identifier == "com.boinx.XCDocumentation.Extension.select"
		{
			self.selectDocumentation()
			{
				relativePath,error in
				completionHandler(error)
			}
		}
    }
    
    
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: -
	
	/// Opens the documentation file for the specified relativePath
	/// - Returns: The absolute path to the documentation file
	
	func openDocumentation(for relativePath:String, completionHandler:@escaping (String?,Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"openDocumentation", argument:relativePath)
			{
				result,error in

				if let error = error
				{
					NSLog("SCRIPT ERROR: \(error)")
				}
				else if let result = result
				{
					NSLog("result = \(result)")
				}
				
				completionHandler(result,error)
			}
		}
		catch let error
		{
			NSLog("ERROR: \(error)")
			completionHandler(nil,error)
		}
    }


//----------------------------------------------------------------------------------------------------------------------
	
	
	/// Lets the user create a new the documentation file.
	/// - Returns: The relative path to the documentation file
	
	func newDocumentation(completionHandler:@escaping (String?,Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"newDocumentation", argument:nil)
			{
				result,error in

				if let error = error
				{
					NSLog("SCRIPT ERROR: \(error)")
				}
				else if let result = result
				{
					NSLog("result = \(result)")
				}
				
				completionHandler(result,error)
			}
		}
		catch let error
		{
			NSLog("ERROR: \(error)")
			completionHandler(nil,error)
		}
    }


//----------------------------------------------------------------------------------------------------------------------
	
	
	/// Lets the user select an existing documentation file.
	/// - Returns: The relative path to the documentation file
	
	func selectDocumentation(completionHandler:@escaping (String?,Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"newDocumentation", argument:nil)
			{
				result,error in

				if let error = error
				{
					NSLog("SCRIPT ERROR: \(error)")
				}
				else if let result = result
				{
					NSLog("result = \(result)")
				}
				
				completionHandler(result,error)
			}
		}
		catch let error
		{
			NSLog("ERROR: \(error)")
			completionHandler(nil,error)
		}
    }


//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: -
	
    func selectedLine(for invocation:XCSourceEditorCommandInvocation) -> String
    {
		guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return "" }

		let row = selection.start.line
		let col1 = selection.start.column
		let col2 = selection.end.column

		print("row=\(row)  col1=\(col1)  col2=\(col2)")
		
		let line = invocation.buffer.lines[row] as? String ?? ""
		print("line=\(line)")
		return line
	}
    
    
	func selectedString(for invocation:XCSourceEditorCommandInvocation) -> String
	{
		guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return "" }

		let row = selection.start.line
		let col1 = selection.start.column
		let col2 = selection.end.column

		if let line = invocation.buffer.lines[row] as? NSString
		{
			let range = NSMakeRange(col1,col2-col1)
			let string = line.substring(with:range)
			return string as String
		}
		
		return ""
	}
}


//----------------------------------------------------------------------------------------------------------------------
	
	
