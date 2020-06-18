------------------------------------------------------------------------------------------------------------------------


-- This function should not be called from the Extenstion and is used instead for testing during script development

on run
	newDocumentation("/Users/peter/Library/Application Support/com.boinx.XCDocumentation/Templates")
end run


------------------------------------------------------------------------------------------------------------------------


-- Creates a new documentation file at $SRCROOT/Document/filename and returns the relativePath to it.
-- The user gets to enter the filename and choose from several templates.

on newDocumentation(templatePath)
	
	set srcrootPath to SRCROOT()
	
	-- Store the current edited file to be able to make it open when we leave the script,
	-- otherwise Xcode will be stuck in the execution of the extension command
	
	set sourceFilePath to activeSourceFilePath()
	
	-- Let the user enter a file name
	
	set nameSuggestion to fileNameWithoutExtension(activeSourceFileName())
	set theResponse to display dialog "New Documentation File:" default answer nameSuggestion with icon note buttons {"Cancel", "OK"} default button "OK"
	
	if button returned of theResponse is "OK" then
		set filename to text returned of theResponse
	else
		return ""
	end if
	
	-- get template list
	
	set templateNames to {}
	set myTemplateFolder to (POSIX file templatePath as string) as alias
	
	tell application "Finder"
		set myTemplates to every file of myTemplateFolder
	end tell
	
	repeat with myTemplate in myTemplates
		set templateNames to templateNames & ((name of myTemplate) as string)
	end repeat
	
	-- If we have more than one template then let the user choose one
	
	if (count of templateNames) > 1 then
		set selectedTemplateName to choose from list templateNames with title "Templates" OK button name "OK" cancel button name "Cancel" without multiple selections allowed
	else
		set selectedTemplateName to item 1 of templateNames
	end if
	
	-- Everything is set so start processing the template
	
	restoreXcodeSourceFile(sourceFilePath) of me
	
	if selectedTemplateName is not false then
		tell application "Finder"
			
			try
				set srcrootFolder to (POSIX file srcrootPath) as alias
				set documentationFolder to folder named "Documentation" of srcrootFolder
			on error
				-- there is no "Documentation" folder, so lets make it:
				set documentationFolder to make new folder at srcrootFolder with properties {name:"Documentation"}
			end try
			
			
			-- If the following doesn't fail then this file already exist!
			
			try
				set newFileName to ensureFileExtension(selectedTemplateName, filename) of me
				set fileExists to file newFileName of documentationFolder
				display dialog "File already exists. Please choose a different name."
				restoreXcodeSourceFile(sourceFilePath) of me
				return ""
			end try
			
			-- Copy the template file from the template folder to the documentation folder
			
			try
				set myTemplateFile to file named selectedTemplateName of myTemplateFolder
				duplicate myTemplateFile to documentationFolder
			on error
				display dialog "Failed to copy template file." with icon stop
				restoreXcodeSourceFile(sourceFilePath) of me
				return ""
			end try
			
			-- Rename the copied template file
			
			set newFile to file named selectedTemplateName of documentationFolder
			set name of newFile to newFileName
			open file newFileName of documentationFolder
			
			-- Just in case the user has navigated away from the original source file, go back or Xcode will
			-- be stuck state where it cannpot be used anymore.
			
			restoreXcodeSourceFile(sourceFilePath) of me
			return newFileName
			
		end tell
	end if
	
end newDocumentation


on restoreXcodeSourceFile(sourceFilePath)
	tell application "Xcode"
		open (POSIX file sourceFilePath) as alias
	end tell
end restoreXcodeSourceFile


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


-- Opens the documentation file at $SRCROOT/Document/relativePath with its native editor application.
-- Returns the absolute path to the file.

on editDocumentation(relativePath)
	
	set absolutePath to absolutePathFor(relativePath) of me
	set myFile to POSIX file absolutePath
	
	try
		tell application "Finder"
			open myFile
		end tell
	on error
		displayMissingFileAlert(relativePath)
	end try
	
	return absolutePath
	
end editDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Shows the documentation file at $SRCROOT/Document/relativePath within Xcode (using QuickLook).
-- Returns the absolute path to the file.

on showDocumentation(relativePath)
	
	set absolutePath to absolutePathFor(relativePath)
	set myFile to POSIX file absolutePath
	
	try
		tell application "Xcode"
			open myFile
		end tell
	on error
		displayMissingFileAlert(relativePath)
	end try
	
	return absolutePath
	
end showDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Returns the current $SRCROOT, i.e. the directory containing the current Xcode project file

on SRCROOT()
	set sourceFilePath to activeSourceFilePath()
	set myProject to projectForSourceFilePath(sourceFilePath)
	set myPath to getSRCROOTofProject(myProject)
	return myPath
end SRCROOT


------------------------------------------------------------------------------------------------------------------------


on absolutePathFor(relativePath)
	
	-- get $SRCROOT and append a trailing / if necessary
	set absolutePath to SRCROOT()
	if not (last character of absolutePath is "/") then
		set absolutePath to absolutePath & "/"
	end if
	
	-- Append "Document/relativePath"
	set absolutePath to absolutePath & "Documentation/" & relativePath
	return absolutePath
	
end absolutePathFor


on displayMissingFileAlert(relativePath)
	set message to "The file '" & relativePath & "' doesn't exist."
	display dialog message with title "Error" with icon caution buttons {"OK"} default button "OK"
end displayMissingFileAlert


------------------------------------------------------------------------------------------------------------------------


on activeSourceFileName()
	
	set activeDocument to activeXcodeDocument()
	set myFileName to name of activeDocument
	
	return myFileName
	
end activeSourceFileName

-- Returns the path to the source file that is currently being edited in Xcode

on activeSourceFilePath()
	
	--set activeDocument to activeXcodeDocument()
	--set myPath to path of activeDocument
	
	tell application "Xcode"
		-- alternative:
		set myDocument to front source document
		set myPath to path of myDocument
		--set activeDocument to document 1 whose name ends with (word -1 of (get name of window 1))
		--set myPath to path of activeDocument
	end tell
	
	return myPath
	
end activeSourceFilePath

on activeXcodeDocument()
	
	tell application "Xcode"
		
		-- Alternativ: Doesn't work with multiple documents though, but should be more robust
		-- set myDocument to front source document
		-- set myPath to path of myDocument
		
		set frontWindowName to name of window 1
		
		-- If a document is dirty, it ends with " Ñ Edited".
		-- We try to get the file name at the beginning:
		
		-- save old delimiters
		set oldAppleDelimiter to AppleScript's text item delimiters
		
		set AppleScript's text item delimiters to " Ñ " -- Note: special minus !
		
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
		set resolvedProject to project of myWorkspace
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
