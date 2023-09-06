
!//gccflags -IC:\llvm-mingw-20211002-msvcrt-x86_64\lib\clang\13.0.0\include; 
!//#include "E:\andrews\pbstuff\pbcex\examples\miniaudio\miniaudio.h";
!//useclang;

ImportC  "miniaudiox64.lib" : EndImport 

ProcedureC data_callback(*Device,*Output,*Input,frameCount)
  Protected amount 
  If frameCount  
    !ma_device* pDevice; 
    !pDevice = p_device; 
    !v_amount = v_framecount * ma_get_bytes_per_frame(pDevice->capture.format, pDevice->capture.channels);
    
    PrintN("copy " + Str(amount))
       
    If amount <> 0  
        CopyMemory(*input,*Output,amount) 
    EndIf
    
  EndIf 
EndProcedure 

PrototypeC pcbcallback(*device,*output,*input,framecount)
Global pcb.pcbcallback 
pcb = @data_callback() ;use a prototype set a refertence to the data_callbackotherwise pb won't include it 

OpenConsole()

!ma_result result;
!ma_device_config deviceConfig;
!ma_device device;

!deviceConfig = ma_device_config_init(ma_device_type_duplex);
!deviceConfig.capture.pDeviceID  = NULL;
!deviceConfig.capture.format     = ma_format_s16;
!deviceConfig.capture.channels   = 2;
!deviceConfig.capture.shareMode  = ma_share_mode_shared;
!deviceConfig.playback.pDeviceID = NULL;
!deviceConfig.playback.format    = ma_format_s16;
!deviceConfig.playback.channels  = 2;
!deviceConfig.dataCallback       = g_pcb;;

!result = ma_device_init(NULL, &deviceConfig, &device);

!if (result != MA_SUCCESS) {
   MessageRequester("error","failed to config")  
   End 
!}

!ma_device_start(&device);

PrintN("press enter to end") 
Input();

!ma_device_uninit(&device);
