------------------------------------------------------------------------------------------------------------------------


-- This function should not be called from the Extenstion and is used instead for testing during script development

on run
	openDocumentation("Architecture.pdf")
end run


------------------------------------------------------------------------------------------------------------------------


-- Opens the documentation file at $SRCROOT/Document/relativePath with its native editor application.
-- Returns the absolute path to the file.

on openDocumentation(relativePath)
	
	-- get $SRCROOT and append a trailing / if necessary
	set absolutePath to SRCROOT()
	if not (last character of absolutePath is "/") then
		set absolutePath to absolutePath & "/"
	end if
	
	-- Append "Document/relativePath"
	set absolutePath to absolutePath & "Documentation/" & relativePath
	set myFile to POSIX file absolutePath
	
	-- Try to open the file
	try
		tell application "Finder" to open myFile
	on error
		set message to "The file '" & relativePath & "' doesn't exist."
		display dialog message with title "Error" with icon caution buttons {"OK"} default button "OK"
	end try
	return absolutePath
	
end openDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Creates a new documentation file at $SRCROOT/Document/filename and returns the relativePath to it.
-- The user gets to enter the filename and choose from several templates.

on newDocumentation(templatePath)
	
	set sorceRootPath to SRCROOT()
	
	-- Let the user enter a file name
	set nameSuggestion to fileNameWithoutExtension(activeSourceFileName())
	set theResponse to display dialog "Please enter the name of the documentation file" default answer nameSuggestion with icon note buttons {"Cancel", "OK"} default button "OK"
	if button returned of theResponse is "OK" then
		
		set filename to text returned of theResponse
	else
		return ""
		
	end if
	
	
	-- get template list
	set myTemplateFolder to (POSIX file templatePath as string) as alias
	
	tell application "Finder"
		set myTemplates to every file of myTemplateFolder
	end tell
	
	set templateNames to {}
	
	repeat with myTemplate in myTemplates
		set templateNames to templateNames & ((name of myTemplate) as string)
	end repeat
	
	if (count of templateNames) > 1 then
		-- Let the user select a template from the template list
		
		set theChoosenItem to choose from list templateNames with title "Documentation Template Selection" with prompt "Choose a Template" OK button name "OK" cancel button name "Cancel" default items {"Boinx Pages"}
		
	else
		
		-- if there is only one template we don't prompte the user to choose it
		
		set theChoosenItem to item 1 of templateNames
	end if
	
	if theChoosenItem is not false then
		
		-- everything is set so start processing the template
		tell application "Finder"
			set myTemplateFile to file named theChoosenItem of myTemplateFolder
			
			set srcrootFolder to (POSIX file sorceRootPath) as alias
			
			try
				set documentationFolder to folder named "Documentation" of srcrootFolder
			on error
				-- there is no "Documentation" folder, so lets make it:
				set documentationFolder to make new folder at srcrootFolder with properties {name:"Documentation"}
			end try
			
			set newFileName to ensureFileExtension(theChoosenItem, filename) of me
			try
				-- if the following line doesn't fail then this file already exist!
				set isFileExisting to file newFileName of documentationFolder
				
				display dialog "This file already exist. Pease choose a different name."
				return ""
				
			end try
			
			try
				-- copy the template file from the template folder to the documentation folder
				duplicate myTemplateFile to documentationFolder
				
			on error
				display dialog "Something went wrong while copying the template file"
				return ""
				
			end try
			-- rename the new file to the name the user gave it
			set newFile to file named theChoosenItem of documentationFolder
			set name of newFile to newFileName
			
			open file newFileName of documentationFolder
			
			return newFileName
		end tell
	end if
	
end newDocumentation

on ensureFileExtension(oldFileName, newFileName)
	
	set resultFileName to newFileName
	
	-- save old delimiters
	set oldAppleDelimiter to AppleScript's text item delimiters
	
	set AppleScript's text item delimiters to "."
	
	set oldFileNameParts to every text item of (oldFileName as text)
	set newFileNameParts to every text item of (newFileName as text)
	
	-- restore text delimiters
	set AppleScript's text item delimiters to oldAppleDelimiter
	
	set oldExtension to last item of oldFileNameParts
	set newExtension to last item of newFileNameParts
	
	if oldExtension is not newExtension then
		set resultFileName to (newFileName & "." & oldExtension) as text
	end if
	
	return resultFileName
	
