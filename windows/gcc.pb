;fake gcc to facitlate working with inline c  
;compile this to the source folder as gcc and then rename gcc in the pb compliers folder to gcc_real and copy in this version of gcc 

;useage
;you can specify additional compiler flags on the command line as below use an inline c comment !// and keyword followed by parameters and end the line in ;  
;   !//gccflags -fno-schedule-insns -fno-schedule-insns2 ;
;if you need to add a header use !//#include followed by file path.h and end in ;
;   !//#include /usr/include/portaudio.h ;  
;this will ensure that the macros and constants are availableto for use from the header in c  
;if you want to compile with clang rather than gcc  
;   !//useclang;
;and if you want to make a static lib use !//makestatic
;   !//makestatic  e:\idle\pbstuff\portaudio\libringbuffer.a; 
;but make sure it's the last compilerflag 

; mingw64-clang13 build can be downloaded here 
; https://github.com/mstorsjo/llvm-mingw/releases/download/20211002/llvm-mingw-20211002-msvcrt-x86_64.zip
; Edit your environment PATH variable to include llvm-mingw-20211002-msvcrt-x86_64;llvm-mingw-20211002-msvcrt-x86_64\bin;llvm-mingw-20211002-msvcrt-x86_64\include
; windows 10,  windows xp
; 1.01 
EnableExplicit 

#DispalyMessages = 1

Macro _SetClipboardText(message) 
  ;SetClipboardText("Cd /D " + GetCurrentDirectory() +#CRLF$+ "PATH=%PATH%;" + GetPathPart(ProgramFilename()) + ";" + GetCurrentDirectory() +#CRLF$+ message +#CRLF$+ "")
EndMacro 

OpenConsole() 

Global Flags.s,Fn,a,Command.s,Param.s,ParamCount,Find.s,CompilerHome.s,Pos,Precomp,len,*data,fn1,fn2
Global Output.s,Gcc,Len,tCommand.s,error.s,usellvm,clangpath.s,libname.s,objname.s,err

clangpath="C:\llvm-mingw-20211002-msvcrt-x86_64\bin\clang.exe"

If ExamineEnvironmentVariables()
    
  CompilerHome = #PB_Compiler_Home
  
  If CompilerHome <> "" 
    ParamCount = CountProgramParameters()
    If ParamCount 
      For a = 0 To ParamCount-1 
        Param = ProgramParameter(a)
        Command + Param + " " 
      Next 
      Command + ProgramParameter(a) 
      
      If FileSize("purebasic.c")
        Fn = OpenFile(#PB_Any,"purebasic.c")  
        If Fn 
          Repeat 
            Flags.s = ReadString(Fn,#PB_UTF8) 
            If Not precomp 
              If FindString(Flags,"//useclang",1)
                usellvm = 1 
                command = RemoveString(command,"-fno-tree-vrp")
                command = RemoveString(command,"-fno-schedule-insns2") 
                command = RemoveString(command,"-fno-schedule-insns") 
                command = RemoveString(command,"-freorder-blocks-algorithm=simple") 
              EndIf   
              If FindString(Flags,"//gccflags",1) 
                tCommand.s = " " + Right(flags,Len(flags)-10) 
                pos = FindString(tCommand,";") 
                If pos   
                  Command.s +  " " + Trim(Left(tCommand,pos-1))
                EndIf   
              EndIf   
              If FindString(Flags,"//#include",1) 
                tCommand = "-include "  + Right(flags,Len(flags)-10) 
                pos = FindString(tCommand,";") 
                 If pos   
                  Command.s + " " + Trim(Left(tCommand,pos-1))
                EndIf  
              EndIf
              If (FindString(Flags,"//makestatic",1) Or FindString(Flags,"//precompile",1)) 
                precomp=1 
                libname = Right(flags,Len(flags)-12) 
                pos = FindString(libname,";") 
                If pos   
                  libname = Trim(Left(libname,pos-1))
                  fn2 = CreateFile(#PB_Any,"makestatic.txt") 
                  If fn2 
                    WriteStringN(fn2,libname) 
                  EndIf   
                EndIf   
                pos = FindString(libname,".") 
                libname = Left(libname,pos) + "o" 
                objname = GetFilePart(libname) 
                FileSeek(fn,1)
                Continue 
              EndIf   
            EndIf 
            If Precomp 
              If FindString(flags,"int PB_Compiler_Thread=1;",1) 
                WriteStringN(fn2,"threaded") 
              ElseIf FindString(flags,"int PB_ExecutableType=",1)  
                len = Loc(fn) 
                *Data = AllocateMemory(len) 
                FileSeek(fn,0) 
                ReadData(fn,*data,len)
                fn1 = CreateFile(#PB_Any,"purebasic1.c") 
                If fn1 
                  WriteData(fn1,*data,len) 
                  CloseFile(fn1)
                  
                  CompilerIf #DispalyMessages 
                     RunProgram("notepad.exe",GetCurrentDirectory()+"purebasic1.c","") 
                  CompilerEndIf 
                  
                  pos = FindString(command,"-c -o PureBasic.obj") 
                  tCommand = Left(command,pos-1) 
                  tcommand + " -o " + objname + " " + "purebasic1.c -c"
                  
                  CompilerIf #DispalyMessages 
                     _SetClipboardText(tcommand) 
                     MessageRequester("gcc 1 do not Link Before", "gcc_real.exe " + tcommand)
                  CompilerEndIf 
                  
                  If usellvm
                    Gcc = RunProgram(clangpath,tcommand,GetCurrentDirectory(),#PB_Program_Open);
                  Else   
                    Gcc = RunProgram(CompilerHome + "Compilers\gcc\gcc_real.exe",tcommand,GetCurrentDirectory(),#PB_Program_Open);
                  EndIf   
                  If WaitProgram(Gcc) 
                    err = ProgramExitCode(Gcc)
                    If Err 
                      MessageRequester("error",Str(err))
                    EndIf 
                  EndIf                     
                                    
                EndIf   
                FreeMemory(*data)
                Break 
              EndIf   
            EndIf  
         Until Eof(Fn) 
         CloseFile(Fn)   
        EndIf 
      EndIf 
      If IsFile(fn2) 
        CloseFile(fn2) 
      EndIf   
            
      CompilerIf #DispalyMessages 
         _SetClipboardText(command) 
         MessageRequester("gcc 3 Before real", "gcc_real.exe " + command)
      CompilerEndIf     
      
      If usellvm
        Gcc = RunProgram(clangpath,command,GetCurrentDirectory(),#PB_Program_Open);
      Else   
        Gcc = RunProgram(CompilerHome + "Compilers\gcc\gcc_real.exe",command,GetCurrentDirectory(),#PB_Program_Open);
      EndIf   
      If WaitProgram(Gcc) 
        End ProgramExitCode(Gcc)
      EndIf   
    EndIf 
  EndIf 
EndIf 


