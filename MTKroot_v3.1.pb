Enumeration
  #Window_0
  #Window_1
  #Window_2
  #Window_3
EndEnumeration

UseZipPacker()

Structure Entry
  type.i
  Name.s
EndStructure

Global NewList Content.Entry()

Global TempFolder.s,ZipFile.s, bootpart.s
Global btnUnZip.i,btnAdd.i,btnZip.i,PackID.i

IncludeFile("procedures.pb")
IncludeFile("blowareprocedures.pb")

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
    Image29:
    IncludeBinary "logos\cleaner.jpg"
        Image30:
  IncludeBinary "logos\salir.png"
EndDataSection

; --- Uso ---
LoadImages()  ; Cargar al inicio del programa


IncludeFile("help\help.pb")

; --- Ventana(504x660) ---
If OpenWindow(#Window_0, 0, 0, 504, 660, "MTKroot v3.1 (2025)", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget)
  version.s = "3.1"
  

If CreateImageMenu(0, WindowID(#Window_0), #PB_Menu_ModernLook)
    MenuTitle("File")
    MenuItem(50, "Load", Images(1))  ; Changed to Image1 (without ImageID)
EndIf
  
  ;-===== LEFT SECTION (Main actions) =====
  FrameGadget(100, 10, 10, 200, 280, "Root Tools")
  ButtonGadget(0, 20, 40, 180, 30, "Process Patch") 
  GadgetToolTip(0, "Transfers the boot file for patching")   
  ButtonGadget(16, 20, 80, 180, 30, "Apps")
  GadgetToolTip(16, "Application repository") 
   ButtonGadget(14,20,200,180,30,"Drivers")
   ButtonImageGadget(1444,20,240,180,30,Images(29))
   GadgetToolTip(1444, "Clean Bloatware, Adware, Spyware etc.") 
 GadgetToolTip(14, "List of USB/Vcom drivers to install") 
  ButtonGadget(15, 20, 120, 180, 30, "Check Root")
  GadgetToolTip(15, "Checks root status")
  ButtonGadget(8, 20, 160, 180, 30, "Unlock Bootloader")
  GadgetToolTip(8, "Attempts to unlock bootloader") 

  ;-===== CENTER SECTION (Status/Image) =====
  ImageGadget(1111, 220, 40, 131, 103, Images(0))  ; Center image
  
  ;--- Root/Unroot Options ---
  FrameGadget(101, 220, 160, 131, 80, "Mode")
  OptionGadget(20, 230, 190, 60, 20, "Root")
  OptionGadget(21, 230, 220, 80, 20, "Unroot")
  SetGadgetState(20, #True)

  ;-===== RIGHT SECTION (ADB/Fastboot) =====
  FrameGadget(102, 360, 10, 130, 250, "Connection")
  ButtonGadget(3, 370, 40, 110, 30, "Test ADB")
  GadgetToolTip(3, "Verifies ADB connection") 
  ButtonGadget(4, 370, 80, 110, 30, "Test Fastboot")
  GadgetToolTip(4, "Verifies Fastboot connection") 
  ButtonGadget(5, 370, 120, 110, 30, "Enter Fastboot")
  GadgetToolTip(5, "Reboots into Fastboot mode") 
  ButtonGadget(6, 370, 160, 110, 30, "Exit Fastboot")
  GadgetToolTip(6, "Reboots into normal mode") 
  ButtonGadget(7, 370, 200, 110, 30, "Reboot Device")
  
  ; ===== BOTTOM SECTION (Console/Extra buttons) =====
  EditorGadget(2, 10, 300, 484, 250, #PB_Editor_ReadOnly)
  SetGadgetColor(2, #PB_Gadget_BackColor, RGB(0, 0, 0))
  SetGadgetColor(2, #PB_Gadget_FrontColor, RGB(126, 178, 25))
  
  ; --- Bottom buttons ---
  ButtonGadget(151, 10, 560, 120, 30, "Screen Control")
  GadgetToolTip(151, "Remote device control") 
  ButtonGadget(18, 140, 560, 120, 30, "Test Bootloader")
  GadgetToolTip(18, "Verifies bootloader status") 
  ButtonGadget(1, 270, 560, 120, 30, "Root/Unroot")
  GadgetToolTip(1, "Executes selected action") 
  ButtonImageGadget(131, 400, 560, 40, 30, Images(27))  ; Console icon
  GadgetToolTip(131, "Open ADB console") 
  ButtonImageGadget(250, 450, 560, 40, 30, Images(28))  ; Update icon
  GadgetToolTip(250, "Check for updates") 

  ; --- Event loop ---


 DisableGadget(1,1)
 DisableGadget(8,1)
 DisableGadget(6,1)
 DisableGadget(0,1)
 DisableGadget(18,1)
 
 inicio:
 
If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1
  source$=rai$+"unroot\"+"unroot.img"
  si=1:SetMenuTitleText(0,0,"Boot loaded")
  SetMenuItemText(0, 50, "Eject")
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
          
        Case 50 ;--load----file
          
          If GetMenuItemText(0, 50)="Eject";;;;;1
            sino=MessageRequester("WARNING !","This will delete root.img and unroot.img patches",#PB_MessageRequester_YesNo)
            If sino=#PB_MessageRequester_Yes
   source$=""
   si=0:rsi=0:psi=0
   DeleteFile(rai$+"unroot\"+"unroot.img")
   DeleteFile(rai$+"root\"+"root.img")
   SetMenuTitleText(0,0,"No boot loaded !!")
   SetMenuItemText(0, 50, "Load")
   DisableGadget(1,1)
   EndIf
 Else
   
 rai$=GetCurrentDirectory()

If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1
 source$=rai$+"unroot\"+"unroot.img":CloseFile(0)
Else
 source$=OpenFileRequester("Select file to process", "boot.img", "img (*.img)|*.img", 0)
EndIf

file$=GetFilePart(source$)

If ReadFile(1,source$)=0 And psi =0:si=0
  MessageRequester("Error","No file selected",0)
Else
  si=1:SetMenuTitleText(0,0,"Boot loaded")
  SetMenuItemText(0, 50, "Eject")
  AddGadgetItem(2,-1,file$)
  DisableGadget(0,0)
   CloseFile(1)
EndIf

EndIf ;;;;;;1

   EndSelect
    
Case #PB_Event_Gadget
  Select EventGadget()
      
    Case 0 ;--process---file
      DisableGadget(0,1)
      
      If ReadFile(6,rai$+"unroot\"+"unroot.img")
        sino=MessageRequester("WARNING!","A processed file already exists. Overwrite?",#PB_MessageRequester_YesNo)
        If sino=#PB_MessageRequester_Yes
          DeleteFile(rai$+"unroot\"+"unroot.img")
          DeleteFile(rai$+"root\"+"root.img")
          EndIf:CloseFile(6):EndIf
      If CopyFile(source$,rai$+"unroot\"+"unroot.img") = 1:procesoa=1:EndIf
      ;Debug procesoa
      
 AddGadgetItem(2, -1, "Copied ==> "+file$)

o$=adb("adb push "+Chr(34)+rai$+"unroot\"+"unroot.img"+Chr(34)+" /sdcard/")
AddGadgetItem(2, -1, "Transferring > "+o$)
o$=adb("aprm /sdcard/Download/magisk_patched*.img")
   
iPause.i = 10
iLine.i = 1
iTotal.i = CountGadgetItems(2)
While (iLine < iTotal)
                Delay(iPause)
         SendMessage_(GadgetID(2),#EM_LINESCROLL,0,1)
         iLine = iLine + 1
       Wend
       AddGadgetItem(2, -1, "Opening Magisk Manager App ")
    
       adb("adb shell monkey -p com.topjohnwu.magisk -c android.intent.category.LAUNCHER 1")

       If procesoa=1:AddGadgetItem(2, -1, "File processed successfully > "):EndIf
       
       
       abra()


     
       o$=adb("apll /sdcard/Download/magisk_patched*.img")
       AddGadgetItem(2, -1, " Method > 1 ")
       If FindString(o$,"remote object")
         o$=adb("apll2 /storage/emulated/0/Download/magisk_patched*.img")
         AddGadgetItem(2, -1, " Method > 2 ")
      EndIf
       AddGadgetItem(2, -1, "Transferring > "+o$)
   
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

       
       
   If OpenWindow(#Window_3, 348, 135, 300, 100, "",  #PB_Window_TitleBar )
      TextGadget(33,  10, 10, 250,  20, "Working on it...", #PB_Text_Center)
      ProgressBarGadget(34,  10, 40, 275,  30, 0, 100)
      HideWindow(#Window_0, #True)
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
       
MessageRequester("Done","Process completed!")

DisableGadget(0,0)
     
     Case 1;--Root/Unroot-----------------------   
       
  SetGadgetText(2,"")
  
  If GetGadgetState(20) <>0
    AddGadgetItem(2, -1, "ROOT selected")
    
    o$=adb("fastboot getvar current-slot")
    AddGadgetItem(2, -1, o$)
    bootpart="boot"
    If FindString(o$,"current-slot: a"):bootpart="boot_a":EndIf
    If FindString(o$,"current-slot: b"):bootpart="boot_b":EndIf
    
    resroot=MessageRequester("","Launch temporary root?", #PB_MessageRequester_Info | #PB_MessageRequester_YesNo)
    If resroot = #PB_MessageRequester_Yes
      o$=adb("fastboot "+bootpart+" "+Chr(34)+rai$+"root\"+"root.img"+Chr(34))
      Else
      o$=adb("fastboot flash "+bootpart+" "+Chr(34)+rai$+"root\"+"root.img"+Chr(34))
    EndIf
       
 AddGadgetItem(2, 1, "==OK==")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, "> Press Exit Fastboot.")

ElseIf GetGadgetState(21)<>0
   AddGadgetItem(2, -1, "UNROOT selected ")
   o$=adb("fastboot flash boot "+Chr(34)+rai$+"unroot\"+"unroot.img"+Chr(34))
   AddGadgetItem(2, 1, "==OK==")
   AddGadgetItem(2, -1, o$)
   AddGadgetItem(2, -1, "> Press Exit Fastboot.")
EndIf

 
 
Case 3 ;--TEST ADB---------------------------
  DisableGadget(3,1)
  SetGadgetText(2,"")
  o$=adb("adb devices")
  o$=adb("cls")
  o$=adb("adb devices")
  If FindString(o$,"unauthorized"):abra2():EndIf
   ;Debug Len(o$)
   ;Debug ""
   ;Debug o$
  If Len(o$)>29
     o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
     o$=Trim(ReplaceString(o$,"device","",1,1))
     device$=o$
     info.s=adb("adb devices -l")
     
     product.s=StringField(info, 2, ":"):product= ReplaceString(product, "_"," "):product=RemoveString(product, "model")
     product=Trim(product)
     model.s=StringField(info, 3, ":"):model= ReplaceString(model, "_"," "):model=RemoveString(model, "device")
     model=Trim(model)
If model = product:model="":EndIf
device.s=StringField(info, 4, ":"):device= ReplaceString(device, "_"," ")
device=Trim(device)
If device = product:device="":EndIf
     
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, "Device detected")
 AddGadgetItem(2, -1, "")
 AddGadgetItem(2, -1, product+" "+model)
 adbon=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Device disconnected")
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
 AddGadgetItem(2, -1, "Device detected")
 DisableGadget(8,0)
 DisableGadget(6,0)
 DisableGadget(18,0)
 fastbooton=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Fastboot disconnected. Press Enter Fastboot")
  fastbooton=0
EndIf
DisableGadget(4,0)

Case 5 ;--ENTER FASTBOOT
  DisableGadget(5,1)
  AddGadgetItem(2, -1, "Rebooting to Fastboot...")
  SetGadgetText(2,"")
  o$=adb("adb reboot bootloader")
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 DisableGadget(5,0)
 
 
Case 6 ;--EXIT FASTBOOT
  DisableGadget(6,1)
  cmd$="fastboot reboot"
  o$=adb(cmd$)
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" Exiting Fastboot")
 DisableGadget(6,0)
 
Case 7;--REBOOT===============
  DisableGadget(7,1)
  cmd$="adb reboot"
  o$=adb(cmd$)
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" Exiting ADB")
 DisableGadget(7,0)
 
Case 8;--UNLOCK BOOTLOADER==========================
  DisableGadget(8,1)
    MessageRequester("Warning","Device will be reset",0)
  o$=adb("fastboot flashing unlock")
  o$=adb("fastboot oem unlock")
  o$=adb("fastboot oem unlock-go")
 SetGadgetText(2,"")
 AddGadgetItem(2, -1, o$)
 AddGadgetItem(2, -1, device$+" unlocking Bootloader")
 AddGadgetItem(2, -1, "Confirm operation from")
 AddGadgetItem(2, -1, "device screen")
 DisableGadget(8,0)
 
Case 9;--RESTART USB
  DisableGadget(9,1)
  o$=adb("adb usb")
  AddGadgetItem(2, -1, o$)
  DisableGadget(9,0)
  
Case 131
  DisableGadget(131,1)
  RunProgram("cmd")
       DisableGadget(131,0)
       
      ;--BLOWARE 
     Case 1444
      IncludeFile("bloware.pb")
       Goto inicio
     Case 14 ;--install drivers
       DisableGadget(14,1)
       
       If OpenWindow(#Window_1, 353, 198, 247, 310, "Install Drivers", #PB_Window_TitleBar | #PB_Window_SystemMenu )
         SetActiveWindow(#Window_1)
   
      ButtonImageGadget(111, 20, 30, 80, 30, Images(10))
      ButtonImageGadget(112, 20, 100, 80, 30, Images(11))
      ButtonImageGadget(113, 20, 160, 80, 30, Images(12))
      ButtonImageGadget(114, 150, 220, 80, 30, Images(13))
      ButtonImageGadget(115, 150, 30, 80, 30, Images(14))
      ButtonImageGadget(116, 150, 100, 80, 30, Images(15))
      ButtonImageGadget(117, 150, 160, 80, 30, Images(16))
      ButtonImageGadget(118, 20, 220, 80, 30, Images(17))
      ButtonGadget(119, 90, 275, 90, 20, "Cancel")

        Repeat
    Event2 = WaitWindowEvent()
Select Event2
  Case #PB_Event_Gadget
    Select EventGadget()
          
      Case 111; MTK
        SetWindowTitle(1,"Please wait...")
        ;InitNetwork()
        If ReadFile(1,"drivers\drvmtk.exe")=0
          If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/0tlqab7lgtzbx5e/drvmtk.zip?dl=0", "drivers/drvmtk.zip")
     trabajando()
     unzip("drivers\drvmtk.zip")
    If RunProgram("drivers\drvmtk.exe"):DeleteFile("drivers\drvmtk.zip"):EndIf
  Else
 MessageRequester("Error","Could not download file")
EndIf
Else
  CloseFile(1):RunProgram("drivers\drvmtk.exe")
  findriv = 1
  EndIf 
  
  
Case 112; QCM
  SetWindowTitle(1,"Please wait...")
  ;InitNetwork()
  If ReadFile(1,"drivers\driverq.exe")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/36o6etw4xuzg1sy/driverq.zip?dl=0", "drivers/driverq.zip")
       trabajando()
       unzip("drivers\driverq.zip")
If RunProgram("drivers\driverq.exe"):DeleteFile("drivers\driverq.zip"):EndIf
  Else
    MessageRequester("Error","Could not download file")
  EndIf
  Else
    CloseFile(1):RunProgram("drivers\driverq.exe")
    findriv = 1
  EndIf 
  
Case 113
  SetWindowTitle(1,"Please wait...")
    OpenConsole()
       ConsoleColor(2,0):ClearConsole()
      PrintN("Select an option:")
      PrintN("")
      PrintN("1 = Install SPD USB Drivers x64")
      PrintN("2 = Install SPD USB Drivers x86")
      PrintN("")
      PrintN("3 = EXIT"):PrintN(""):PrintN("")
      consoleoption.s=Input()
      
      If consoleoption="1"
     
        ShellExecute_(0, "RunAs", "drivers\Spreadtrum_USB_Driver\SPDx64\x64.bat", "", "", #SW_SHOWNORMAL)
        PrintN("Installing SPD x64 drivers..."):Delay(3000)
         CloseConsole()
      EndIf
      If consoleoption="2"
   ShellExecute_(0, "RunAs", "drivers\Spreadtrum_USB_Driver\SPDx64\x64.bat", "", "", #SW_SHOWNORMAL)
        PrintN("Installing SPD x86 drivers..."):Delay(3000)
         CloseConsole()
     EndIf
            If consoleoption="3"
        PrintN("Exiting...")
        Delay(1000):CloseConsole()
        findriv = 1
      EndIf    
      
    Case 114; ADB
      SetWindowTitle(1,"Please wait...")
      ;InitNetwork()
      If ReadFile(1,"drivers\adb-driver.msi")=0
       If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/rpq2eo5z4bfvhmi/adb-driver.zip?dl=0", "drivers/adb-driver.zip")
         trabajando()
         unzip("drivers\adb-driver.zip")
         If RunProgram("drivers\adb.bat"):DeleteFile("drivers\adb-driver.zip"):EndIf
  Else
 MessageRequester("Error","Could not download file")
  EndIf 
    Else
      CloseFile(1):RunProgram("drivers\adb.bat")
      findriv = 1
  EndIf
  
Case 115; SAMSUNG
  SetWindowTitle(1,"Please wait...")
  ;InitNetwork()
  If ReadFile(1,"drivers\samsung.exe")=0
           If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/h0qgc94r91bkvkv/samsung.zip?dl=0", "drivers\samsung.zip")
             trabajando()
              unzip("drivers\samsung.zip")
If ShellExecute_(0, "RunAs", "drivers\samsung.exe", "", "", #SW_SHOWNORMAL):DeleteFile("drivers\samsung.zip"):EndIf
  Else
    MessageRequester("Error","Could not download file")
  EndIf
      Else
        CloseFile(1):ShellExecute_(0, "RunAs", "drivers\samsung.exe", "", "", #SW_SHOWNORMAL)
        findriv = 1
  EndIf
  
    Case 116; LG
       SetWindowTitle(1,"Please wait...")
       ;InitNetwork()
         If ReadFile(1,"drivers\lgdriver.exe")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/p1ky2uyyf3oeamh/lgdriver.zip?dl=0", "drivers/lgdriver.zip")
       trabajando()
       unzip("drivers\lgdriver.zip")
       If ShellExecute_(0, "RunAs", "drivers\lgdriver.exe", "", "", #SW_SHOWNORMAL):DeleteFile("drivers\lgdriver.zip"):EndIf
  Else
    MessageRequester("Error","Could not download file")
  EndIf
        Else
          CloseFile(1):ShellExecute_(0, "RunAs", "drivers\lgdriver.exe", "", "", #SW_SHOWNORMAL)
          findriv = 1
  EndIf 

Case 117; MOTOROLA
  If Is64BitOS() = 1
    
     motopfile.s="f37duj2vkp6q8bj/motorola64.zip?dl=0":motofile.s="motorola64"
  Else
   motopfile.s="r4ugpnjxo8l9umi/motorola32.zip?dl=0":motofile.s="motorola32"
  EndIf
             SetWindowTitle(1,"Please wait...")
             ;InitNetwork()
             If ReadFile(1,"drivers\"+motofile+".msi")=0
     If ReceiveHTTPFile("https://dl.dropboxusercontent.com/s/"+motopfile, "drivers/"+motofile+".zip")
       trabajando()
       unzip("drivers\"+motofile+".zip")
       If RunProgram("drivers\"+motofile+".bat"):DeleteFile("drivers\"+motofile+".zip"):EndIf
  Else
    MessageRequester("Error","Could not download file")
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

 If Len(o$)<29:AddGadgetItem(2, -1,"Device not connected")
 Else
   o$=adb("adb shell su -v")
        For a = 1 To 101;+Random(250)
          SetGadgetColor(2,#PB_Gadget_BackColor,RGB(221, 79, 67)):SetGadgetColor(2,#PB_Gadget_FrontColor,RGB(0, 0, 0))
          Delay(a/4)

          AddGadgetItem(2, a, "Testing root access "+Str(a)+"%...")   
         
        Next
        
        If FindString(o$,"not found") > 0
          AddGadgetItem(2, -1, "NO ROOT ACCESS!")
          MessageRequester("NO ROOT","Superuser not detected",0)
         
        Else
          AddGadgetItem(2,-1, "ROOT ACCESS OK!")
          MessageRequester("ROOT OK !!","Superuser detected "+o$,0)
           ;Debug  o$
          AddGadgetItem(2, -1, o$)
         EndIf
         
        SetGadgetColor(2,#PB_Gadget_BackColor,RGB(0,0,0)):SetGadgetColor(2,#PB_Gadget_FrontColor,RGB(126, 178, 25))

      EndIf
     DisableGadget(15,0)    
      
   Case 151;--VIEW SCREEN
     AddGadgetItem(2, -1, "> Loading...")
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

Case 16  ;--INSTALL APPS
  DisableGadget(16,1)
  If OpenWindow(#Window_2, 348, 135, 243, 300, "Root Applications",  #PB_Window_TitleBar | #PB_Window_SystemMenu ) ;-- WINDOWS2 APPS
      ButtonImageGadget(120, 10, 30, 100, 40, Images(18))
      GadgetToolTip(120, "Root file explorer")
      
      ButtonImageGadget(121, 130, 30, 100, 40, Images(19))
      GadgetToolTip(121, "BusyBox tools")
      
      ButtonImageGadget(122, 10, 90, 100, 40, Images(20))
      GadgetToolTip(122, "Increase memory")
      
      ButtonImageGadget(123, 130, 90, 100, 40, Images(21))
      GadgetToolTip(123, "Overclock and more")
      
      ButtonImageGadget(124, 10, 150, 100, 40, Images(22))
      GadgetToolTip(124, "Remove root apps")
      
      ButtonImageGadget(125, 130, 150, 100, 40, Images(23))
      GadgetToolTip(125, "TWRP Recovery App")
      
      ButtonGadget(126, 70, 260, 100, 20, "Cancel")
      ButtonImageGadget(127, 10,200,100,40, images(25))
      GadgetToolTip(127, "Install Magisk Manager App to your phone")
      
       ButtonImageGadget(128, 130,200,100,40, images(26))
       GadgetToolTip(128, "Remove Magisk Manager App from your phone")
       
       
  o$=adb("adb devices")
 If Len(o$)>29
     o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
     o$=Trim(ReplaceString(o$,"device","",1,1))
     device$=o$
     info.s=adb("adb devices -l")
     
     product.s=StringField(info, 2, ":"):product= ReplaceString(product, "_"," "):product=RemoveString(product, "model")
     product=Trim(product)
     model.s=StringField(info, 3, ":"):model= ReplaceString(model, "_"," "):model=RemoveString(model, "device")
     model=Trim(model)

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
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"rootbrowser.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
  Else
    MessageRequester("Error","No device")
  EndIf
  
  Case 121
    If adbon =1
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"busybox.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
     Else
    MessageRequester("Error","No device")
  EndIf
  
  Case 122
    If adbon =1
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"ramexpander.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
     Else
    MessageRequester("Error","No device")
  EndIf
  
  Case 123
    If adbon =1
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"devicecontrol.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
     Else
    MessageRequester("Error","No device")
  EndIf
  
  Case 124
    If adbon =1
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"rootuninstaller.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
     Else
    MessageRequester("Error","No device")
  EndIf
  
  Case 125
    If adbon =1
    MessageRequester("Information", "An app will be installed on your device "+product+" "+model+". Check Android desktop",0)
    SetWindowTitle(#Window_2,"One moment...")
    SetActiveWindow(#Window_0)
    AddGadgetItem(2, -1, "Waiting...")
    o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"twrp.apk"+Chr(34))
    AddGadgetItem(2, -1, o$)
    If o$="":isap.s="OK":EndIf
    MessageRequester("","App installed",0)
    finapp = 1
     Else
    MessageRequester("Error","No device")
  EndIf
  
Case 126
  finapp=1

  Case 127 ;--INSTALL MAGISK
    If adbon =1
      AddGadgetItem(2, -1, "Waiting...")
      o$=adb("adb install -t "+Chr(34)+rai$+"app\"+"magisk.apk"+Chr(34))
      AddGadgetItem(2, -1, o$)
  If o$="":isap.s="OK":Else:isap="OK":EndIf
  
     If OpenWindow(#Window_3, 348, 135, 300, 100, "",  #PB_Window_SystemMenu | #PB_Window_TitleBar )
      TextGadget(33,  10, 10, 250,  20, "Working on it...", #PB_Text_Center)
      ProgressBarGadget(34,  10, 40, 275,  30, 0, 100)
      HideWindow(#Window_0, #True)
   Repeat
         Event3 = WaitWindowEvent()
Select Event3
  Case #PB_Event_Gadget
    Select EventGadget()
        
  Case 120
 EndSelect

EndSelect
For a=0 To 100
SetWindowTitle(#Window_3, Str(a)):SetGadgetState(34, a):Delay(10)
  Delay(10):Next
Until a > 99 Or Event3 = #PB_Event_CloseWindow
HideWindow(#Window_0, #False):CloseWindow(#Window_3):a-a
EndIf
adb("adb shell monkey -p com.topjohnwu.magisk -c android.intent.category.LAUNCHER 1")
MessageRequester("","App installed",0)
finapp = 1
      Else
    MessageRequester("Error","No device")
  EndIf
  
   Case 128 ;--REMOVE MAGISK
     If adbon =1
       AddGadgetItem(2, -1, "Waiting...")
  o$=adb("adb uninstall com.topjohnwu.magisk")
If o$="":isap.s="OK":EndIf
MessageRequester("","App uninstalled",0)
finapp = 1
 Else
    MessageRequester("Error","No device")
EndIf
 EndSelect
 
EndSelect
Until finapp = 1 Or Event3 = #PB_Event_CloseWindow
finapp=0
EndIf

CloseWindow(#Window_2):SetActiveWindow(#Window_0);:Goto start
DisableGadget(16,0)

Case 18 ;-- CHECK BOOTLOADER=================
  DisableGadget(18,1)
  o$=adb("fastboot getvar unlocked")
  If FindString(o$,"yes",1)
     
    AddGadgetItem(2, -1, "Congratulations!")
    AddGadgetItem(2, -1, "")
    AddGadgetItem(2, -1, "Bootloader is UNLOCKED")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, o$)
   Else
     AddGadgetItem(2, -1, "Oops!")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "Bootloader is LOCKED")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
     AddGadgetItem(2, -1, "")
  AddGadgetItem(2, -1, o$)
EndIf
DisableGadget(18,0)

Case 20  ;-===== ROOT OPTION
 If ReadFile(0,rai$+"root\"+"root.img"):rsi=1:si=rsi:CloseFile(0):Else:rsi=0
 EndIf
 o$=adb("fastboot devices")
 If Len(o$)>10
 o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
 device$=o$
 fastbooton=1
Else
  SetGadgetText(2,""):Delay(200)
  AddGadgetItem(2, -1, "Fastboot disconnected. Press Enter Fastboot")
  fastbooton=0
EndIf

  SetGadgetText(2,""):Delay(200)
        If rsi=1    
  SetGadgetText(1,"ROOT")
  AddGadgetItem(2, -1, "> Root loaded-> "+rai$+"root\"+"root.img")
  If si=1 And fastbooton=1
    DisableGadget(1,0)
  EndIf
Else
  SetGadgetText(2,"")
  If rsi<>1:AddGadgetItem(2, -1, "Error 380 > You must process the BOOT file (root.img was not created)."):EndIf
  AddGadgetItem(2, -1, "> Root not available.")
  AddGadgetItem(2, -1, "")
    If fastbooton<>1:AddGadgetItem(2, -1, "Error 720 > Device must be in Fastboot mode-")
    AddGadgetItem(2, -1, "Press Enter Fastboot wait 5 seconds and press Test Fastboot")
  EndIf
 
      Goto inicio
      EndIf


    Case 21   ;-====== UNROOT OPTION
      If ReadFile(0,rai$+"unroot\"+"unroot.img"):psi=1:si=psi:CloseFile(0):Else:psi=0
        
 EndIf
 o$=adb("fastboot devices")
 If Len(o$)>10
 o$=Trim(ReplaceString(o$,"List of devices attached","",1,1))
 device$=o$
 fastbooton=1
Else
  SetGadgetText(2,"")
  AddGadgetItem(2, -1, "Fastboot disconnected. Press Enter Fastboot")
  fastbooton=0
EndIf   
      SetGadgetText(2,""):Delay(200)
      If psi=1 
  SetGadgetText(1,"UNROOT")
  AddGadgetItem(2, -1, "> Stock Boot Loaded->"+rai$+"unroot\"+"unroot.img")
  If si=1 And fastbooton=1
  DisableGadget(1,0):EndIf
Else
  SetGadgetText(2,"")
  If psi<>1:AddGadgetItem(2, -1, "Error 381 > You must process the BOOT file (unroot.img was not created)")
    AddGadgetItem(2, -1, "> If you prefer you can manually place it by renaming original boot.img")
    AddGadgetItem(2, -1, "as unroot.img and copying it to DATA\unroot folder")
  EndIf
    AddGadgetItem(2, -1, "")
If fastbooton<>1:AddGadgetItem(2, -1, "Error 720 > Device must be in Fastboot mode-")
    AddGadgetItem(2, -1, "Press Enter Fastboot wait 5 seconds and press Test Fastboot")
  EndIf
      Goto inicio
    EndIf
    
  Case 22
    If ReadFile(10,rai$+"root\root.img")
      boodin$ = SaveFileRequester("Save as", "boot", "img (*.img)|*.img", 0)
      CloseFile(10):EndIf
    If CopyFile(rai$+"root\root.img", boodin$+".img")
      MessageRequester("OK","",9)
      Else: MessageRequester("ERROR", "No processed file exists",0):EndIf
    
 
   EndSelect
        
EndSelect
If si=1 And GetGadgetState(20)=1 And GetGadgetState(21)=1
DisableGadget(1,0):EndIf

Until Event = #PB_Event_CloseWindow
adb("adb kill-server")
EndIf
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 99
; FirstLine = 93
; EnableXP
; UseIcon = logos\logo.ico
; Executable = MTKroot3.1.exe