end ensureFileExtension

on fileNameWithoutExtension(filename)
	
	set resultFileName to filename
	
	-- save old delimiters
	set oldAppleDelimiter to AppleScript's text item delimiters
	
	set AppleScript's text item delimiters to "."
	
	set fileNameParts to every text item of (filename as text)
	
	-- restore text delimiters
	set AppleScript's text item delimiters to oldAppleDelimiter
	
	set partCount to count of fileNameParts
	
	if partCount > 1 then
		set resultFileName to (items 1 through (partCount - 1) of fileNameParts) as text
	end if
	
	return resultFileName
	
end fileNameWithoutExtension



------------------------------------------------------------------------------------------------------------------------


-- Lets the user select an existing file from the Documentation folder and returns the relativePath to it

on selectDocumentation()
	set relativePath to "Bar.pdf"
	return relativePath
end selectDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Returns the current $SRCROOT, i.e. the directory containing the current Xcode project file

on SRCROOT()
	set sourceFilePath to activeSourceFilePath()
	set myProject to projectForSourceFilePath(sourceFilePath)
	set myPath to getSRCROOTofProject(myProject)
	return myPath
end SRCROOT


------------------------------------------------------------------------------------------------------------------------


on activeSourceFileName()
	
	set activeDocument to activeXcodeDocument()
	set myFileName to name of activeDocument
	
	return myFileName
	
end activeSourceFileName

-- Returns the path to the source file that is currently being edited in Xcode

on activeSourceFilePath()
	
	set activeDocument to activeXcodeDocument()
	set myPath to path of activeDocument
	
	return myPath
	
end activeSourceFilePath

on activeXcodeDocument()
	
	tell application "Xcode"
		
		-- Alternativ: Doens't work with multiple documents thought, but should be more robust
		-- set myDocument to front source document
		-- set myPath to path of myDocument
		
		set frontWindowName to name of window 1
		
		-- If a document is dirty, it ends with " — Edited".
		-- We try to get the file name at the beginning:
		
		-- save old delimiters
		set oldAppleDelimiter to AppleScript's text item delimiters
		
		set AppleScript's text item delimiters to " — " -- Note: special minus !
		
		set myDocumentNameParts to every text item of frontWindowName
		
		-- restore text delimiters
		set AppleScript's text item delimiters to oldAppleDelimiter
		
		set activeDocument to document 1 whose name ends with (item 1 of myDocumentNameParts)
		
	end tell
	
	return activeDocument
	
end activeXcodeDocument


------------------------------------------------------------------------------------------------------------------------


-- Returns the Xcode project that contains the specified source file

on projectForSourceFilePath(sourceFilePath)
	
	tell application "Xcode"
		
		set myWorkspace to front workspace document
		set myProjects to project of myWorkspace
		set maxPathLength to 0
		
		-- set myProject to first item of myProjects
		repeat with myProject in myProjects
			-- log (name of myProject) as text
			
			set mySRCROOT to getSRCROOTofProject(myProject) of me
			if mySRCROOT is not "" then
				
				set isPrefix to offset of mySRCROOT in sourceFilePath
				
				set mySRCROOTLength to length of mySRCROOT
				
				if isPrefix is 1 and mySRCROOTLength > maxPathLength then
					
					set resolvedProject to myProject
					set resolvedSRCROOT to mySRCROOT
					set maxPathLength to mySRCROOTLength
					
				end if
			end if
		end repeat
		
	end tell
	
	return resolvedProject
	
end projectForSourceFilePath


------------------------------------------------------------------------------------------------------------------------


-- Returns $SRCROOT for the specified Xcode project

on getSRCROOTofProject(myProject)
	tell application "Xcode"
		set myBuildConfiguration to first build configuration of myProject
		set mySRCROOT to value of resolved build setting "SRCROOT" of myBuildConfiguration
	end tell
	return mySRCROOT
end getSRCROOTofProject


------------------------------------------------------------------------------------------------------------------------
