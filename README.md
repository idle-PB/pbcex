# pbcex
comandline tool for c backend

PBCEX tools to facilitate using inline c and to make precompiled static libs 
Author idle 2022  
Version 1.0 for windows purebasic 6.00 c backend
Linux and Raspberry PI version will be on their way  
It's my hope that Fred will eventually add this to the c backend.  

Set up: 
Compile gcc and polink to the source folder. 
navigate to your purebasic compilers directory and rename Gcc and polink to gcc_real and polink_real 
copy your compiled gcc and polink to the purebasic compilers directory. 

Use: 

The tool facilitates you to control gcc compiler flags and utilize c libs directly in PB and also make precompiled libs to save compile times
flags are entered as inline c comments !// followed by command and argments that end in ;  

!//gccflags -O3;  optimize to O3  
!//useclang;      if you've installed mingw64 and added the enviroment path to the compiler you can use that in place of the supplied gcc 
!//#include path\to\some\clibheader.h;   ;this will inlude the entire c lib so it's available to use with inline c 
!//makestatic path\to\your\libray.a;     ;this will generate a static lib all function marked as procedureCDll will be exported 
 

Some examples make use of llvm mingw64 you can download it here and install c:\ or where ever   
https://github.com/mstorsjo/llvm-mingw/releases/download/20211002/llvm-mingw-20211002-msvcrt-x86_64.zip
;Edit your environment PATH variable to include the paths 
c:\llvm-mingw-20211002-msvcrt-x86_64
c:\llvm-mingw-20211002-msvcrt-x86_64\bin
c:\llvm-mingw-20211002-msvcrt-x86_64\include

Tool files 
gcc.pb         tool source instructions to install mingw64 in readme 
polink.pb      source to facilitate making static libs 


Examples 
*Note you will need to modify all the inline c paths used on all examples and use c backend for compile

librb - ringbuffer as a static lib.    
portaudio - ffttest and dueltest requires librb.a    
raylib4 -  screen and julia set.
miniaudio - single header c lib compiled as dll coming native to PB 


librb a static lib example librb.a allows you to create a static lib and compile as a dll 
the file patern used allows you to easily work on and precompile a lib and use it in a project easily. 
Set compiler to c backend, set to the compile type to shared dll, turn off debuger and hit F5 to compile to static lib   

files: 
librb.a        the generated static lib compiled with optional !//useclang; 
librb.dll      the compiled dll from using create executable 
librb.lib      the import lib to the dll 
testlibrb.pb   test for librb compile as thread safe for debug messages   
ringbuffer.pbi lockfree ring buffer to produce librb.a

Notes the filepattern used in ringbuffer.pbi facilitates you to easily create test and use precompiled libs in a project to save compile times 
while the static libary generated is usable with pb it may not be usable from another language as it misses out the intialization functions
also note that while the generated static libries are large, the resultant executable won't be anywhere near as large. 

Example PortAudio  
Portaudio x64 build only uses gcc as compiler  
Dueltest ;example of bridging streams via a ring buffer from two threads (note you need to build the ring buffer librb first) 
FFTtest  ;uses a single callback on the input output streams and runs an FFT iFFT   

Example Raylib4 
Raylib4 x64, requires Mingw64 to be installed   
Screen  basic hello world example 
juliaset creates an anmiate fullscreen juilia set fractal with glsl shader    

Example MiniAudio 
x64 build of miniaudio requires mingw64 install 
miniaudio_duplex test recoreding from defalt mike and plays back on default speaker 



