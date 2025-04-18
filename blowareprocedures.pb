;-- 1. Enumeration de constantes
Enumeration
  #Window_Main = 164
  #List_Packages
  #Text_Description
  #Button_Delete = 2320
  #Button_Disable = 2321
  #Button_RefreshList = 2322
  #Button_SaveReport = 2323
  #StatusBar = 2324
  #ProgressBar = 2325
  #Checkbox_SystemApps = 2326
  #Text_Search = 2327
  #Input_Search = 2328
  #Button_Search = 2329
  #Button_Salir = 2330
EndEnumeration

;-- 2. Constantes para API de Windows (ListView)
#LVM_FIRST = $1000
#LVM_SCROLL = (#LVM_FIRST + 20)
#LVM_GETITEMCOUNT = (#LVM_FIRST + 4)
#LVM_GETITEMPOSITION = (#LVM_FIRST + 16)
#LVM_GETITEMRECT = (#LVM_FIRST + 14)
#LVM_GETTOPINDEX = (#LVM_FIRST + 39)
#LVM_GETCOUNTPERPAGE = (#LVM_FIRST + 40)
#WM_VSCROLL = $0115
#SB_LINEUP = 0
#SB_LINEDOWN = 1
#LB_GETITEMHEIGHT = $01A1
#LB_SETTOPINDEX = $0197
#LB_GETTOPINDEX = $018E
#RDW_INVALIDATE = $0001
#RDW_UPDATENOW = $0100
#SB_THUMBPOSITION = 4
#LVM_ENSUREVISIBLE = (#LVM_FIRST + 19)

;-- 3. Variables globales
Global NewList DetectedPackages.s()
Global NewList PackageDescriptions.s()
Global NewList IsSystemPackage.b()
Global NewList PackageStatus.s()
Global Dim BloatwarePackages.s(4894);--------------------------------------------------------------------------------------------------------------------------------------------------
Global Dim BloatwareDescriptions.s(4894)
; Variables para scroll
Global Scroll_hList.i
Global Scroll_Rect.RECT
Global description.s
Global desc.s
Global Scroll_iPause.i = 10  ; Velocidad del scroll (ajustable)
Global Scroll_iCurrentPos.i
Global Scroll_iTargetPos.i
Global Scroll_iItemHeight.i = 20  ; Altura estimada por defecto
Global action 

; Constantes para API de Windows
#WM_VSCROLL = $0115
#SB_LINEDOWN = 1
#LB_GETITEMHEIGHT = $01A1
#LB_SETTOPINDEX = $0197

IncludeFile "DIMbloat.pb"


