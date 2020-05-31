//**********************************************************************************************************************
//
//  SourceEditorExtension.swift
//	Main entry point for the Xcode editor extension
//  Copyright ©2020 by IMAGINE GbR & Boinx Software International GmbH. All rights reserved.
//
//**********************************************************************************************************************
	
	
import Foundation
import XcodeKit


//----------------------------------------------------------------------------------------------------------------------
	

// When the extension doesn't get loaded by the system type the following command into terminal:
//
//	  $ PATH=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support:"$PATH"
//	  $ lsregister -f /Applications/Xcode.app
//
// More info at https://github.com/nicklockwood/SwiftFormat/issues/494


//----------------------------------------------------------------------------------------------------------------------
	

class SourceEditorExtension : NSObject, XCSourceEditorExtension
{
    func extensionDidFinishLaunching()
    {

    }
    
//    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]]
//    {
//        // If your extension needs to return a collection of command definitions that differs from those
//        // in its Info.plist, implement this optional property getter.
//
//        return []
//    }
}


//----------------------------------------------------------------------------------------------------------------------
	

