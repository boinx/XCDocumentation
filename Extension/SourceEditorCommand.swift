//
//  SourceEditorCommand.swift
//  Extension
//
//  Created by peter on 29.05.20.
//  Copyright © 2020 Peter Baumgartner. All rights reserved.
//

import Foundation
import XcodeKit
import AppKit

// Find details at documentation://Architecture.pdf to get the big picture.


//----------------------------------------------------------------------------------------------------------------------
	
	
class SourceEditorCommand : NSObject, XCSourceEditorCommand
{
    func perform(with invocation:XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?)->Void ) -> Void
    {
		let relativePath = self.selectedString(for:invocation)
		
		self.openDocumentation(for:relativePath)
		{
			absolutePath,error in
			
			if let error = error
			{
				NSLog("ERROR trying to open documentation://\(relativePath):\n\(error)")
			}
			else if let absolutePath = absolutePath
			{
				NSLog("Opened file at \(absolutePath)")
			}
			
			completionHandler(error)
		}
    }
    
    
//----------------------------------------------------------------------------------------------------------------------
	
	
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
	
    
//----------------------------------------------------------------------------------------------------------------------
	
	
     func openDocumentation(for path:String, completionHandler:@escaping (String?,Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"openDocumentation", argument:path)
			{
				result,error in

				if let error = error
				{
					print("Script error: \(error)")
					completionHandler(nil,error)
				}
				else if let result = result
				{
					print("result: \(result)")
					completionHandler(result,nil)
				}
				else
				{
					print("got nil result")
					completionHandler(nil,nil)
				}
			}
		}
		catch let error
		{
			print("Error: \(error)")
			completionHandler(nil,error)
		}
    }


   /// Executes an AppleScript to get the value of $SRCROOT for the current Xcode project, i.e. the project that contains the file that is currently
    /// being edited.
    
    func getSRCROOT(completionHandler:@escaping (String?,Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"SRCROOT", argument:nil)
			{
				result,error in

				if let error = error
				{
					print("Script error: \(error)")
					completionHandler(nil,error)
				}
				else if let result = result
				{
					print("result: \(result)")
					completionHandler(result,nil)
				}
				else
				{
					print("got nil result")
					completionHandler(nil,nil)
				}
			}
		}
		catch let error
		{
			print("Error: \(error)")
			completionHandler(nil,error)
		}
    }
   
   
//----------------------------------------------------------------------------------------------------------------------
	
	
    func revealInXcode(url:URL)
    {
		if let xcodeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier:"com.apple.dt.Xcode")
		{
			print("xcodeURL: \(xcodeURL)")
			print("fileURL: \(url)")
			let config = NSWorkspace.OpenConfiguration()
			config.promptsUserIfNeeded = true
			NSWorkspace.shared.open([url], withApplicationAt:xcodeURL, configuration:config)
		}
    }
    
}


//----------------------------------------------------------------------------------------------------------------------
	
	
