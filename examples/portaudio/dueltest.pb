
XIncludeFile "../librb/ringbuffer.pbi" 

ImportC "portaudio_x64.lib" : EndImport 

!//#include E:\andrews\pbstuff\pbcex\windows\examples\portaudio\portaudio.h";

Procedure InputCallback(*in.float,*out.float,framesPerBuffer,*timeInfo,statusFlags,*rb) 
  
  RB_Write(*rb,*in,framesPerBuffer) 
     
EndProcedure 

Procedure OutputCallback(*in.float,*out.float,framesPerBuffer,*timeInfo,statusFlags,*rb)
  
  RB_Read(*rb,*out,framesPerBuffer) 
      
EndProcedure 

OpenConsole() 

!#define SAMPLE_RATE         (44100)
!#define PA_SAMPLE_TYPE      paFloat32
!PaStreamParameters inputParameters;
!PaStreamParameters outputParameters;
!PaStream *streamin;
!PaStream *streamout;

Global err,pinputcb,poutputcb,samplesize,numdevices ;

samplesize = 256*2*SizeOf(float)      
pinputcb= @InputCallback()  
poutputcb = @OutputCallback()

Global rb.ringbuffer 
RB_Initialize(@rb,8,8192)

!v_err = Pa_Initialize();
If err <> 0 
  Goto error;
EndIf  

!inputParameters.device = Pa_GetDefaultInputDevice(); /* default input device */

!if (inputParameters.device == paNoDevice) {
Debug "Error: No default input device."
Goto error;
!}

!inputParameters.channelCount = 2;       /* stereo input */
!inputParameters.sampleFormat = PA_SAMPLE_TYPE;
!inputParameters.suggestedLatency = Pa_GetDeviceInfo(inputParameters.device )->defaultLowInputLatency;
!inputParameters.hostApiSpecificStreamInfo = 0;

!outputParameters.device = Pa_GetDefaultOutputDevice(); /* default output device */

!if (outputParameters.device == paNoDevice) {
Debug "Error: No Default output device."
Goto error;
!}

!outputParameters.channelCount = 2;       /* stereo output */
!outputParameters.sampleFormat = PA_SAMPLE_TYPE;
!outputParameters.suggestedLatency = Pa_GetDeviceInfo( outputParameters.device )->defaultLowOutputLatency;
!outputParameters.hostApiSpecificStreamInfo = 0;

!v_err = Pa_OpenStream(&streamin,&inputParameters,0,SAMPLE_RATE,v_samplesize,0,v_pinputcb,&v_rb);
If err <> 0 
  Goto error;
EndIf 

!v_err = Pa_OpenStream(&streamout,0,&outputParameters,SAMPLE_RATE,v_samplesize,0,v_poutputcb,&v_rb);
If err <> 0 
  Goto error;
EndIf 


!v_err = Pa_StartStream( streamin );
If err <> 0 
  Goto error;
EndIf 
!v_err = Pa_StartStream( streamout );
If err <> 0 
  Goto error;
EndIf 


PrintN("Hit ENTER to stop program.");
Input()

!v_err = Pa_CloseStream( streamin );
If err <> 0 
  Goto error;
EndIf 

!v_err = Pa_CloseStream( streamout );
If err <> 0 
  Goto error;
EndIf 

!Pa_Terminate();
End 

error:
Global perr
!v_perr = Pa_GetErrorText(v_err);
MessageRequester("PA Test",PeekS(perr,-1,#PB_UTF8)) 


!Pa_Terminate();
End 

; IDE Options = PureBasic 6.00 Beta 8 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 1
; Folding = -
; EnableThread
; EnableXP
; DPIAware
; Executable = test\dueltest.pb.exe
; DisableDebugger
; Compiler = PureBasic 6.00 Beta 8 - C Backend (Windows - x64)