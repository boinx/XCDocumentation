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


//----------------------------------------------------------------------------------------------------------------------
	
	
// Find details at documentation://Architecture.pdf to get the big picture.

// documentation://Test.pages
// documentation://Bla.pdf


//----------------------------------------------------------------------------------------------------------------------
	
	
class SourceEditorCommand : NSObject, XCSourceEditorCommand
{

	enum Error : Swift.Error
	{
		case invalidCommand
	}
	
	
//----------------------------------------------------------------------------------------------------------------------
	
	
	/// This is the entry point when menu commands are selected in the Xcode editor menu
	
    func perform(with invocation:XCSourceEditorCommandInvocation, completionHandler:@escaping (Swift.Error?)->Void) -> Void
    {
		let identifier = invocation.commandIdentifier
		let buffer = invocation.buffer
		
		// Create a new documentation file and insert a documentation:// comment at the current selection
		
		if identifier == "com.boinx.XCDocumentation.Extension.new"
		{
			self.newDocumentation()
			{
				relativePath,error in
				
				if relativePath?.count ?? 0 > 1
				{
					self.insertDocumentationComment(with:relativePath, in:buffer)
				}
				completionHandler(error)
			}
		}
		
		// Open existing documentation
		
		else if identifier == "com.boinx.XCDocumentation.Extension.open"
		{
			let line = self.selectedLine(for:invocation)
			
			guard let documentationURL = self.documentationURL(in:line) else
			{
				completionHandler(nil)
				return
			}
			
			guard let relativePath = self.relativePath(in:documentationURL) else
			{
				completionHandler(nil)
				return
			}
			
			self.editDocumentation(for:relativePath)
			{
				_,error in
				completionHandler(error)
			}
		}
		
		// Insert a documentation:// comment for an existing file at the current selection
		
		else if identifier == "com.boinx.XCDocumentation.Extension.select"
		{
			self.selectDocumentation()
			{
				relativePath,error in
				self.insertDocumentationComment(with:relativePath, in:buffer)
				completionHandler(error)
			}
		}
		
		// Unknown command, but we still have to call the completion handler or we'll hand Xcode
		
		else
		{
			completionHandler(Error.invalidCommand)
		}
    }
    
    
//----------------------------------------------------------------------------------------------------------------------
	
	
	// MARK: -
	

	/// Lets the user create a new the documentation file.
	/// - Returns: The relative path to the documentation file
	
	func newDocumentation(completionHandler:@escaping (String?,Swift.Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			let templatePath = "/Users/\(NSUserName())/Library/Application Support/com.boinx.XCDocumentation/Templates"
			
			script.run(function:"newDocumentation", argument:templatePath)
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
	
	
	/// Shows the documentation file for the specified relativePath in Xcode
	/// - Returns: The absolute path to the documentation file
	
	func showDocumentation(for relativePath:String, completionHandler:@escaping (String?,Swift.Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"showDocumentation", argument:relativePath)
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
	
	
	/// Opens the documentation file for the specified relativePath in its native editor app
	/// - Returns: The absolute path to the documentation file
	
	func editDocumentation(for relativePath:String, completionHandler:@escaping (String?,Swift.Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"editDocumentation", argument:relativePath)
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
	
	func selectDocumentation(completionHandler:@escaping (String?,Swift.Error?)->Void)
    {
		do
		{
			let script = try BXAppleScript(named:"XCDocumentation")
			
			script.run(function:"selectDocumentation", argument:nil)
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
	
	
	// MARK: - Helpers
	
	
    func selectedLine(for invocation:XCSourceEditorCommandInvocation) -> String
    {
		guard let lines = invocation.buffer.lines as? [String] else { return "" }
		guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else { return "" }

		let row = selection.start.line
		let col1 = selection.start.column
		let col2 = selection.end.column

		print("row=\(row)  col1=\(col1)  col2=\(col2)")
		
		let line = lines[row]
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
	
	
	func documentationURL(in line:String) -> String?
	{
		let pattern = "documentation://([^\\s]*)"
		
		if let regex = try? NSRegularExpression(pattern:pattern,options:.caseInsensitive)
		{
			var match:NSTextCheckingResult? = nil
			
			repeat
			{
				match = regex.firstMatch(in:line, options:[], range:NSMakeRange(0,line.count))
				
				if let match = match, match.numberOfRanges > 0
				{
					let range = match.range(at:0)
					
					if range.location != NSNotFound, let r = Range(range, in:line)
					{
						let string = String(line[r])
						return string
					}
				}
			}
			while match != nil
		}

		return nil
	}
	
	
	func relativePath(in documentationURL:String?) -> String?
	{
		guard let documentationURL = documentationURL else { return nil }
		guard documentationURL.hasPrefix("documentation://") else { return nil }
		let relativePath = documentationURL.replacingOccurrences(of:"documentation://", with:"")
		return relativePath.replacingOccurrences(of:"%20", with:" ")
	}
	

//----------------------------------------------------------------------------------------------------------------------
	
	
	/// Creates a "documentation://relativePath" comment and inserts it in the source code at the current cursor position
	
	func insertDocumentationComment(with relativePath:String?, in buffer:XCSourceTextBuffer)
	{
		guard let relativePath = relativePath else { return }
		guard let lines = buffer.lines as? [String] else { return }
		guard let selection = buffer.selections.firstObject as? XCSourceTextRange else { return }
		
		let row = selection.start.line
		let col = selection.start.column
		let line = lines[row] as NSString
		
		// Insert the comment at the current cursor position
			
		let comment = "documentation://\(relativePath.replacingOccurrences(of:" ", with:"%20"))"
		let newLine = line.replacingCharacters(in:NSMakeRange(col,0), with:comment)
		buffer.lines[row] = newLine as NSString
		
		// Select the new comment
		
		let n = comment.count
		selection.start.column = col
		selection.end.column = col+n
	}
}


//----------------------------------------------------------------------------------------------------------------------
	
