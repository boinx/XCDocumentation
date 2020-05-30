------------------------------------------------------------------------------------------------------------------------


-- This function should not be called from the Extenstion and is used instead for testing during script development

on run
	openDocumentation("Architecture.pdf")
end run


------------------------------------------------------------------------------------------------------------------------


-- Opens the documentation file at $SRCROOT/Document/relativePath with its native editor application

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
	tell application "Finder"
		open myFile
	end tell
	
	-- Return the absolute path to the file
	return absolutePath
	
end openDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Creates a documentation file at $SRCROOT/Document/relativePath and returns the relativePath to it

on newDocumentation()
	set relativePath to "new.pdf"
	return relativePath
end newDocumentation


------------------------------------------------------------------------------------------------------------------------


-- Returns the current $SRCROOT, i.e. the directory containing the current Xcode project file

on SRCROOT()
	set sourceFilePath to activeSourceFilePath()
	set myProject to projectForSourceFilePath(sourceFilePath)
	set myPath to getSRCROOTofProject(myProject)
	return myPath
end SRCROOT


------------------------------------------------------------------------------------------------------------------------


-- Returns the path to the source file that is currently being edited in Xcode

on activeSourceFilePath()
	tell application "Xcode"
		-- alternative:
		set myDocument to front source document
		set myPath to path of myDocument
		--set activeDocument to document 1 whose name ends with (word -1 of (get name of window 1))
		--set myPath to path of activeDocument
	end tell
	return myPath
end activeSourceFilePath


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
