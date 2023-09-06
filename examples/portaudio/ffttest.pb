ImportC "portaudio_x64.lib" : EndImport 
!//#include "e:\andrews\pbstuff\pbcex\examples\portaudio\portaudio.h";  

!#define SAMPLE_RATE         (44100)
!#define PA_SAMPLE_TYPE      paFloat32
!typedef float SAMPLE;

#DOUBLEPREC = 1

CompilerIf #DOUBLEPREC = 0
  Structure complex 
    Re.d
    Im.d 
  EndStructure   
CompilerElse 
  Structure complex 
    Re.f
    Im.f 
  EndStructure   
CompilerEndIf 

Structure arcomplex 
  ar.complex[0]
EndStructure 

Procedure _stockham(*x.arcomplex,n.i,flag.i,n2.i,*y.arcomplex)
  
  Protected *y_orig.arcomplex 
  Protected *tmp.complex 
  
  Protected i.i, j.i, k.i, k2.i, Ls.i, r.i, jrs.i
  Protected half, m, m2                          
  Protected wr.d, wi.d, tr.d, ti.d               
  
  *y_orig = *y
  half = n >> 1
  r = half 
  Ls = 1                                     
  
  While(r >= n2) 
    *tmp = *x                  
    *x = *y                             
    *y = *tmp
    m = 0                      
    m2 = half                    
    j=0
    While j < ls
      wr = Cos(#PI*j/Ls)
      wi = -flag * Sin(#PI*j/Ls)            
      jrs = j*(r+r)
      k = jrs
      While k < jrs+r
        k2 = k + r
        tr =  wr * *y\ar[k2]\Re - wi * *y\ar[k2]\Im   
        ti =  wr * *y\ar[k2]\Im + wi * *y\ar[k2]\Re
        *x\ar[m]\Re = *y\ar[k]\Re + tr
        *x\ar[m]\Im = *y\ar[k]\Im + ti
        *x\ar[m2]\Re = *y\ar[k]\Re - tr
        *x\ar[m2]\Im = *y\ar[k]\Im - ti
        m+1
        m2+1
        k+1
      Wend 
      j+1
    Wend  
    r  >> 1
    Ls << 1
  Wend 
  
  CopyMemory(*x,*y,n*SizeOf(complex))  
   
EndProcedure   

Procedure fft(*x.arcomplex,n.i,flag.i=1)
  Protected *y.arcomplex
  *y = AllocateMemory((n)*SizeOf(complex))
  _stockham(*x, n, flag, 1, *y)
  FreeMemory(*y) 
EndProcedure 

#PI2 = 2 * #PI 
#hamming =1
#Hanning = 2 
#Blackman = 3  

Global gNumNoInputs = 0;
Global fftpoints = 4096
Global Dim inp.complex(fftpoints)
Global Dim windowing.f(fftpoints) 
Global windowtype = 1 
Global samplesize = fftpoints / 4 
Global *buf = AllocateMemory(fftpoints*SizeOf(complex)) 

For a = 0 To fftpoints 
  If windowtype = #Hamming 
    windowing(a) =  0.54 - (0.46 * Cos(#PI2 * a / ((fftpoints/2)-1)))  
  ElseIf windowtype = #Hanning 
    windowing(a) = 0.5 * (1.0-Cos((#pi2*a /(fftpoints/2)-1)))   
  ElseIf windowtype = #BLackman  
    windowing(a) = 0.42- ((0.5 * Cos(#PI2*a / (fftpoints-1))) + (0.08 * Cos(4*#PI*a/(fftpoints-1))))  
  EndIf 
Next   

Procedure Freqency() 
  Protected res.d, time.d 
  res = (44100 / 2.0 / fftpoints)
  time = 1/res 
EndProcedure  

Procedure.f Mag(*val.complex) 
  ProcedureReturn Sqr(*val\Re * *val\re + *val\Im * *val\Im)
EndProcedure   

Procedure.f CubicAmplifier(input.f)
   Protected  output.f, temp.f;
    If input < 0.0
       temp = input + 1.0;
       output = (temp * temp * temp) - 1.0;
    Else
       temp = input - 1.0;
       output = (temp * temp * temp) + 1.0;
    EndIf    
    ProcedureReturn output;
  EndProcedure 
  
  Macro FUZZ(x)
    CubicAmplifier(CubicAmplifier(CubicAmplifier(CubicAmplifier(x))))
  EndMacro

ProcedureCDLL fuzzCallback(*in.float,*out.float,framesPerBuffer,*timeInfo,statusFlags,*userData)
  Protected a,half,*pbuf.float, in.s, out.s ,shift  
   
  half = fftpoints >> 1 
    
  For a = 0 To half-1
     inp(a)\Re = *in\f * windowing(a)   
     inp(a)\Im = 0 
     *in+4
  Next   
    
  fft(@inp(0),fftpoints,1)  ;do forward fft 
  
  For a = 0 To half-256
   inp(a)\Re = inp(a+256)\Re  ;mag(@inp(Random(64,half))) ;mess with the signal
   inp(a)\Im = inp(a+256)\Im   
  Next 
       
  fft(@inp(0),fftpoints,-1) ;do inverse fft 
  
  For a = 1 To half-1 
    If a < 20 
      *out\f = 0
     Else  
      *out\f = inp(a)\re ;* windowing(a)  ;write it out should really divide by ftpoints  
    EndIf
    *out+4 
  Next
  
  FillMemory(@inp(0),fftpoints*SizeOf(complex),0,#PB_Long) 
  
  ProcedureReturn 0 
EndProcedure 

OpenConsole() 

!PaStreamParameters inputParameters;
!PaStreamParameters outputParameters;
!PaStream *stream;

Global err,pcb ;

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
