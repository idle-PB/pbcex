;Example of lockfree ringbuffer to make a precompiled static lib with c backend and pbcex tool
;create executable as a shared dll 
;cheate temp exe in source foler location  

;change the path to the source folder location for the makestatic flag line 28  

Structure RingBuffer_Ar 
  e.a[0]   
EndStructure

Structure RingBuffer 
  stop.i
  bufferSize.i
  writeIndex.i
  readIndex.i
  bigMask.i
  smallMask.i
  elementSizeBytes.i 
  *buffer.Ringbuffer_Ar 
EndStructure   
  
 CompilerIf #PB_Compiler_IsMainFile  
   
  CompilerIf #PB_Compiler_Backend = #PB_Backend_C   
 
 ; !//gccflags -O3;    //optioanl; flags 
 ; !//useclang;        //if you have installed a mingw32 environment  
  !//makestatic "d:\idle\pbstuff\pbcex\examples\librb\librb.a"; <---change path to the source folder 
  
 CompilerEndIf 
  
  Macro FullMemoryBarrier() 
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm     
      !mfence 
    CompilerElse 
        !__asm__("mfence" ::: "memory"); 
    CompilerEndIf   
  EndMacro 
  
  Macro WriteMemoryBarrier()
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm  
      !sfence 
    CompilerElse  
       !__asm__("sfence" ::: "memory");
    CompilerEndIf   
  EndMacro 
  
  Macro ReadMemoryBarrier() 
    CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm   
      !lfence
    CompilerElse  
      !__asm__("lfence" ::: "memory");
    CompilerEndIf    
  EndMacro 
  
   Global gEnumlock.i  
   
  Macro _gEnumlock(x)
     CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
        !__atomic_exchange_n(&squintXg_genumlock,x,__ATOMIC_SEQ_CST) ; 
     CompilerElse  
        !mov rdx, x  
        !xchg qword [squint.v_gEnumlock] , rdx
     CompilerEndIf 
  EndMacro 
  
  ProcedureCDLL RB_Initialize(*rb.RingBuffer,elementSizeBytes,elementCount)
    
    If(((elementCount-1) & elementCount) <> 0) ;element count must be power of 2 
      ProcedureReturn -1
    EndIf  
    
    *rb\bufferSize = elementCount
    *rb\buffer = AllocateMemory(elementCount*elementSizeBytes)  
    *rb\bigMask = (elementCount*2)-1
    *rb\smallMask = (elementCount)-1
    *rb\elementSizeBytes = elementSizeBytes
    
    ProcedureReturn *rb\buffer 
    
  EndProcedure 
  
  ProcedureCDLL RB_Free(*rb.RingBuffer) 
    
    If *rb 
      If *rb\buffer 
        FreeMemory(*rb\buffer) 
        *rb\buffer = #Null 
      EndIf 
    EndIf
    
  EndProcedure   
  
  Procedure RB_GetReadAvailable(*rb.RingBuffer)
    
    ProcedureReturn((*rb\writeIndex - *rb\readIndex) & *rb\bigMask)
    
  EndProcedure 
  
  Procedure RB_GetWriteAvailable(*rb.RingBuffer)
    
    ProcedureReturn(*rb\bufferSize - RB_GetReadAvailable(*rb))
    
  EndProcedure 
  
  Procedure RB_Flush(*rb.RingBuffer)
    
    *rb\writeIndex = 0 
    *rb\readIndex = 0
    
  EndProcedure 
  
  Procedure RB_GetWriteRegions(*rb.RingBuffer,elementCount,*dataPtr1.integer,*sizePtr1.integer,*dataPtr2.integer,*sizePtr2.integer )
    Protected index.i, available.i
    
    available.i = RB_GetWriteAvailable(*rb)
    
    If elementCount > available 
      elementCount = available
    EndIf   
    
    index = (*rb\writeIndex & *rb\smallMask)
    
    If(index + elementCount) > *rb\bufferSize 
      firstHalf = *rb\bufferSize - index
      *dataPtr1\i = @*rb\buffer\e[index * *rb\elementSizeBytes]
      *sizePtr1\i = firstHalf
      *dataPtr2\i = @*rb\buffer\e[0]
      *sizePtr2\i = elementCount - firstHalf
    Else
      *dataPtr1\i = @*rb\buffer\e[index * *rb\elementSizeBytes]
      *sizePtr1\i = elementCount
      *dataPtr2\i = #Null
      *sizePtr2\i = 0
    EndIf 
    
    If available 
      FullMemoryBarrier() 
    EndIf 
    
    ProcedureReturn elementCount
    
  EndProcedure 
  
  Procedure RB_AdvanceWriteIndex(*rb.RingBuffer,elementCount.i)
    Protected index,*ptr  
    
    WriteMemoryBarrier()
    *rb\writeIndex = (*rb\writeIndex + elementCount) & *rb\bigMask
    
    ProcedureReturn *rb\writeIndex
    
  EndProcedure 
  
  Procedure RB_GetReadRegions(*Rb.RingBuffer,elementCount,*dataPtr1.integer,*sizePtr1.integer,*dataPtr2.integer,*sizePtr2.integer)
    Protected index.i,firsthalf.i,available.i
    
    available.i = RB_GetReadAvailable(*rb)
    
    If( elementCount > available ) 
      elementCount = available
    EndIf   
    
    index = (*rb\readIndex & *rb\smallMask)
    
    If((index + elementCount) > *rb\bufferSize )
      firstHalf = *rb\bufferSize - index
      *dataPtr1\i = @*rb\buffer\e[index * *rb\elementSizeBytes]
      *sizePtr1\i = firstHalf
      *dataPtr2\i = @*rb\buffer\e[0]
      *sizePtr2\i = elementCount - firstHalf
    Else
      *dataPtr1\i = @*rb\buffer\e[index * *rb\elementSizeBytes]
      *sizePtr1\i = elementCount
      *dataPtr2\i = 0
      *sizePtr2\i = 0
    EndIf 
    
    If( available )
      ReadMemoryBarrier() 
    EndIf 
    
    ProcedureReturn elementCount
    
  EndProcedure 
  
  Procedure RB_AdvanceReadIndex(*rb.RingBuffer,elementCount)
    
    FullMemoryBarrier()
    
    *rb\readIndex = (*rb\readIndex + elementCount) & *rb\bigMask
    
    ProcedureReturn *rb\readIndex
    
  EndProcedure 
  
  ProcedureCDLL RB_Write(*rb.RingBuffer,*Data,elementCount)
    Protected size1, size2, numWritten
    Protected data1, data2
    
    numWritten = RB_GetWriteRegions(*rb,elementCount,@data1, @size1, @data2, @size2)
    
    If( size2 > 0 )
      CopyMemory(*Data,data1,size1 * *rb\elementSizeBytes)
      *data + (size1 * *rb\elementSizeBytes)
      CopyMemory(*Data,data2,size2 * *rb\elementSizeBytes)
    Else
      CopyMemory(*Data,data1, size1 * *rb\elementSizeBytes )
    EndIf 
    
    RB_AdvanceWriteIndex(*rb,numWritten)
    
    ProcedureReturn numWritten                 
    
  EndProcedure 
  
  ProcedureCDLL RB_Read(*rb.RingBuffer,*Data,elementCount)
    Protected size1, size2, numRead
    Protected data1, data2
    
    numRead = RB_GetReadRegions(*rb,elementCount,@data1,@size1,@data2,@size2 )
    
    If( size2 > 0 )
      CopyMemory(data1,*data,size1 * *rb\elementSizeBytes )
      *Data + size1 * *rb\elementSizeBytes
      CopyMemory(data2,*Data,size2 * *rb\elementSizeBytes )
    Else
      CopyMemory(data1,*Data,size1 * *rb\elementSizeBytes )
    EndIf 
    
    RB_AdvanceReadIndex(*rb,numRead)
    
    ProcedureReturn numRead                
      
  EndProcedure 
    
  CompilerIf #PB_Compiler_Debugger
    
    Procedure Producer(*RB.RingBuffer) 
      
      Protected num 
      Dim inputs.f(64) 
      
      Repeat 
        
        For a = 0 To 63
          inputs(a) = ct 
          ct+1 
        Next 
        
        num = RB_Write(*RB,@inputs(0),64) ;write 64 elements to the ring if full it will return 0  
        
        Debug "num write " + Str(num) 
        
        Delay(Random(100,20))  
        
      Until *RB\stop 
      
    EndProcedure 
    
    
    Procedure Consumer(*RB.RingBuffer) 
      
      et= ElapsedMilliseconds() + 10000
      Dim outputs.f(64) 
      
      Repeat 
        
        num = RB_Read(*RB,@outputs(0),64)  ;read 64 elements off ring if empty it will return 0 
        
        Debug "num read " + Str(num) + " " + StrF(outputs(0),3)      
        
        Delay(Random(100,20))  
        
      Until ElapsedMilliseconds() > et       
      
      *rb\stop = 1 ;stop buffering  
      
    EndProcedure   
    
    
    Global RB.RingBuffer                  ;decalre a RB              
    RB_Initialize(@RB,SizeOf(float),1024) ;set the size in bytes of elements and the number or elements 
    
    t1 = CreateThread(@Producer(),@RB)    ;create writer thread 
    t2 = CreateThread(@consumer(),@RB)    ;create reader thread 
    
    WaitThread(t2) 
    
  CompilerEndIf 
    
