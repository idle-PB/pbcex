; /*******************************************************************************************
; *
; *   raylib [shaders] example - julia sets
; *
; *   NOTE: This example requires raylib OpenGL 3.3 Or ES2 versions For shaders support,
; *         OpenGL 1.1 does Not support shaders, recompile raylib To OpenGL 3.3 version.
; *
; *   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
; *
; *   This example has been created using raylib 2.5 (www.raylib.com)
; *   raylib is licensed under an unmodIfied zlib/libpng license (View raylib.h For details)
; *
; *   Example contributed by eggmund (@eggmund) And reviewed by Ramon Santamaria (@raysan5)
; *
; *   Copyright (c) 2019 eggmund (@eggmund) And Ramon Santamaria (@raysan5)
; *
; ********************************************************************************************/

;note 
;set the correct paths on lines 22,27,28,65

ImportC "d:\idle\pbstuff\pbcex\examples\raylib-4.0.0_win64_msvc16\raylibdll.lib"     ;<- change path 
  IsMouseButtonDown(button) 
  IsKeyPressed(key) 
EndImport 

!//gccflags -IC:\llvm-mingw-20211002-msvcrt-x86_64\lib\clang\13.0.0\include;                      ;<- change path 
!//#include "d:\idle\pbstuff\pbcex\examples\raylib-4.0.0_win64_msvc16\include\raylib.h";       ;<- change path 

!#define GLSL_VERSION 330
!#if defined(PLATFORM_DESKTOP)
!#define GLSL_VERSION 330
!#endif

Global pause,showControls,*shaderpath 

#KEY_F1 = 290 
#KEY_RIGHT = 262
#KEY_LEFT   = 263
#MOUSE_BUTTON_LEFT    = 0;       // Mouse button left
#MOUSE_BUTTON_RIGHT   = 1;       // Mouse button right
#MOUSE_BUTTON_MIDDLE  = 2;       // Mouse button middle (pressed wheel)
#MOUSE_BUTTON_SIDE    = 3;       // Mouse button side (advanced mouse device)
#MOUSE_BUTTON_EXTRA   = 4;       // Mouse button extra (advanced mouse device)
#MOUSE_BUTTON_FORWARD = 5;       // Mouse button fordward (advanced mouse device)
#MOUSE_BUTTON_BACK    = 6;       // Mouse button back (advanced mouse device)

;// A few good julia sets
!const float pointsOfInterest[6][2] = {{ -0.348827f, 0.607167f },{ -0.786268f, 0.169728f },{ -0.8f, 0.156f },{ 0.285f, 0.0f },{ -0.835f, -0.2321f },{ -0.70176f, -0.3842f }};

;// Initialization
;//--------------------------------------------------------------------------------------
ExamineDesktops() 
screenwidth = DesktopWidth(0)
screenheight = DesktopHeight(0)
;!const int screenWidth = 800;
;!const int screenHeight = 450;

!SetConfigFlags(FLAG_WINDOW_HIGHDPI);
!InitWindow(v_screenwidth, v_screenheight, "raylib [shaders] example - julia sets");

;// Load julia set shader
;// NOTE: Defining 0 (NULL) For vertex shader forces usage of internal Default vertex shader

*shaderpath = UTF8("d\idle\pbstuff\pbcex\examples\raylib-4.0.0_win64_msvc16\examples\shaders\resources\shaders\glsl330\julia_set.fs")   ; <----change path 
!Shader shader = LoadShader(0, TextFormat(p_shaderpath, GLSL_VERSION));
FreeMemory(*shaderpath) 

;// Create a RenderTexture2D To be used For render To texture
!RenderTexture2D target = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
    
;// c constant To use in z^2 + c
!float c[2] = { pointsOfInterest[0][0], pointsOfInterest[0][1] };
    
;// Offset And zoom To draw the julia set at. (centered on screen And Default size)
!float offset[2] = { -(float)GetScreenWidth()/2, -(float)GetScreenHeight()/2 };
!float zoom = 1.0f                                                            ;
    
!Vector2 offsetSpeed = { 0.0f, 0.0f };
    
;// Get variable (unIform) locations on the shader To connect With the program
;// NOTE: If unIform variable could Not be found in the shader, function returns -1
!int cLoc = GetShaderLocation(shader, "c");
!int zoomLoc = GetShaderLocation(shader, "zoom");
!int offsetLoc = GetShaderLocation(shader, "offset");
        
;// Tell the shader what the screen dimensions, zoom, offset And c are
!float screenDims[2] = { (float)GetScreenWidth(), (float)GetScreenHeight() };
!SetShaderValue(shader, GetShaderLocation(shader, "screenDims"), screenDims, SHADER_UNIFORM_VEC2);
        
!SetShaderValue(shader, cLoc, c, SHADER_UNIFORM_VEC2);
!SetShaderValue(shader, zoomLoc, &zoom, SHADER_UNIFORM_FLOAT);
!SetShaderValue(shader, offsetLoc, offset, SHADER_UNIFORM_VEC2);
        
!int incrementSpeed = 0;     // Multiplier of speed to change c value
ShowControls = -1;           // Show controls
pause = 0      ;             // Pause animation
        
