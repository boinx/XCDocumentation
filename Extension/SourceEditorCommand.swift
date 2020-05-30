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
//		guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else
//		{
//			completionHandler( NSError(
//				domain: "com.boinx.XCDocumentation",
//				code: -1,
//				userInfo: [NSLocalizedDescriptionKey:"XCDocumentation requires a text selection"]))
//				
//			return
//		}
		
//		let row = selection.start.line
//		let col1 = selection.start.column
//		let col2 = selection.end.column
		let str = self.selectedString(for:invocation)
		
		self.openDocumentation(for:str)
		{
			result,error in
		}
		
//		print("\n")
//		print("row=\(row)  col1=\(col1)  col2=\(col2)  string = '\(str)'")
//
//		self.getSRCROOT()
//		{
//			srcroot,error in
//
//			if let error = error
//			{
//				print("error = \(error)")
//				completionHandler(error)
//			}
//			else if let SRCROOT = srcroot
//			{
//				print("$SRCROOT = \(SRCROOT)")
//
//				let string = self.selectedString(for:invocation)
//				print("string = \(string)")
//
//				let fileURL = URL(fileURLWithPath:SRCROOT)
//					.appendingPathComponent("Documentation")
//					.appendingPathComponent(string)
//
//				print("fileURL = \(fileURL)")
//				self.revealInXcode(url:fileURL)
//				completionHandler(nil)
//			}
//			else
//			{
//				completionHandler(nil)
//			}
//		}
		
//		let srcroot =
//		let index = selection.start.line
//		guard let line = invocation.buffer.lines[index] as? NSString else
//		{
//			completionHandler( NSError(
//				domain: "com.boinx.XCDocumentation",
//				code: -2,
//				userInfo: [NSLocalizedDescriptionKey:"Couldn't access text of selected line"]))
//
//			return
//		}
//
//		let env = ProcessInfo.processInfo.environment
//		let envStr = "Extension environment: \(env)"
//		invocation.buffer.lines.replaceObject(at: index, with:envStr)
//
//        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
//
//        completionHandler(nil)
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
	
	