CompilerElse ;this is the import header so when you include ringbuffer.pbi  
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_C 
    #USESTATIC=1
  CompilerElse 
    #USESTATIC=0
  CompilerEndIf  
   
  CompilerIf #USESTATIC  
  
   ImportC "librb.a"
     RB_Initialize(*rb.RingBuffer,elementSizeBytes,elementCount) As "f_rb_initialize"
     RB_Free(*rb.RingBuffer) As "f_rb_free"
     RB_Write(*rb.RingBuffer,*Data,elementCount) As "f_rb_write" 
     RB_Read(*rb.RingBuffer,*Data,elementCount) As "f_rb_read" 
   EndImport   
   
 CompilerElse 
   
   ImportC "librb.lib"
     RB_Initialize(*rb.RingBuffer,elementSizeBytes,elementCount) 
     RB_Free(*rb.RingBuffer) 
     RB_Write(*rb.RingBuffer,*Data,elementCount) 
     RB_Read(*rb.RingBuffer,*Data,elementCount) 
   EndImport   
   
   CompilerEndIf 
     
CompilerEndIf 






; IDE Options = PureBasic 6.01 LTS beta 1 (Windows - x64)
; ExecutableFormat = Shared dll
; Folding = ----
; Optimizer
; EnableThread
; EnableXP
; DPIAware
; Executable = librb.dll
; DisableDebugger
; CompileSourceDirectory
; Compiler = PureBasic 6.01 LTS beta 1 - C Backend (Windows - x64)