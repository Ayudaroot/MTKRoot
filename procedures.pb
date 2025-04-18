Procedure UnZip(zipfile.s)
  
  Define Folder.s,NewFolder.s
  
  Folder = "drivers"
  TempFolder = GetPathPart(ZipFile)
  PackID = OpenPack(#PB_Any, ZipFile,#PB_PackerPlugin_Zip)
  If ExaminePack(PackID)
    While NextPackEntry(PackID)
      NewFolder = GetPathPart(PackEntryName(PackID))
      ;CreatePath(TempFolder + Folder + "\" + NewFolder)
      UncompressPackFile(PackID, Folder + "\" + PackEntryName(PackID)) 
    Wend
    ClosePack(PackID)
    ;RenameFile(ZipFile, GetPathPart(ZipFile) + "(old)" + GetFilePart(ZipFile))  
  EndIf
  
EndProcedure

Procedure.s adb(comando.s)

p=RunProgram(GetEnvironmentVariable("comspec"),"/c "+comando,"",#PB_Program_Hide|#PB_Program_Open|#PB_Program_Read|#PB_Program_Error)

While ProgramRunning(p)
  If AvailableProgramOutput(p)
     o$+ReadProgramString(p)+#CRLF$

  EndIf
  e$=ReadProgramError(p)
  If e$
     o$+e$+#CRLF$

  EndIf

Wend
CloseProgram(p)
o$=ReplaceString(o$,"adb:","!")
o$=ReplaceString(o$,"/emulators","")
adbres.s=o$

ProcedureReturn adbres
AddGadgetItem(2, -1, o$)
EndProcedure


Procedure.s adbf(comando.s)

p=RunProgram(GetEnvironmentVariable("comspec"),"/c "+comando,"",#PB_Program_Wait)


adbres.s=o$
SetGadgetText(2,o$)
ProcedureReturn adbres

EndProcedure


Procedure.i Is64BitOS()
; [DESC]
; Check if the OS under which the program is running is a 64 bit OS.
;
; [RETURN]
; 1 for 64 bit OS, else 0.

 Protected Is64BitOS = 0
 Protected hDLL, IsWow64Process_
 
 If SizeOf(Integer) = 8
    Is64BitOS = 1 ; this is a 64 bit exe
 Else
    hDll = OpenLibrary(#PB_Any,"kernel32.dll")
    If hDll
        IsWow64Process_ = GetFunction(hDll,"IsWow64Process")
        If IsWow64Process_
            CallFunctionFast(IsWow64Process_, GetCurrentProcess_(), @Is64BitOS)
        EndIf
        CloseLibrary(hDll)
    EndIf     
 EndIf
 
 ProcedureReturn Is64BitOS
EndProcedure

Procedure trabajando() 
      
      If OpenWindow(31, 348, 135, 300, 100, "",  #PB_Window_TitleBar )
      TextGadget(330,  10, 10, 250,  20, "Trabajando en ello ......", #PB_Text_Center)
      ProgressBarGadget(340,  10, 40, 275,  30, 0, 100)
      HideWindow(0, #True)
   Repeat
         Event3 = WaitWindowEvent()
Select Event3
  Case #PB_Event_Gadget
Select EventGadget()
  ;Case 120
 EndSelect
EndSelect
For a=0 To 100
  SetGadgetState(340, a):Delay(15)
  Next
Until a > 99 Or Event2 = #PB_Event_CloseWindow
HideWindow(0, #False):CloseWindow(31):a-a
EndIf
EndProcedure

; --- Declaración de imágenes ---
Global Dim Images.i(30)  ; Índices 0-28
; --- Carga optimizada de imágenes ---
Procedure LoadImages()
  ; Carga todas las imágenes usando un array global Images()
  For i = 0 To 30
    Select i
      Case 0
        Images(i) = CatchImage(i, ?Image0)
      Case 1
        Images(i) = CatchImage(i, ?Image1)
      Case 10
        Images(i) = CatchImage(i, ?Image10)
      Case 11
        Images(i) = CatchImage(i, ?Image11)
      Case 12
        Images(i) = CatchImage(i, ?Image12)
      Case 13
        Images(i) = CatchImage(i, ?Image13)
      Case 14
        Images(i) = CatchImage(i, ?Image14)
      Case 15
        Images(i) = CatchImage(i, ?Image15)
      Case 16
        Images(i) = CatchImage(i, ?Image16)
      Case 17
        Images(i) = CatchImage(i, ?Image17)
      Case 18
        Images(i) = CatchImage(i, ?Image18)
      Case 19
        Images(i) = CatchImage(i, ?Image19)
      Case 20
        Images(i) = CatchImage(i, ?Image20)
      Case 21
        Images(i) = CatchImage(i, ?Image21)
      Case 22
        Images(i) = CatchImage(i, ?Image22)
      Case 23
        Images(i) = CatchImage(i, ?Image23)
      Case 25
        Images(i) = CatchImage(i, ?Image25)
      Case 26
        Images(i) = CatchImage(i, ?Image26)
      Case 27
        Images(i) = CatchImage(i, ?Image27)
      Case 28
        Images(i) = CatchImage(i, ?Image28)
      Case 29
        Images(i) = CatchImage(i, ?Image29)
              Case 30
        Images(i) = CatchImage(i, ?Image30)
    EndSelect
    
    ; Verificación de carga (excepto índices no usados como 24)
    If Not Images(i) And i <> 2 And i <> 3 And i <> 4 And i <> 5 And i <> 6 And i <> 7 And i <> 8 And i <> 9 And i <> 24 And i < 31
      Debug "[Error] Fallo al cargar imagen índice " + Str(i)
    EndIf
  Next
EndProcedure

Procedure AutoScrollLog(gadgetID.i)
    iPause.i = 10
    iLine.i = 1
    iTotal.i = CountGadgetItems(gadgetID)
    While (iLine < iTotal)
        Delay(iPause)
        SendMessage_(GadgetID(gadgetID), #EM_LINESCROLL, 0, 1)
        iLine + 1
    Wend
EndProcedure

Procedure ShowProgressWindow()
    If OpenWindow(3, 348, 135, 300, 100, "", #PB_Window_TitleBar)
        TextGadget(33, 10, 10, 250, 20, "Trabajando en ello...", #PB_Text_Center)
        ProgressBarGadget(34, 10, 40, 275, 30, 0, 100)
        HideWindow(0, #True)
        
        For a = 0 To 100
            SetGadgetState(34, a)
            Delay(10)
            While WindowEvent() : Wend ; Procesar eventos pendientes
        Next
        
        HideWindow(0, #False)
        CloseWindow(3)
    EndIf
EndProcedure
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 106
; FirstLine = 47
; Folding = x-
; EnableXP