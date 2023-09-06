ImportC "portaudio_x64.lib" : EndImport 
!//#include "e:\andrews\pbstuff\pbcex\examples\portaudio\portaudio.h";  

!#define SAMPLE_RATE         (44100)
!#define PA_SAMPLE_TYPE      paFloat32
!typedef float SAMPLE;

Global gfrequency.f=880 , gamp.f = 1.0 ,aa.f, bb.f, angle.f  

ProcedureCDLL fuzzCallback(*in.float,*out.float,framesPerBuffer,*timeInfo,statusFlags,*userData)
  Static phase.f, phasel.f, phaser.f,samp.f   
  Protected a,v.f,vl.f,vr.f   
  
  Protected  b.f = 0.010 , c.f = 1.0 , d.f = -1.0   
    
  While a < framesPerBuffer 
    
     
      v = (gAmp * Sin(phase*c) * Cos(phase*d))   
      phase + (2 * #PI * (gfrequency/32) / 44100) 
      If phase > (2 * #PI) 
        phase = phase - (2 * #PI) 
        d=-d
      EndIf 
        
    
      vl = gAmp * Sin(phasel)
      phasel + (2 * #PI * gfrequency / 44100)
      If phasel > (2 * #PI) 
        phasel = phasel - (2 * #PI)
      EndIf 
       
     *out\f = (v * 0.5)  + ( vl * 0.5) 
     *in+4 
     *out+4 
     
     vr = gAmp * Sin(phaser)
     phaser + (2 * #PI * gfrequency / 44100)
     If phaser > (2 * #PI) 
       phaser = phaser - (2 * #PI)
     EndIf 
       
     *out\f = (v * 0.5)  + ( vr * 0.5) 
     *in+4 
     *out+4 
     
     a + 1 
     
   Wend    
    
  
EndProcedure   

OpenConsole() 

!PaStreamParameters inputParameters;
!PaStreamParameters outputParameters;
!PaStream *stream;

Global err,pcb,samplesize=256

pcb= @fuzzCallback()
!g_err = Pa_Initialize();
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

!g_err = Pa_OpenStream(&stream,&inputParameters,&outputParameters,SAMPLE_RATE,g_samplesize,0,g_pcb,0);
If err <> 0 
  Goto error;
EndIf 

!g_err = Pa_StartStream( stream );
If err <> 0 
  Goto error;
EndIf 



PrintN("Hit ENTER to stop program.");
Input()

!g_err = Pa_CloseStream( stream );
If err <> 0 
  Goto error;
EndIf 

PrintN("Finished.");
Input() 
!Pa_Terminate();

error:
!Pa_Terminate();
