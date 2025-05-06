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
  Protected p.i, o$, e$, adbres.s

p=RunProgram(GetEnvironmentVariable("comspec"),"/c "+comando,"",#PB_Program_Hide|#PB_Program_Open|#PB_Program_Read|#PB_Program_Error)

If p
While ProgramRunning(p)
  If AvailableProgramOutput(p)
     o$+ReadProgramString(p)+#CRLF$

   EndIf
   Delay(10)
  e$=ReadProgramError(p)
  If e$
     o$+e$+#CRLF$

  EndIf

Wend
If ProgramRunning(p)
  CloseProgram(p)
  EndIf
o$=ReplaceString(o$,"adb:","!")
o$=ReplaceString(o$,"/emulators","")
adbres=o$
    Else
        adbres = "! Error al ejecutar: " + comando
    EndIf

ProcedureReturn adbres
AddGadgetItem(2, -1, o$)
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
      TextGadget(330,  10, 10, 250,  20, "Working...", #PB_Text_Center)
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
  
  Procedure ScreenViewerThread(*Value)
  ; Deshabilitar botón en el hilo principal (usamos PostEvent)
  PostEvent(#PB_Event_Gadget, #Window_0, 151, #PB_EventType_Disable)
  AddGadgetItem(2, -1, "> Loading scrcpy...")
  
  ; Ejecutar comandos ADB
  o$ = adb("adb devices")
  
  If FindString(o$, "unauthorized")
    PostEvent(#PB_Event_Gadget, #Window_0, 151, #PB_EventType_Unauthorized)
  ElseIf Len(o$) > 29
    o$ = adb("adb kill-server")
    AddGadgetItem(2, -1, o$)
    o$ = adb("ptl\scrcpy")
    AddGadgetItem(2, -1, o$)
  Else
    PostEvent(#PB_Event_Gadget, #Window_0, 151, #PB_EventType_DeviceNotFound)
  EndIf
  
  ; Rehabilitar botón al finalizar
  PostEvent(#PB_Event_Gadget, #Window_0, 151, #PB_EventType_Enable)
ThreadID = 0  ; (opcional, para poder relanzar más tarde)
EndProcedure


Procedure GrabarVideo(*Dummy)
  
    VideoFinishedFilename = "video_" + FormatDate("%hh%ii%ss-%dd%mm%yyyy", Date())+".mp4"
    RecordingSeconds = 0
    
    ; Ejecutar screenrecord en segundo plano (60s)
    RunProgram("cmd", "/c adb shell screenrecord --time-limit 60 /sdcard/temp_rec.mp4", "", #PB_Program_Hide)
    
    ; Contador regresivo
    While RecordingActive And RecordingSeconds < 60
        Delay(1000)
        RecordingSeconds + 1
        PostEvent(#PB_Event_Gadget, #Window_0, 153, #PB_EventType_FirstCustomValue)
    Wend

    ; Esperar un poco para asegurar que el archivo se haya finalizado correctamente
    Delay(1000)
    
    ; Transferir el archivo (independientemente de la cancelación)
    RunProgram("cmd", "/c adb pull /sdcard/temp_rec.mp4 " + Chr(34) + "..\"+VideoFinishedFilename + Chr(34) + " & adb shell rm /sdcard/temp_rec.mp4", "", #PB_Program_Hide)
    
    ; Notificar que se terminó
    PostEvent(#PB_Event_Gadget, #Window_0, 153, #PB_EventType_FirstCustomValue + 1)
    
    ; Marcar grabación como inactiva
    RecordingActive = #False
  EndProcedure
  
  
  Procedure.s DetermineBootPartition();--A/B
    
    
   
  Protected o$, bootpart.s, hasSlot.s
  
 ; First we check if the device has an A/B partition system
o$ = adb("fastboot getvar has-slot:boot")
AddGadgetItem(2, -1, "Checking partition system: " + o$)

If FindString(o$, "has-slot:boot: yes")
    ; Device with A/B partitions
    AddGadgetItem(2, -1, "Device with A/B system detected")
    
    ; Get current slot
    o$ = adb("fastboot getvar current-slot")
    AddGadgetItem(2, -1, "Current slot: " + o$)
    
    If FindString(o$, "current-slot: a")
        bootpart = "boot_a"
    ElseIf FindString(o$, "current-slot: b")
        bootpart = "boot_b"
    Else
        ; Couldn't determine slot, using default value
        bootpart = "boot_a"
        AddGadgetItem(2, -1, "Warning: Could not determine slot! Using boot_a as default")
    EndIf
    
ElseIf FindString(o$, "has-slot:boot: no") Or FindString(o$, "has-slot:boot: not found")
    ; Device without A/B partitions
    AddGadgetItem(2, -1, "Device without A/B system detected")
    bootpart = "boot"
Else
    ; Couldn't determine, using default value
    AddGadgetItem(2, -1, "A/B system not detected. Using boot as default")
    bootpart = "boot"
EndIf

AddGadgetItem(2, -1, "Selected boot partition: " + bootpart)
ProcedureReturn bootpart
EndProcedure

Procedure.s DetectBootPartition()
    Protected resultado$, path$, i
    Dim commonPaths.s(5)
    
    ; Lista de posibles ubicaciones
    commonPaths(0) = "/dev/block/bootdevice/by-name/boot"
    commonPaths(1) = "/dev/block/platform/*/by-name/boot"
    commonPaths(2) = "/dev/block/mmcblk0boot0"
    commonPaths(3) = "/dev/block/platform/soc/by-name/boot"
    commonPaths(4) = "/dev/block/by-name/boot"
    commonPaths(5) = "/dev/block/platform/*/by-name/boot"
    
    ; Buscar la partición
    For i = 0 To ArraySize(commonPaths())
      AddGadgetItem(2, -1, "Buscando: " + commonPaths(i)):Delay(10)
        resultado$ = adb("adb shell su -c 'ls "+commonPaths(i)+"'")
        If FindString(resultado$, "/dev/block/", 1) And FindString(resultado$, "No such file or directory",1) = 0
            ;path$ = Trim(resultado$)
            path$ = commonPaths(i)
            AddGadgetItem(2, -1, "Detectada: " + path$)
            AutoScrollLog(2)
            ProcedureReturn path$
        EndIf
      Next
     AddGadgetItem(2, -1, "FallBack " + "/dev/block/mmcblk0boot0")
    ProcedureReturn "/dev/block/mmcblk0boot0" ; Fallback
EndProcedure

Procedure BackupBootIMG()
    Protected resultado$, bootPath$, fileSize, savePath$
    Protected Pattern$ = "Imagen boot (*.img)|*.img|Todos los archivos (*.*)|*.*"
    
    AddGadgetItem(2, -1, ">>> Inicio extracción boot.img <<<")
    
    ; 1. Detección automática de partición boot
    bootPath$ = DetectBootPartition()
    
     ; 1. Verificación ADB
    resultado$ = adb("adb devices")
    If Not FindString(resultado$, "device", 1)
        AddGadgetItem(2, -1, "[ERROR] Verifica conexión USB y depuración")
        ProcedureReturn
    EndIf
    
    ; 2. Verificación root (método confiable)
    resultado$ = adb("adb shell su -c 'id'")
    If Not FindString(resultado$, "uid=0", 1)
        AddGadgetItem(2, -1, "[ERROR] Root no detectado")
        ProcedureReturn
    EndIf
    
    ; 3. Extracción a /sdcard/
    AddGadgetItem(2, -1, "Extrayendo partición boot...")
    resultado$ = adb("adb shell su -c 'dd if=" + bootPath$ + " of=/sdcard/boot.img bs=4k'")
    
    ; 4. Selección de destino
    savePath$ = SaveFileRequester("Guardar boot.img como", "boot_backup", Pattern$, 0)
    savePath$+".img"
    If savePath$ = ""
        AddGadgetItem(2, -1, "Operación cancelada por usuario")
        ProcedureReturn
    EndIf
    
    ; 5. Copia directa al destino (manejo de espacios con #DQUOTE$)
    resultado$ = adb("adb pull /sdcard/boot.img " + #DQUOTE$ + savePath$+ #DQUOTE$)
    
    ; 6. Verificación final (usando FileSize para existencia y tamaño)
    fileSize = FileSize(savePath$)
    Select fileSize
        Case -1
            AddGadgetItem(2, -1, "[ERROR] No se creó el archivo")
        Case 0 To 204799
            AddGadgetItem(2, -1, "[ERROR] Archivo muy pequeño (" + Str(fileSize) + " bytes)")
            If fileSize > 0 : DeleteFile(savePath$) : EndIf
        Default
            AddGadgetItem(2, -1, "✔ Backup correcto (" + Str(fileSize/1024) + " KB)")
            AddGadgetItem(2, -1, "Ubicación: " + savePath$)
    EndSelect
    
    ; Limpieza siempre
    adb("adb shell rm /sdcard/boot.img")
    AutoScrollLog(2)
  EndProcedure
 
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 298
; FirstLine = 12
; Folding = Ag-
; EnableXP