
UseZipPacker()

Structure Entry
  type.i
  Name.s
EndStructure

Global NewList Content.Entry()

Global TempFolder.s,ZipFile.s, bootpart.s
Global btnUnZip.i,btnAdd.i,btnZip.i,PackID.i

IncludeFile("procedures.pb")

SetCurrentDirectory("DATA/")

UsePNGImageDecoder() : UseJPEGImageDecoder()


; --- Datos binarios ---
DataSection
  Image0:
  IncludeBinary "logos\logo.png"
  Image1:
  IncludeBinary "logos\loadboot.jpg"
  Image10:
  IncludeBinary "logos\mediatek_logo.jpg"
  Image11:
  IncludeBinary "logos\qualcomm.jpg"
  Image12:
  IncludeBinary "logos\Spreadtrum.jpg"
  Image13:
  IncludeBinary "logos\391930.jpg"
  Image14:
  IncludeBinary "logos\sam.jpg"
  Image15:
  IncludeBinary "logos\yyy.jpg"
  Image16:
  IncludeBinary "logos\motorola-logo-1.jpg"
  Image17:
  IncludeBinary "logos\huawei-logo.jpg"
  Image18:
  IncludeBinary "logos\root_browser.jpg"
  Image19:
  IncludeBinary "logos\busybox.jpg"
  Image20:
  IncludeBinary "logos\ramexpander.jpg"
  Image21:
  IncludeBinary "logos\devicecontrol.jpg"
  Image22:
  IncludeBinary "logos\rootuninstaller.jpg"
  Image23:
  IncludeBinary "logos\twrp.jpg"
  Image25:
  IncludeBinary "logos\magisk.jpg"
  Image26:
  IncludeBinary "logos\umagisk.jpg"
  Image27:
  IncludeBinary "logos\adbcom.jpg"
  Image28:
  IncludeBinary "logos\actualizar.png"
EndDataSection

; --- Uso ---
LoadImages()  ; Cargar al inicio del programa


IncludeFile("help\help.pb")