!SetTargetFPS(60);           // Set our game to run at 60 frames-per-second
;//--------------------------------------------------------------------------------------

Repeat 
  ;Press [1 - 6] To reset c To a point of interest
  If Not IsKeyPressed(0) 
    If IsKeyPressed(Asc("1"))
      !c[0] = pointsOfInterest[0][0];
      !c[1] = pointsOfInterest[0][1];
    ElseIf IsKeyPressed(Asc("2"))
      !c[0] = pointsOfInterest[1][0];
      !c[1] = pointsOfInterest[1][1];
    ElseIf IsKeyPressed(Asc("3"))
      !c[0] = pointsOfInterest[2][0];
      !c[1] = pointsOfInterest[2][1];
    ElseIf IsKeyPressed(Asc("4"))
      !c[0] = pointsOfInterest[3][0];
      !c[1] = pointsOfInterest[3][1];
    ElseIf IsKeyPressed(Asc("5"))
      !c[0] = pointsOfInterest[4][0];
      !c[1] = pointsOfInterest[4][1];
    ElseIf IsKeyPressed(Asc("6"))
      !c[0] = pointsOfInterest[5][0];
      !c[1] = pointsOfInterest[5][1];
    EndIf      
    !SetShaderValue(shader, cLoc, c, SHADER_UNIFORM_VEC2);
  EndIf 
  
  If IsKeyPressed(Asc(" ")) 
    pause = ~pause;
  EndIf          
  If IsKeyPressed(#KEY_F1) 
    showControls = ~showControls 
  EndIf                       
  If Not pause
    If IsKeyPressed(#KEY_RIGHT) 
      !incrementSpeed++;
    ElseIf IsKeyPressed(#KEY_LEFT)
      !incrementSpeed--;
    EndIf   
    If (IsMouseButtonDown(#MOUSE_BUTTON_LEFT) Or IsMouseButtonDown(#MOUSE_BUTTON_RIGHT))
      If IsMouseButtonDown(#MOUSE_BUTTON_LEFT) 
        !zoom += zoom*0.003f;
      EndIf   
      If IsMouseButtonDown(#MOUSE_BUTTON_RIGHT)
        !zoom -= zoom*0.003f;
      EndIf                               
      !Vector2 mousePos = GetMousePosition();
      
      !offsetSpeed.x = (mousePos.x*zoom) -(float)((v_screenwidth/2)*zoom);
      !offsetSpeed.y = (mousePos.y*zoom) -(float)((v_screenheight/2)*zoom);
      
      !offset[0] += GetFrameTime()*offsetSpeed.x*0.5f;
      !offset[1] += GetFrameTime()*offsetSpeed.y*0.5f;
    Else 
      !offsetSpeed = (Vector2) { 0.0f, 0.0f };
    EndIf                                
    
    !SetShaderValue(shader, zoomLoc, &zoom, SHADER_UNIFORM_FLOAT);
    !SetShaderValue(shader, offsetLoc, offset, SHADER_UNIFORM_VEC2);
    
    ;// Increment c value With time
    !float amount = GetFrameTime()*incrementSpeed*0.0005f;
    !c[0] += amount                                      ;
    !c[1] += amount                                      ;
    
    !SetShaderValue(shader, cLoc, c, SHADER_UNIFORM_VEC2);
  EndIf 
  ;//----------------------------------------------------------------------------------
  ;// Draw
  ;//----------------------------------------------------------------------------------
  ;// Using a render texture To draw Julia set
  !BeginTextureMode(target);       // Enable drawing to texture
  !ClearBackground(BLACK)  ;     // Clear the render texture
  
  ;// Draw a rectangle in shader mode To be used As shader canvas
  ;// NOTE: Rectangle uses font white character texture coordinates,
  ;// so shader can Not be applied here directly because input vertexTexCoord
  ;// do Not represent full screen coordinates (space where want To apply shader)
  !DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);
  !EndTextureMode()                                               ;
  
  !BeginDrawing();
  !ClearBackground(BLACK);     // Clear screen background
  
  ;// Draw the saved texture And rendered julia set With shader
  ;// NOTE: We do Not invert texture on Y, already considered inside shader
  !BeginShaderMode(shader);
  ;// WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
  ;// when rendering the RenderTexture2D To fit in the HighDPI scaled Window
  !DrawTextureEx(target.texture, (Vector2){ 0.0f, 0.0f }, 0.0f, 1.0f, WHITE);
  !EndShaderMode()                                                          ;
  
  If showControls
    !DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, RAYWHITE);
    !DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, RAYWHITE)                 ;
    !DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, RAYWHITE)        ;
    !DrawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, RAYWHITE)            ;
    !DrawText("Press KEY_SPACE to pause movement animation", 10, 75, 10, RAYWHITE)           ;
  EndIf 
  !EndDrawing();
  !v_close = WindowShouldClose();  
Until close 

;                                     // De-Initialization
;                                     //--------------------------------------------------------------------------------------
!UnloadShader(shader);               // Unload shader
!UnloadRenderTexture(target);        // Unload render texture

!CloseWindow();                      // Close window and OpenGL context
;                                    //--------------------------------------------------------------------------------------
                                                
                                                            

; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 42
; FirstLine = 90
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.00 Beta 10 - C Backend (Windows - x64)