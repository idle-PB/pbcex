EnableExplicit

#DispalyMessages = 1

CompilerIf #PB_Compiler_OS = #PB_OS_Windows 
   #Cdir = "\" 
CompilerElse 
   #Cdir = "/"
CompilerEndIf 

Structure folderContents
   type.b
   value.s
EndStructure

Procedure GetFileList(StartDir.s,List Lfiles.folderContents(),pattern.s="*.*",Recursive=1,bset=0)
   Protected mDir,Directory.s,Filename.s,FullFileName.s, tdir.s,ct,a,depth,bmatch
   
   Static NewList Lpattern.s()
   Static FileCount
      
   If Not bset
      StartDir = RTrim(StartDir, #Cdir) 
      pattern = RemoveString(pattern,"*.")
      ct = CountString(pattern,"|") + 1
      ClearList(lpattern())
      For a = 1 To ct 
           AddElement(Lpattern())
           Lpattern() = UCase(StringField(pattern,a,"|"))
        Next
        filecount=0
        bset=1
   EndIf 
 
  mDir = ExamineDirectory(#PB_Any, StartDir, "*.*") 
  If mDir 
    While NextDirectoryEntry(mDir)
      If DirectoryEntryType(mDir) = #PB_DirectoryEntry_File
          Directory = startdir
          FileName.s = DirectoryEntryName(mDir)
           ForEach Lpattern()
              If  Lpattern() = GetExtensionPart(UCase(Filename))
                  bmatch=1
              ElseIf  Lpattern() = "*"
                 bmatch =1 
              EndIf   
              If bmatch 
                  FullFileName.s = StartDir + #Cdir + FileName
                   AddElement(LFiles()) 
                   Lfiles()\value = FullFileName
                   Lfiles()\type = #PB_DirectoryEntry_File
                  FileCount+1
                  bmatch =0    
               EndIf
            Next  
        Else
         tdir = DirectoryEntryName(mDir)
         If tdir <> "." And tdir <> ".."
            If Recursive = 1
              depth + 1
            GetFileList(startDir + #Cdir + tdir,LFiles(),Pattern,Recursive,bset)
           EndIf
         EndIf
      EndIf
   Wend
   FinishDirectory(mDir)
  EndIf
    
  ProcedureReturn FileCount

EndProcedure

Macro _SetClipboardText(message,prog) 
  ;SetClipboardText("Cd /D " + GetCurrentDirectory() +#CRLF$+ "PATH=%PATH%; " + GetPathPart(ProgramFilename()) + ";" + GetCurrentDirectory() +#CRLF$+ prog + message +#CRLF$+ "")
EndMacro   

Global NewList myfiles.folderContents() 
Global tmp.s,cmd.s,libname.s,prog,name.s,pos   

If FileSize("makestatic.txt") 
  
  If ReadFile(0,"makestatic.txt")
   
    libname = ReadString(0) 
    cmd = GetFilePart(libname,#PB_FileSystem_NoExtension) + ".o " 
    
    tmp = ReadString(0)  ;might need to inlude some system libs based on setting like threadsafe  
    If FindString(tmp,"threaded") 
      CopyFile(#PB_Compiler_Home + "Compilers\" + "ObjectManagerThread.lib",GetCurrentDirectory()+"ObjectManagerThread.lib")  
      CopyFile(#PB_Compiler_Home + "Compilers\" + "StringManagerCThread.lib",GetCurrentDirectory()+"StringManagerCThread.lib")  
      CopyFile(#PB_Compiler_Home + "Compilers\gcc\" + "libgcc.a",GetCurrentDirectory()+"libgcc.a")  
    EndIf 
        
    If GetFileList(GetCurrentDirectory(),myfiles(),"*.lib|*.a",0)  
       ForEach myfiles() 
         cmd + myfiles()\value + " "   
       Next   
    EndIf 
        
    cmd +  " /OUT:" + libname 
    
    CloseFile(0) 
    
    CompilerIf  #DispalyMessages
      ;_SetClipboardText(cmd,"polib.exe")
      MessageRequester("polib Before", "polib.exe " + cmd)
    CompilerEndIf 
  
    RunProgram(#PB_Compiler_Home + "Compilers\polib.exe",cmd,GetCurrentDirectory(),#PB_Program_Wait) 
    
    MessageRequester("polib",cmd) 
  EndIf    
EndIf 

cmd = ""
cmd = PeekS( GetCommandLine_())
cmd = RemoveString(cmd, #DOUBLEQUOTE$ + ProgramFilename() + #DOUBLEQUOTE$, #PB_String_NoCase, 1, 1)
cmd = Mid(cmd,2)


CompilerIf #DispalyMessages
   SetClipboardText(cmd) 
   MessageRequester("polink",cmd)
 CompilerEndIf 
 
prog = RunProgram(#PB_Compiler_Home + "Compilers\polink_real.exe", cmd, GetCurrentDirectory(), #PB_Program_Open)
While IsProgram(prog)
	If ProgramRunning(prog) 
		Delay(100)
	Else
		CloseProgram(prog)	
	EndIf
Wend
End ProgramExitCode(prog)

; IDE Options = PureBasic 6.02 beta 4 LTS (Windows - x64)
; CursorPosition = 121
; Folding = -
; EnableXP
; DPIAware
; Executable = polink.exe
; Compiler = PureBasic 6.02 beta 4 LTS - C Backend (Windows - x64)