; --- Ventana 20% más grande (504x660) ---
If OpenWindow(0, 0, 0, 504, 660, "MTKroot v3.0 (2025)", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget)
  version.s = "3.0"
  
  ; --- Menú principal ---
  If CreateImageMenu(0, WindowID(0), #PB_Menu_ModernLook)
    MenuTitle("Archivo")
    MenuItem(50, "Cargar", Images(1))  ; Cambiado a Image1 (sin ImageID)
  EndIf
  
  ;-===== SECCIÓN IZQUIERDA (Acciones principales) =====
  FrameGadget(100, 10, 10, 200, 250, "Herramientas Root")
  ButtonGadget(0, 20, 40, 180, 30, "Procesar Parche") 
  GadgetToolTip(0, "Transfiere el archivo boot para parchearlo")   
  ButtonGadget(16, 20, 80, 180, 30, "Apps")
  GadgetToolTip(16, "Repertorio de aplicaciones") 
   ButtonGadget(14,20,200,180,30,"Drivers");IZD
 GadgetToolTip(14, "Lista de controladores USB/Vcom para instalar") 
  ButtonGadget(15, 20, 120, 180, 30, "Check Root")
  GadgetToolTip(15, "Comprueba el estado root")
  ButtonGadget(8, 20, 160, 180, 30, "Liberar Bootloader")
  GadgetToolTip(8, "Intenta liberar el bootloader") 

  ;-===== SECCIÓN CENTRAL (Estado/Imagen) =====
  ImageGadget(1111, 220, 40, 131, 103, Images(0))  ; Imagen central
  
  ;--- Opciones Root/Unroot ---
  FrameGadget(101, 220, 160, 131, 80, "Modo")
  OptionGadget(20, 230, 190, 60, 20, "Rootear")
  OptionGadget(21, 230, 220, 80, 20, "Desrootear")
  SetGadgetState(20, #True)

  ;-===== SECCIÓN DERECHA (ADB/Fastboot) =====
  FrameGadget(102, 360, 10, 130, 250, "Conexión")
  ButtonGadget(3, 370, 40, 110, 30, "Test ADB")
  GadgetToolTip(3, "Verifica conexión ADB") 
  ButtonGadget(4, 370, 80, 110, 30, "Test Fastboot")
  GadgetToolTip(4, "Verifica conexión Fastboot") 
  ButtonGadget(5, 370, 120, 110, 30, "Ir Fastboot")
  GadgetToolTip(5, "Reinicia en modo Fastboot") 
  ButtonGadget(6, 370, 160, 110, 30, "Salir Fastboot")
  GadgetToolTip(6, "Reinicia en modo normal") 
  ButtonGadget(7, 370, 200, 110, 30, "Reiniciar Disp.")
  
  ; ===== SECCIÓN INFERIOR (Consola/Botones extra) =====
  EditorGadget(2, 10, 300, 484, 250, #PB_Editor_ReadOnly)
  SetGadgetColor(2, #PB_Gadget_BackColor, RGB(0, 0, 0))
  SetGadgetColor(2, #PB_Gadget_FrontColor, RGB(126, 178, 25))
  
  ; --- Botones inferiores ---
  ButtonGadget(151, 10, 560, 120, 30, "Controlar pantalla")
  GadgetToolTip(151, "Control remoto del dispositivo") 
  ButtonGadget(18, 140, 560, 120, 30, "Test Bootloader")
  GadgetToolTip(18, "Verifica estado del bootloader") 
  ButtonGadget(1, 270, 560, 120, 30, "Root/Unroot")
  GadgetToolTip(1, "Ejecuta la acción seleccionada") 
  ButtonImageGadget(131, 400, 560, 40, 30, Images(27))  ; Icono consola
  GadgetToolTip(131, "Abrir consola ADB") 
  ButtonImageGadget(250, 450, 560, 40, 30, Images(28))  ; Icono actualizar
  GadgetToolTip(250, "Buscar actualizaciones") 

  ; --- Bucle de eventos ---


 DisableGadget(1,1)
 DisableGadget(8,1)
 DisableGadget(6,1)
 DisableGadget(0,1)
 DisableGadget(18,1)
 
 inicio:
 
If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1
  source$=rai$+"unroot\"+"unroot.img"
  si=1:SetMenuTitleText(0,0,"Boot cargado")
  SetMenuItemText(0, 50, "Expulsar")
   DisableGadget(0,0):CloseFile(0)
 EndIf
 
 If ReadFile(0,rai$+"root\"+"root.img"):rsi=1
   rsi=1
   CloseFile(0)
EndIf
  
  Repeat
    o$=""
   
Event = WaitWindowEvent()
Select Event
    
    Case #PB_Event_Menu
      Select EventMenu()  ; To see which menu has been selected
          
        Case 50 ;--cargar----archivo
          
          If GetMenuItemText(0, 50)="Expulsar";;;;;1
            sino=MessageRequester("ATENCION !","Esto eliminara los parches root.img y unroot.img",#PB_MessageRequester_YesNo)
            If sino=#PB_MessageRequester_Yes
   source$=""
   si=0:rsi=0:psi=0
   DeleteFile(rai$+"unroot\"+"unroot.img")
   DeleteFile(rai$+"root\"+"root.img")
   SetMenuTitleText(0,0,"No hay boot !!")
   SetMenuItemText(0, 50, "Cargar")
   DisableGadget(1,1)
   EndIf
 Else
   
 rai$=GetCurrentDirectory()

If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1
 source$=rai$+"unroot\"+"unroot.img":CloseFile(0)
Else
 source$=OpenFileRequester("Selecciona archivo a procesar", "boot.img", "img (*.img)|*.img", 0)
EndIf

archivo$=GetFilePart(source$)

If ReadFile(1,source$)=0 And psi =0:si=0
  MessageRequester("Error","No ha seleccionado el archivo",0)
Else
  si=1:SetMenuTitleText(0,0,"Boot cargado")
  SetMenuItemText(0, 50, "Expulsar")
  AddGadgetItem(2,-1,archivo$)
  DisableGadget(0,0)
   CloseFile(1)
EndIf

EndIf ;;;;;;1

   EndSelect
    
Case #PB_Event_Gadget
  Select EventGadget()
      
    Case 0 ;--procesar---archivo
      DisableGadget(0,1)
      
      If ReadFile(6,rai$+"unroot\"+"unroot.img")
        sino=MessageRequester("ATENCIÓN!","Ya hay un archivo procesado ¿Quieres sobreescribirlo?",#PB_MessageRequester_YesNo)
        If sino=#PB_MessageRequester_Yes
          DeleteFile(rai$+"unroot\"+"unroot.img")
          DeleteFile(rai$+"root\"+"root.img")
          EndIf:CloseFile(6):EndIf
      If CopyFile(source$,rai$+"unroot\"+"unroot.img") = 1:procesoa=1:EndIf
      ;Debug procesoa
      
 AddGadgetItem(2, -1, "Copiado ==> "+archivo$)

o$=adb("adb push "+Chr(34)+rai$+"unroot\"+"unroot.img"+Chr(34)+" /sdcard/")
AddGadgetItem(2, -1, "Transfiriendo > "+o$)
o$=adb("aprm /sdcard/Download/magisk_patched*.img")
   
iPause.i = 10
iLine.i = 1
iTotal.i = CountGadgetItems(2)
While (iLine < iTotal)
                Delay(iPause)
         SendMessage_(GadgetID(2),#EM_LINESCROLL,0,1)
         iLine = iLine + 1
       Wend
       AddGadgetItem(2, -1, "Abriendo App Magisk _Manager ")
    
       adb("adb shell monkey -p com.topjohnwu.magisk -c android.intent.category.LAUNCHER 1")

       If procesoa=1:AddGadgetItem(2, -1, "Archivo Procesado correctamente > "):EndIf
       
       
       abra()


     
       o$=adb("apll /sdcard/Download/magisk_patched*.img")
       AddGadgetItem(2, -1, " Método > 1 ")
       If FindString(o$,"remote object")
         o$=adb("apll2 /storage/emulated/0/Download/magisk_patched*.img")
         AddGadgetItem(2, -1, " Método > 2 ")
      EndIf
       AddGadgetItem(2, -1, "Transfiriendo > "+o$)
   
iPause.i = 10
iLine.i = 1
iTotal.i = CountGadgetItems(2)
While (iLine < iTotal)
                Delay(iPause)
         SendMessage_(GadgetID(2),#EM_LINESCROLL,0,1)
         iLine = iLine + 1
       Wend

       
If ExamineDirectory(0, rai$, "*.img")
 While NextDirectoryEntry(0)
   If RenameFile(rai$+DirectoryEntryName(0),rai$+"root\"+"root.img")
     AddGadgetItem(2, -1, " OK ")
   Else
     Delay(2000)
     RenameFile(rai$+DirectoryEntryName(0),rai$+"root\"+"root.img")
     EndIf
 Wend
EndIf

       
       
   If OpenWindow(3, 348, 135, 300, 100, "",  #PB_Window_TitleBar )
      TextGadget(33,  10, 10, 250,  20, "Trabajando en ello ...", #PB_Text_Center)
      ProgressBarGadget(34,  10, 40, 275,  30, 0, 100)
      HideWindow(0, #True)
   Repeat
         Event3 = WaitWindowEvent()
Select Event3
  Case #PB_Event_Gadget
Select EventGadget()
  Case 120
 EndSelect

EndSelect
For a=0 To 100
  SetGadgetState(34, a):Delay(10)
  Next
Until a > 99 Or Event2 = #PB_Event_CloseWindow
HideWindow(0, #False):CloseWindow(3):a-a
EndIf
       
MessageRequester("Fin","Proceso finalizado !")

DisableGadget(0,0)
     
     Case 1;--Root/Unroot-----------------------   
       
  SetGadgetText(2,"")
  
  If GetGadgetState(20) <>0
    AddGadgetItem(2, -1, "Seleccionado ROOT")
    
    o$=adb("fastboot getvar current-slot")
    AddGadgetItem(2, -1, o$)
    bootpart="boot"
    If FindString(o$,"current-slot: a"):bootpart="boot_a":EndIf
    If FindString(o$,"current-slot: b"):bootpart="boot_b":EndIf
    
    resroot=MessageRequester("","Lanzar root temporal?", #PB_MessageRequester_Info | #PB_MessageRequester_YesNo)
    If resroot = #PB_MessageRequester_Yes
      o$=adb("fastboot "+bootpart+" "+Chr(34)+rai$+"root\"+"root.img"+Chr(34))
      Else
      o$=adb("fastboot flash "+bootpart+" "+Chr(34)+rai$+"root\"+"root.img"+Chr(34))
    EndIf
       
 AddGadgetItem(2, 1, "==OK==")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, "> Pulsa Salir de Fastboot.")

ElseIf GetGadgetState(21)<>0
   AddGadgetItem(2, -1, "Seleccionado UNROOT ")
   o$=adb("fastboot flash boot "+Chr(34)+rai$+"unroot\"+"unroot.img"+Chr(34))
   AddGadgetItem(2, 1, "==OK==")
   AddGadgetItem(2, -1, o$)
   AddGadgetItem(2, -1, "> Pulsa Salir de Fastboot.")
EndIf

 
 
Case 3 ;--TEST ADB---------------------------
  DisableGadget(3,1)
  SetGadgetText(2,"")
  o$=adb("adb devices")
  If FindString(o$,"unauthorized"):abra2():EndIf
   
  If Len(o$)>29
     o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
     o$=Trim(ReplaceString(o$,"device","",1,1))
     device$=o$
     info.s=adb("adb devices -l")
     
     producto.s=StringField(info, 2, ":"):producto= ReplaceString(producto, "_"," "):producto=RemoveString(producto, "model")
     producto=Trim(producto)
     modelo.s=StringField(info, 3, ":"):modelo= ReplaceString(modelo, "_"," "):modelo=RemoveString(modelo, "device")
     modelo=Trim(modelo)
If modelo = producto:modelo="":EndIf
device.s=StringField(info, 4, ":"):device= ReplaceString(device, "_"," ")
device=Trim(device)
If device = producto:device="":EndIf
     
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, "Dispositivo detectado")
 AddGadgetItem(2, -1, "")
 AddGadgetItem(2, -1, producto+" "+modelo)
 adbon=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Dispositivo desconectado")
  abra3()
EndIf
DisableGadget(3,0)

Case 4;--TEST FASTBOOT=======================
  DisableGadget(4,1)
  
  o$=adb("fastboot devices")

  If Len(o$)>10
     
    o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
    device$=o$
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, "Dispositivo detectado")
 DisableGadget(8,0)
 DisableGadget(6,0)
 DisableGadget(18,0)
 fastbooton=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Fastboot desconectado. Pulsa Ir Fastboot")
  fastbooton=0
EndIf
DisableGadget(4,0)

Case 5 ;--IR A FASTBOOT
  DisableGadget(5,1)
  AddGadgetItem(2, -1, "Reiniciando a Fastboot ...")
  SetGadgetText(2,"")
  o$=adb("adb reboot bootloader")
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 DisableGadget(5,0)
 
 
Case 6 ;--SALIR DE FASTBOOT
  DisableGadget(6,1)
  cmd$="fastboot reboot"
  o$=adb(cmd$)
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" Saliendo de Fastboot")
 DisableGadget(6,0)
 
Case 7;--REINICIAR===============
  DisableGadget(7,1)
  cmd$="adb reboot"
  o$=adb(cmd$)
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" Saliendo de ADB")
 DisableGadget(7,0)
 
Case 8;--LIBERAR BOOTLOADER==========================
  DisableGadget(8,1)
    MessageRequester("Atención","El dispositivo será reestablecido",0)
  o$=adb("fastboot flashing unlock")
  o$=adb("fastboot oem unlock")
  o$=adb("fastboot oem unlock-go")
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" desbloqueando Bootloader")
 AddGadgetItem(2, -1, "Confirme la operación desde")
 AddGadgetItem(2, -1, "la pantalla del dispositivo")
 DisableGadget(8,0)
 
Case 9;--REINICIAR USB
  DisableGadget(9,1)
  o$=adb("adb usb")
  AddGadgetItem(2, -1, o$)
  DisableGadget(9,0)
  
Case 131
  DisableGadget(131,1)
       RunProgram("cmd")
       DisableGadget(131,0)
       
     Case 14 ;--instalar drivers
       DisableGadget(14,1)
       
       If OpenWindow(1, 353, 198, 247, 310, "Instalar Drivers", #PB_Window_TitleBar | #PB_Window_SystemMenu )
         SetActiveWindow(1)
   
      ButtonImageGadget(111, 20, 30, 80, 30, Images(10))
      ButtonImageGadget(112, 20, 100, 80, 30, Images(11))
      ButtonImageGadget(113, 20, 160, 80, 30, Images(12))
      ButtonImageGadget(114, 150, 220, 80, 30, Images(13))
      ButtonImageGadget(115, 150, 30, 80, 30, Images(14))
      ButtonImageGadget(116, 150, 100, 80, 30, Images(15))
      ButtonImageGadget(117, 150, 160, 80, 30, Images(16))
      ButtonImageGadget(118, 20, 220, 80, 30, Images(17))
      ButtonGadget(119, 90, 275, 90, 20, "Cancelar")

        Repeat
    Event2 = WaitWindowEvent()
Select Event2
  Case #PB_Event_Gadget
    Select EventGadget()
          
      Case 111; MTK
        SetWindowTitle(1,"Espere, por favor...")
        ;InitNetwork()
        If ReadFile(1,"drivers\drvmtk.exe")=0
          If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/0tlqab7lgtzbx5e/drvmtk.zip?dl=0", "drivers/drvmtk.zip")
     trabajando()
     unzip("drivers\drvmtk.zip")
    If RunProgram("drivers\drvmtk.exe"):DeleteFile("drivers\drvmtk.zip"):EndIf
  Else
 MessageRequester("Error","No se pudo descargar el archivo")
EndIf
Else
  CloseFile(1):RunProgram("drivers\drvmtk.exe")
  findriv = 1
  EndIf 
  
  
Case 112; QCM
  SetWindowTitle(1,"Espere, por favor...")
  ;InitNetwork()
  If ReadFile(1,"drivers\driverq.exe")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/36o6etw4xuzg1sy/driverq.zip?dl=0", "drivers/driverq.zip")
       trabajando()
       unzip("drivers\driverq.zip")
If RunProgram("drivers\driverq.exe"):DeleteFile("drivers\driverq.zip"):EndIf
  Else
    MessageRequester("Error","No se pudo descargar el archivo")
  EndIf
  Else
    CloseFile(1):RunProgram("drivers\driverq.exe")
    findriv = 1
  EndIf 
  
Case 113
  SetWindowTitle(1,"Espere, por favor...")
    OpenConsole()
       ConsoleColor(2,0):ClearConsole()
      PrintN("Selecciona una opción:")
      PrintN("")
      PrintN("1 = Instalar Drivers USB SPD x64")
      PrintN("2 = Instalar Drivers USB SPD x86")
      PrintN("")
      PrintN("3 = SALIR"):PrintN(""):PrintN("")
      opcionconsola.s=Input()
      
      If opcionconsola="1"
     
        ShellExecute_(0, "RunAS", "drivers\Spreadtrum_USB_Driver\SPDx64\x64.bat", "", "", #SW_SHOWNORMAL)
        PrintN("Instalando drivers SPD x64 ..."):Delay(3000)
         CloseConsole()
      EndIf
      If opcionconsola="2"
   ShellExecute_(0, "RunAS", "drivers\Spreadtrum_USB_Driver\SPDx64\x64.bat", "", "", #SW_SHOWNORMAL)
        PrintN("Instalando drivers SPD x86 ..."):Delay(3000)
         CloseConsole()
     EndIf
            If opcionconsola="3"
        PrintN("Saliendo ...")
        Delay(1000):CloseConsole()
        findriv = 1
      EndIf    
      
    Case 114; ADB
      SetWindowTitle(1,"Espere, por favor...")
      ;InitNetwork()
      If ReadFile(1,"drivers\adb-driver.msi")=0
       If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/rpq2eo5z4bfvhmi/adb-driver.zip?dl=0", "drivers/adb-driver.zip")
         trabajando()
         unzip("drivers\adb-driver.zip")
         If RunProgram("drivers\adb.bat"):DeleteFile("drivers\adb-driver.zip"):EndIf
  Else
 MessageRequester("Error","No se pudo descargar el archivo")
  EndIf 
    Else
      CloseFile(1):RunProgram("drivers\adb.bat")
      findriv = 1
  EndIf
  
Case 115; SAMSUNG
  SetWindowTitle(1,"Espere, por favor...")
  ;InitNetwork()
  If ReadFile(1,"drivers\samsung.exe")=0
           If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/h0qgc94r91bkvkv/samsung.zip?dl=0", "drivers\samsung.zip")
             trabajando()
              unzip("drivers\samsung.zip")
If ShellExecute_(0, "RunAS", "drivers\samsung.exe", "", "", #SW_SHOWNORMAL):DeleteFile("drivers\samsung.zip"):EndIf
  Else
    MessageRequester("Error","No se pudo descargar el archivo")
  EndIf
      Else
        CloseFile(1):ShellExecute_(0, "RunAS", "drivers\samsung.exe", "", "", #SW_SHOWNORMAL)
        findriv = 1
  EndIf
  
    Case 116; LG
       SetWindowTitle(1,"Espere, por favor...")
       ;InitNetwork()
         If ReadFile(1,"drivers\lgdriver.exe")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/p1ky2uyyf3oeamh/lgdriver.zip?dl=0", "drivers/lgdriver.zip")
       trabajando()
       unzip("drivers\lgdriver.zip")
       If ShellExecute_(0, "RunAS", "drivers\lgdriver.exe", "", "", #SW_SHOWNORMAL):DeleteFile("drivers\lgdriver.zip"):EndIf
  Else
    MessageRequester("Error","No se pudo descargar el archivo")
  EndIf
        Else
          CloseFile(1):ShellExecute_(0, "RunAS", "drivers\lgdriver.exe", "", "", #SW_SHOWNORMAL)
          findriv = 1
  EndIf 

Case 117; MOTOROLA
  If Is64BitOS() = 1
    
     motopfile.s="f37duj2vkp6q8bj/motorola64.zip?dl=0":motofile.s="motorola64"
  Else
   motopfile.s="r4ugpnjxo8l9umi/motorola32.zip?dl=0":motofile.s="motorola32"
  EndIf
             SetWindowTitle(1,"Espere, por favor...")
             ;InitNetwork()
             If ReadFile(1,"drivers\"+motofile+".msi")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/"+motopfile, "drivers/"+motofile+".zip")
       trabajando()
       unzip("drivers\"+motofile+".zip")
       If RunProgram("drivers\"+motofile+".bat"):DeleteFile("drivers\"+motofile+".zip"):EndIf
  Else
    MessageRequester("Error","No se pudo descargar el archivo")
  EndIf
   Else
     CloseFile(1):RunProgram("drivers\"+motofile+".bat")
     findriv = 1
EndIf
   
    Case 119
      findriv = 1


EndSelect

EndSelect
Until findriv = 1 Or Event2 = #PB_Event_CloseWindow
EndIf
DisableGadget(14,0)
findriv = 0
CloseWindow(1):SetActiveWindow(0):Goto inicio

Case 15;--CHECK ROOT
DisableGadget(15,1)
  
o$=adb("adb shell su -v")
o$=adb("adb devices")

 If Len(o$)<29:AddGadgetItem(2, -1,"Dispositivo no conectado")
 Else
   o$=adb("adb shell su -v")
        For a = 1 To 101;+Random(250)
          SetGadgetColor(2,#PB_Gadget_BackColor,RGB(221, 79, 67)):SetGadgetColor(2,#PB_Gadget_FrontColor,RGB(0, 0, 0))
          Delay(a/4)

          AddGadgetItem(2, a, "Probando acceso root "+Str(a)+"% ...")   
         
        Next
        
        If FindString(o$,"not found") > 0
          AddGadgetItem(2, -1, "SIN ACCESO ROOT !")
          MessageRequester("NO ROOT","Superusuario no detectado",0)
         
        Else
          AddGadgetItem(2,-1, "ACCESO ROOT OK !")
          MessageRequester("ROOT OK !!","Superusuario detectado "+o$,0)
           ;Debug  o$
          AddGadgetItem(2, -1, o$)
         EndIf
         
        SetGadgetColor(2,#PB_Gadget_BackColor,RGB(0,0,0)):SetGadgetColor(2,#PB_Gadget_FrontColor,RGB(126, 178, 25))

      EndIf
     DisableGadget(15,0)    
      
    Case 151;--VER PANTALLA
      DisableGadget(151,1)
      o$=adb("adb devices")
      If FindString(o$,"unauthorized"):abra2():EndIf
      If Len(o$)>29
        o$=adb("adb kill-server"):AddGadgetItem(2, -1, o$)
        o$=adb("ptl\scrcpy"):AddGadgetItem(2, -1, o$)
        Else
      abra2()
EndIf
DisableGadget(151,0)

Case 16  ;--INSTALAR APPS
  DisableGadget(16,1)
  If OpenWindow(2, 348, 135, 243, 300, "Aplicaciones Root",  #PB_Window_TitleBar | #PB_Window_SystemMenu ) ;-- WINDOWS2 APPS
      ButtonImageGadget(120, 10, 30, 100, 40, Images(18))
      GadgetToolTip(120, "Explorador de archivos Root")
      
      ButtonImageGadget(121, 130, 30, 100, 40, Images(19))
      GadgetToolTip(121, "Herramientas BusyBox")
      
      ButtonImageGadget(122, 10, 90, 100, 40, Images(20))
      GadgetToolTip(122, "Aumenta la memoria")
      
      ButtonImageGadget(123, 130, 90, 100, 40, Images(21))
      GadgetToolTip(123, "Overclock y mucho más")
      
      ButtonImageGadget(124, 10, 150, 100, 40, Images(22))
      GadgetToolTip(124, "Elimina aplicaciones root")
      
      ButtonImageGadget(125, 130, 150, 100, 40, Images(23))
      GadgetToolTip(125, "App TWRP Recovery")
      
      ButtonGadget(126, 70, 260, 100, 20, "Cancelar")
      ButtonImageGadget(127, 10,200,100,40, images(25));IZD
      GadgetToolTip(127, "Instala la App Magisk Manager a tu teléfono")
      
       ButtonImageGadget(128, 130,200,100,40, images(26));IZD
       GadgetToolTip(128, "Borra la App Magisk Manager de tu teléfono")
       
       
  o$=adb("adb devices")
 If Len(o$)>29
     o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
     o$=Trim(ReplaceString(o$,"device","",1,1))
     device$=o$
     info.s=adb("adb devices -l")
     
     producto.s=StringField(info, 2, ":"):producto= ReplaceString(producto, "_"," "):producto=RemoveString(producto, "model")
     producto=Trim(producto)
     modelo.s=StringField(info, 3, ":"):modelo= ReplaceString(modelo, "_"," "):modelo=RemoveString(modelo, "device")
     modelo=Trim(modelo)

   adbon=1
Else
   adbon=0
EndIf
       

      Repeat
         
    Event3 = WaitWindowEvent()
Select Event3
  Case #PB_Event_Gadget
    Select EventGadget()
        
  Case 120
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"rootbrowser.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
  Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
  Case 121
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"busybox.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
     Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
  Case 122
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"ramexpander.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
     Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
  Case 123
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"devicecontrol.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
     Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
  Case 124
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"rootuninstaller.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
     Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
  Case 125
    If adbon =1
    MessageRequester("Información", "Se va a instalar una aplicación en tu dispositivo "+producto+" "+modelo+". Comprueba el escritorio de Android",0)
    SetWindowTitle(2,"Un momento...")
    SetActiveWindow(0)
    AddGadgetItem(2, -1, "Esperando...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"twrp.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","Aplicación instalada",0)
    finapp = 1
     Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
Case 126
  finapp=1

  Case 127 ;--INSTALAR MAGISK
    If adbon =1
      AddGadgetItem(2, -1, "Esperando...")
      o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"magisk.apk"+Chr(34))
      AddGadgetItem(2, -1, o$)
  If o$="":isap.s="OK":Else:isap="OK":EndIf
  
     If OpenWindow(3, 348, 135, 300, 100, "",  #PB_Window_SystemMenu | #PB_Window_TitleBar )
      TextGadget(33,  10, 10, 250,  20, "Trabajando en ello ...", #PB_Text_Center)
      ProgressBarGadget(34,  10, 40, 275,  30, 0, 100)
      HideWindow(0, #True)
   Repeat
         Event3 = WaitWindowEvent()
Select Event3
  Case #PB_Event_Gadget
    Select EventGadget()
        
  Case 120
 EndSelect

EndSelect
For a=0 To 100
SetWindowTitle(3, Str(a)):SetGadgetState(34, a):Delay(10)
  Delay(10):Next
Until a > 99 Or Event3 = #PB_Event_CloseWindow
HideWindow(0, #False):CloseWindow(3):a-a
EndIf
adb("adb shell monkey -p com.topjohnwu.magisk -c android.intent.category.LAUNCHER 1")
MessageRequester("","Aplicación instalada",0)
finapp = 1
      Else
    MessageRequester("Error","No dispositivo")
  EndIf
  
   Case 128 ;--ELIMINAR MAGISK
     If adbon =1
       AddGadgetItem(2, -1, "Esperando...")
  o$=adb("adb uninstall com.topjohnwu.magisk")
If o$="":isap.s="OK":EndIf
MessageRequester("","Aplicación desinstalada",0)
finapp = 1
 Else
    MessageRequester("Error","No dispositivo")
EndIf
 EndSelect
 
EndSelect
Until finapp = 1 Or Event3 = #PB_Event_CloseWindow
finapp=0
EndIf

CloseWindow(2):SetActiveWindow(0);:Goto inicio
DisableGadget(16,0)

Case 18 ;-- CHEK BOOTLOAER=================
  DisableGadget(18,1)
  o$=adb("fastboot getvar unlocked")
  If FindString(o$,"yes",1)
     
    AddGadgetItem(2, -1, "Enhorabuena !")
    AddGadgetItem(2, -1, "")
    AddGadgetItem(2, -1, "El bootloader se encuentra DESBLOQUEADO")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, o$)
   Else
     AddGadgetItem(2, -1, "Vaya !")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "El bootloader se encuentra BLOQUEADO")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
  AddGadgetItem(2, -1, o$)
EndIf
DisableGadget(18,0)

Case 20  ;-===== OPCIÓN ROOT
 If ReadFile(0,rai$+"root\"+"root.img"):rsi=1:si=rsi:CloseFile(0):Else:rsi=0
 EndIf
 o$=adb("fastboot devices")
 If Len(o$)>10
 o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
 device$=o$
 fastbooton=1
Else
  SetGadgetText(2,""):Delay(200)
  AddGadgetItem(2, -1, "Fastboot desconectado. Pulsa Ir Fastboot")
  fastbooton=0
EndIf

  SetGadgetText(2,""):Delay(200)
        If rsi=1    
  SetGadgetText(1,"ROOT")
  AddGadgetItem(2, -1, "> Root cargado-> "+rai$+"root\"+"root.img")
  If si=1 And fastbooton=1
    DisableGadget(1,0)
  EndIf
Else
  SetGadgetText(2,"")
  If rsi<>1:AddGadgetItem(2, -1, "Error 380 > Debes procesar el archivo BOOT (root.img no se ha creado)."):EndIf
  AddGadgetItem(2, -1, "> Root no disponible.")
  AddGadgetItem(2, -1, "")
    If fastbooton<>1:AddGadgetItem(2, -1, "Error 720 > Dispositivo debe estar en modo Fastboot-")
    AddGadgetItem(2, -1, "Pulsa Ir a Fastboot espera 5 segundos y pulsa Test Fastboot")
  EndIf
 
      Goto inicio
      EndIf


    Case 21   ;-====== OPCIÓN UNROOT
      If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1:si=psi:CloseFile(0):Else:psi=0
        
 EndIf
 o$=adb("fastboot devices")
 If Len(o$)>10
 o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
 device$=o$
 fastbooton=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Fastboot desconectado. Pulsa Ir Fastboot")
  fastbooton=0
EndIf   
      SetGadgetText(2,""):Delay(200)
      If psi=1 
  SetGadgetText(1,"UNROOT")
  AddGadgetItem(2, -1, "> Stock Boot Cargado->"+rai$+"unroot\"+"unroot.img")
  If si=1 And fastbooton=1
  DisableGadget(1,0):EndIf
Else
  SetGadgetText(2,"")
  If psi<>1:AddGadgetItem(2, -1, "Error 381 > Debes procesar el archivo BOOT (unroot.img no se ha creado)")
    AddGadgetItem(2, -1, "> Puedes colocarlo manualmente renombrando boot.img original")
    AddGadgetItem(2, -1, "como unroot.img y copiándolo a la carpeta DATA\unroot")
  EndIf
    AddGadgetItem(2, -1, "")
If fastbooton<>1:AddGadgetItem(2, -1, "Error 720 > Dispositivo debe estar en modo Fastboot-")
    AddGadgetItem(2, -1, "Pulsa Ir a Fastboot espera 5 segundos y pulsa Test Fastboot")
  EndIf
      Goto inicio
    EndIf
    
  Case 22
    If ReadFile(10,rai$+"root\root.img")
      boodin$ = SaveFileRequester("Guardar en", "boot", "img (*.img)|*.img", 0)
      CloseFile(10):EndIf
    If CopyFile(rai$+"root\root.img", boodin$+".img")
      MessageRequester("OK","",9)
      Else: MessageRequester("ERROR", "No existe archivo procesado",0):EndIf
    
 
   EndSelect
        
EndSelect
If si=1 And GetGadgetState(20)=1 And GetGadgetState(21)=1
DisableGadget(1,0):EndIf

Until Event = #PB_Event_CloseWindow
adb("adb kill-server")
EndIf
