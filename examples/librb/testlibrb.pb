XIncludeFile "ringbuffer.pbi" 

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

Global RB.RingBuffer                          ;decalre a RB              
RB_Initialize(@RB,SizeOf(float),1024)         ;set the size in bytes of elements and the number or elements 

t1 = CreateThread(@Producer(),@RB)    ;create writer thread 
t2 = CreateThread(@consumer(),@RB)    ;create reader thread 

WaitThread(t2) 
; IDE Options = PureBasic 6.01 LTS beta 1 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 50
; Folding = -
; EnableThread
; EnableXP
; DPIAware
; Executable = testRBDynamic.exe
; Compiler = PureBasic 6.01 LTS beta 1 - C Backend (Windows - x64)