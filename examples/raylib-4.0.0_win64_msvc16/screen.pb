
ImportC "e:\andrews\pbstuff\pbcex\examples\raylib-4.0.0_win64_msvc16\raylibdll.lib" : EndImport  ;<-change paths 
!//gccflags -IC:\llvm-mingw-20211002-msvcrt-x86_64\lib\clang\13.0.0\include;                  ;<-change paths 
!//#include "e:\andrews\pbstuff\pbcex\examples\raylib-4.0.0_win64_msvc16\include\raylib.h";      ;<-change paths 
  
Global screenwidth = 800;
Global screenheight = 450;

!InitWindow(v_screenwidth, v_screenheight, "raylib [core] example - 3d camera free");

;// Define the camera To look into our 3d world
!Camera camera = { 0 };
!camera.position = (Vector3){ 10.0f, 10.0f, 10.0f };
!camera.target = (Vector3){ 0.0f, 0.0f, 0.0f };
!camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };
!camera.fovy = 45.0f;
!camera.projection = CAMERA_PERSPECTIVE;

!Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };
!Vector2 cubeScreenPosition = { 0.0f, 0.0f };

!SetCameraMode(camera, CAMERA_FREE); // Set a free camera mode

!SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second

;// Main game loop
Global state 

While state = 0 
                
  !UpdateCamera(&camera);          // Update camera
  
  ;// Calculate cube screen space position (With a little offset To be in top)
  !cubeScreenPosition = GetWorldToScreen((Vector3){cubePosition.x, cubePosition.y + 2.5f, cubePosition.z}, camera);
  ;//----------------------------------------------------------------------------------
  
  ;// Draw
  ;//----------------------------------------------------------------------------------
  !BeginDrawing();
  
  !ClearBackground(RAYWHITE);
  
  !BeginMode3D(camera);
  
  !DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, RED);
  !DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, MAROON);
  
  !DrawGrid(10, 1.0f);
  
  !EndMode3D();
  
  *msg = UTF8(FormatDate("%hh:%ii:%ss", Date()))    
  !DrawText(p_msg, (int)cubeScreenPosition.x - MeasureText(p_msg, 20)/2, (int)cubeScreenPosition.y, 20, BLACK);
  !DrawText("Text is always on top of the cube", (v_screenwidth - MeasureText("Text is always on top of the cube", 20))/2, 25, 20, GRAY);
  FreeMemory(*msg) 
  !EndDrawing();
  ;//----------------------------------------------------------------------------------
  !v_state = WindowShouldClose();   
Wend 

;//--------------------------------------------------------------------------------------
!CloseWindow();        // Close window and OpenGL context
;//--------------------------------------------------------------------------------------
    
; IDE Options = PureBasic 6.01 LTS beta 1 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 17
; EnableThread
; EnableXP
; DPIAware
; Compiler = PureBasic 6.01 LTS beta 1 - C Backend (Windows - x64)