Procedure.s ExecuteADBCommand(command.s, isCheckStatus.b = #False)
  Protected comspec.s = GetEnvironmentVariable("COMSPEC")
  If comspec = "" : comspec = "cmd.exe" : EndIf
  
  Protected program.i = RunProgram(comspec, " /c adb " + command, "", #PB_Program_Open|#PB_Program_Read|#PB_Program_Hide)
  Protected output.s = ""
  
  If program
    While ProgramRunning(program)
      output + ReadProgramString(program) + #CRLF$
    Wend
    CloseProgram(program)
  EndIf
  
  ProcedureReturn output
EndProcedure

Procedure.s CheckPackageStatus(packageName.s)
  Protected output.s = ExecuteADBCommand("shell pm list packages -d | find " + Chr(34) + packageName + Chr(34), #True)
  If FindString(output, packageName, 1) : ProcedureReturn "Deshabilitado" : EndIf
  
  output = ExecuteADBCommand("shell pm list packages | find " + Chr(34) + packageName + Chr(34), #True)
  If FindString(output, packageName, 1) : ProcedureReturn "Activo" : EndIf
  
  ProcedureReturn "No instalado"
EndProcedure

Procedure.s ManagePackage(packageName.s, action.s)
  Protected command.s, result.s
  
  Select action
    Case "uninstall":
      command = "shell pm uninstall --user 0 " + packageName
      result = "Desinstalación"
    Case "disable":
      command = "shell pm disable-user --user 0 " + packageName
      result = "Deshabilitación"
    Case "clear":
      command = "shell pm clear " + packageName
      result = "Limpieza"
    Default:
      ProcedureReturn "Acción no válida"
  EndSelect
  
  Protected output.s = ExecuteADBCommand(command)
  
  If FindString(LCase(output), "success", 1)
    ProcedureReturn result + " exitosa"
  ElseIf output <> ""
    ProcedureReturn result + " fallida: " + output
  EndIf
  
  ProcedureReturn result + " - Sin respuesta del dispositivo"
EndProcedure

Procedure ScrollToItem(itemIndex)
  Scroll_hList = GadgetID(#List_Packages)
  Protected itemCount = SendMessage_(Scroll_hList, #LVM_GETITEMCOUNT, 0, 0)
  
  ; Verificar límites
  If itemIndex < 0 : itemIndex = 0 : EndIf
  If itemIndex >= itemCount : itemIndex = itemCount - 1 : EndIf
  
  ; Seleccionar el item
  SetGadgetItemState(#List_Packages, itemIndex, #PB_ListIcon_Selected)
  SetActiveGadget(#List_Packages)
  
  ; Método 1: Asegurar que el item sea visible
  SendMessage_(Scroll_hList, #LVM_ENSUREVISIBLE, itemIndex, 1)
  
  ; Método 2: Scroll adicional para centrar mejor el item
  Protected visibleItems = SendMessage_(Scroll_hList, #LVM_GETCOUNTPERPAGE, 0, 0)
  Protected currentTop = SendMessage_(Scroll_hList, #LVM_GETTOPINDEX, 0, 0)
  Protected targetTop = itemIndex - (visibleItems / 3)
  
  If targetTop < 0 : targetTop = 0 : EndIf
  
  ; Obtener altura del item
  SendMessage_(Scroll_hList, #LVM_GETITEMRECT, itemIndex, @Scroll_Rect)
  Protected itemHeight = Scroll_Rect\bottom - Scroll_Rect\top
  If itemHeight <= 0 : itemHeight = 20 : EndIf
  
  ; Calcular scroll necesario
  Protected scrollPixels = (targetTop - currentTop) * itemHeight
  
  ; Aplicar scroll
  If scrollPixels <> 0
    SendMessage_(Scroll_hList, #LVM_SCROLL, 0, scrollPixels)
  EndIf
  
  ; Forzar redibujado
  UpdateWindow_(Scroll_hList)
  RedrawWindow_(Scroll_hList, 0, 0, #RDW_INVALIDATE|#RDW_UPDATENOW)
EndProcedure

Procedure UpdatePackageList()
  ClearGadgetItems(#List_Packages)
  ClearList(PackageStatus())
  
  Protected showSystemApps.b = GetGadgetState(#Checkbox_SystemApps)
  Protected i.i, status.s, type.s, action.s, description.s, dangerLevel.i, priority.i
  
  Protected allPackages.s = ExecuteADBCommand("shell pm list packages", #True)
  Protected disabledPackages.s = ExecuteADBCommand("shell pm list packages -d", #True)

  ; Estructura temporal para ordenar
  Structure TempPackage
    Name.s
    Description.s
    IsSystem.b
    DangerLevel.i
    Status.s
    Action.s
    Priority.i
  EndStructure
  
  NewList TempPackages.TempPackage()
  
  ; Recopilar información de paquetes
  ResetList(DetectedPackages())
  ResetList(PackageDescriptions())
  ResetList(IsSystemPackage())
  
  While NextElement(DetectedPackages())
    If Not NextElement(PackageDescriptions()) Or Not NextElement(IsSystemPackage())
      Break
    EndIf
    
    description = PackageDescriptions()
    
    If (IsSystemPackage() And Not showSystemApps)
      Continue
    EndIf

    ; Determinar estado
    If FindString(disabledPackages, DetectedPackages(), 1)
      status = "Disabled"
    ElseIf FindString(allPackages, DetectedPackages(), 1)
      status = "Enable"
    Else
      status = "Not Installed"
    EndIf
    
    ; Asignar acción y prioridad por defecto (blanco)
    action = "      (*)"
    dangerLevel = 0
    priority = 5  ; Último lugar
    
    ; Determinar acción recomendada según descripción
    If description <> ""
      If FindString(LCase(description), "delete if not used", 1) Or
         FindString(LCase(description), "malware", 1) Or 
         FindString(LCase(description), "troyano", 1) Or
         FindString(LCase(description), "spyware", 1) Or
         FindString(LCase(description), "adware", 1) Or
         FindString(LCase(description), "safe to remove", 1) Or
         FindString(LCase(description), "publicidad", 1); And FindString(LCase(description), "do not remove") =0 And FindString(LCase(description), "not safe") =0 And FindString(LCase(description), "caution if") =0        
        action = "Delete If Not used"
        dangerLevel = 8
        priority = 1  ; Rojo - Primero
        
      ElseIf FindString(LCase(description), "can be replaced", 1); And FindString(LCase(description), "do not remove") =0
        action = "Can be Replaced"
        dangerLevel = 5
        priority = 2  ; Amarillo - Segundo
        
      ElseIf FindString(LCase(description), "caution if removing", 1) ;And FindString(LCase(description), "safe to remove") =0
        action = "Caution If Removing"
        dangerLevel = 4
        priority = 3  ; Verde - Tercero
        
      ElseIf FindString(LCase(description), "not safe to delete", 1) Or FindString(LCase(description), "do not remove")
        action = "Not Safe To Delete"
        dangerLevel = 2
        priority = 4  ; Morado - Cuarto
      EndIf
    EndIf
    
;     Not Safe To Delete, Caution If Removing, Can be Replaced, Delete If Not used
    
    ; Añadir a lista temporal
    AddElement(TempPackages())
    TempPackages()\Name = DetectedPackages()
    TempPackages()\Description = description
    TempPackages()\IsSystem = IsSystemPackage()
    TempPackages()\DangerLevel = dangerLevel
    TempPackages()\Status = status
    TempPackages()\Action = action
    TempPackages()\Priority = priority
  Wend
  
  ; Ordenar primero por prioridad y luego por peligrosidad
  SortStructuredList(TempPackages(), #PB_Sort_Ascending, OffsetOf(TempPackage\Priority), TypeOf(TempPackage\Priority))
  SortStructuredList(TempPackages(), #PB_Sort_Descending, OffsetOf(TempPackage\DangerLevel), TypeOf(TempPackage\DangerLevel))
  
  ; Mostrar paquetes ordenados
  ForEach TempPackages()
    type = "User" 
    If TempPackages()\IsSystem 
      type = "System" 
    EndIf
    
    AddGadgetItem(#List_Packages, -1, TempPackages()\Name + #LF$ + type + #LF$ + TempPackages()\Status + #LF$ + TempPackages()\Action)
    
    ; Aplicar colores según la acción
    Select TempPackages()\Action        
      Case "Delete If Not used"
        SetGadgetItemColor(#List_Packages, CountGadgetItems(#List_Packages)-1, #PB_Gadget_BackColor, RGB(255, 150, 150), -1) ; Rojo
      
      Case "Can be Replaced"
        SetGadgetItemColor(#List_Packages, CountGadgetItems(#List_Packages)-1, #PB_Gadget_BackColor, RGB(255, 255, 150), -1) ; Amarillo
      
      Case "Caution If Removing"
        SetGadgetItemColor(#List_Packages, CountGadgetItems(#List_Packages)-1, #PB_Gadget_BackColor, RGB(150, 255, 150), -1) ; Verde
      
      Case "Not Safe To Delete"
        SetGadgetItemColor(#List_Packages, CountGadgetItems(#List_Packages)-1, #PB_Gadget_BackColor, RGB(200, 150, 255), -1) ; Morado
      
      Default
        SetGadgetItemColor(#List_Packages, CountGadgetItems(#List_Packages)-1, #PB_Gadget_BackColor, RGB(255, 255, 255), -1) ; Blanco
    EndSelect
  Next
  
  StatusBarText(#StatusBar, 1, "Packets: " + Str(CountGadgetItems(#List_Packages)))
EndProcedure

Procedure IdentifyBloatwareForGUI()
  ClearList(DetectedPackages())
  ClearList(PackageDescriptions())
  ClearList(IsSystemPackage())
  
  Protected output.s = ExecuteADBCommand("shell pm list packages", #True)
  If output = "" : ProcedureReturn #False : EndIf
  
  Protected count.i = CountString(output, #CRLF$)
  Protected i.i, line.s, packageName.s, isSystem.b, description.s, j.i
  
  For i = 1 To count
    line = Trim(StringField(output, i, #CRLF$))
    If line = "" : Continue : EndIf
    
    packageName = Trim(StringField(line, 2, ":"))
    isSystem = Bool(FindString(packageName, "android.", 1) Or FindString(packageName, "com.google.", 1) Or FindString(packageName, "com.android.", 1))
    description = ""
    
    For j = 0 To ArraySize(BloatwarePackages())
      If BloatwarePackages(j) <> "" And LCase(packageName) = LCase(BloatwarePackages(j))
        description = BloatwareDescriptions(j)
        Break
      EndIf
    Next
    
    AddElement(DetectedPackages()) : DetectedPackages() = packageName
    AddElement(PackageDescriptions()) : PackageDescriptions() = description
    AddElement(IsSystemPackage()) : IsSystemPackage() = isSystem
  Next
  
  ProcedureReturn #True
EndProcedure

Procedure SearchPackages(searchTerm.s)
  If searchTerm = ""
    UpdatePackageList()
    ProcedureReturn
  EndIf
  
  Protected foundIndex = -1
  searchTerm = LCase(searchTerm)
  
  ; Buscar en elementos visibles
  For i = 0 To CountGadgetItems(#List_Packages) - 1
    If FindString(LCase(GetGadgetItemText(#List_Packages, i, 0)), searchTerm, 1)
      foundIndex = i
      Break
    EndIf
  Next
  
  ; Si no se encontró, buscar en toda la lista
  If foundIndex = -1
    ResetList(DetectedPackages())
    While NextElement(DetectedPackages())
      If FindString(LCase(DetectedPackages()), searchTerm, 1)
        UpdatePackageList()
        For i = 0 To CountGadgetItems(#List_Packages) - 1
          If LCase(GetGadgetItemText(#List_Packages, i, 0)) = LCase(DetectedPackages())
            foundIndex = i
            Break 2
          EndIf
        Next
      EndIf
    Wend
  EndIf
  
  ; Manejar resultado
  If foundIndex >= 0
    ScrollToItem(foundIndex)
  Else
    MessageRequester("Búsqueda", "No se encontraron coincidencias para: " + searchTerm, #PB_MessageRequester_Info)
  EndIf
EndProcedure

Procedure CreateGUI()
  If OpenWindow(#Window_Main, 0, 0, 700, 750, "Bloatware Remover", #PB_Window_ScreenCentered)
    ; Controles de búsqueda
    TextGadget(#Text_Search, 10, 10, 60, 20, "")
    StringGadget(#Input_Search, 30, 10, 150, 20, "")
    ButtonGadget(#Button_Search, 190, 10, 120, 20, "Search")
    
    ; Lista principal
  ListIconGadget(#List_Packages, 0, 40, 680, 300, "Packet", 340, #PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines)
  AddGadgetColumn(#List_Packages, 1, "Type", 80)
  AddGadgetColumn(#List_Packages, 2, "Status", 95)
  AddGadgetColumn(#List_Packages, 3, "Action", 140)
    
    ; Descripción
    EditorGadget(#Text_Description, 10, 350, 680, 150, #PB_Editor_ReadOnly | #PB_Editor_WordWrap)
    
    ; Botones principales
    ButtonGadget(#Button_Delete, 10, 510, 120, 30, "Uninstall")
    ButtonGadget(#Button_Disable, 140, 510, 120, 30, "Disable")
    ButtonGadget(#Button_RefreshList, 270, 510, 120, 30, "Scan")
    ButtonGadget(#Button_SaveReport, 400, 510, 120, 30, "Save report")
    ButtonImageGadget(#Button_Salir, 625, 650, 70, 70, images(30))
    
    ; Checkbox
    CheckBoxGadget(#Checkbox_SystemApps, 535, 515, 200, 25, "Show System Apps")
    SetGadgetState(#Checkbox_SystemApps, #True)
    
    ; Barra de estado
    CreateStatusBar(#StatusBar, WindowID(#Window_Main))
    AddStatusBarField(200)
    AddStatusBarField(300)
    
    ; Barra de progreso
    ProgressBarGadget(#ProgressBar, 10, 550, 780, 20, 0, 100)
    HideGadget(#ProgressBar, #True)
    
    ; Leyenda de colores

    Define gadgetBloatware = TextGadget(#PB_Any, 10, 613, 500, 20, "")
    SetGadgetColor(gadgetBloatware, #PB_Gadget_BackColor, RGB(255, 150, 150))
    SetGadgetText(gadgetBloatware, " Delete If Not used")
    
    Define gadgetPublicidad = TextGadget(#PB_Any, 10, 634, 400, 20, "")
    SetGadgetColor(gadgetPublicidad, #PB_Gadget_BackColor, RGB(200, 255, 200))
    SetGadgetText(gadgetPublicidad, " Can be Replaced")
    
    Define gadgetPublicidad = TextGadget(#PB_Any, 10, 655, 200, 20, "")
    SetGadgetColor(gadgetPublicidad, #PB_Gadget_BackColor, RGB(255, 255, 150))
    SetGadgetText(gadgetPublicidad, " Caution If removing")
    
    Define gadgetSeguro = TextGadget(#PB_Any, 10, 676, 150, 20, "")
    SetGadgetColor(gadgetSeguro, #PB_Gadget_BackColor, RGB(200, 200, 255))
    SetGadgetText(gadgetSeguro, " Not Safe To Delete")
    
    StatusBarText(#StatusBar, 0, "Listo. Pulse Actualizar para comenzar")
  EndIf

EndProcedure

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 370
; FirstLine = 352
; Folding = --
; EnableXP