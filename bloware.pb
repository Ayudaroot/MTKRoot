; 5. Código principal
Define quit.i = #False
Define selected.i, selectedPackage.s, result.s, file.s, i.i, j.i

CreateGUI()

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_CloseWindow
      quit = #True
      
    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case #List_Packages
If EventType() = #PB_EventType_Change
            selected = GetGadgetState(#List_Packages)
            If selected >= 0
              selectedPackage = GetGadgetItemText(#List_Packages, selected, 0)
              
              ; Buscar la descripción en BloatwareDescriptions
               description.s = ""
              For i = 0 To ArraySize(BloatwarePackages()) - 1
                If LCase(selectedPackage) = LCase(BloatwarePackages(i))
                  description = BloatwareDescriptions(i)
                  Break
                EndIf
              Next
              
              ; Si no se encontró en BloatwareDescriptions, buscar en PackageDescriptions
              If description = ""
                For i = 0 To ListSize(DetectedPackages()) - 1
                  SelectElement(DetectedPackages(), i)
                  If DetectedPackages() = selectedPackage
                    SelectElement(PackageDescriptions(), i)
                    description = PackageDescriptions()
                    Break
                  EndIf
                Next
              EndIf
              
              SetGadgetText(#Text_Description, description)
              
              ; Cambiar color de fondo según contenido
              If description <> ""
                SetGadgetColor(#Text_Description, #PB_Gadget_BackColor, RGB(255, 255, 200))
              Else
                SetGadgetColor(#Text_Description, #PB_Gadget_BackColor, RGB(255, 255, 255))
              EndIf
            EndIf
          EndIf
          
        Case #Button_Delete
          selected = GetGadgetState(#List_Packages)
          If selected >= 0
            selectedPackage = GetGadgetItemText(#List_Packages, selected, 0)
            If MessageRequester("Confirmar", "¿Desinstalar " + selectedPackage + "?", #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning) = #PB_MessageRequester_Yes
              HideGadget(#ProgressBar, #False)
              SetGadgetState(#ProgressBar, 80)
              StatusBarText(#StatusBar, 0, "Desinstalando...")
              
              result = ManagePackage(selectedPackage, "uninstall")
              ;MessageRequester("Resultado", result)
              
              IdentifyBloatwareForGUI()
              UpdatePackageList()
              SetGadgetState(#ProgressBar, 0)
              HideGadget(#ProgressBar, #True)
            EndIf
          EndIf
          
        Case #Button_Disable
          selected = GetGadgetState(#List_Packages)
          If selected >= 0
            selectedPackage = GetGadgetItemText(#List_Packages, selected, 0)
            If MessageRequester("Confirmar", "¿Deshabilitar " + selectedPackage + "?", #PB_MessageRequester_YesNo|#PB_MessageRequester_Warning) = #PB_MessageRequester_Yes
              HideGadget(#ProgressBar, #False)
              SetGadgetState(#ProgressBar, 80)
              StatusBarText(#StatusBar, 0, "Deshabilitando...")
              
              result = ManagePackage(selectedPackage, "disable")
              ;MessageRequester("Resultado", result)
              
              IdentifyBloatwareForGUI()
              UpdatePackageList()
              SetGadgetState(#ProgressBar, 0)
              HideGadget(#ProgressBar, #True)
            EndIf
          EndIf
          
        Case #Button_Salir
          CloseWindow(#Window_Main)
          SetActiveWindow(#Window_0)
          Goto inicio
          
        Case #Button_Search
          SearchPackages(GetGadgetText(#Input_Search))
          
        Case #Button_RefreshList
          HideGadget(#ProgressBar, #False)
          SetGadgetState(#ProgressBar, 80)
          StatusBarText(#StatusBar, 0, "Actualizando lista...")
          
          If IdentifyBloatwareForGUI()
            UpdatePackageList()
            StatusBarText(#StatusBar, 0, "Lista actualizada")
          Else
            StatusBarText(#StatusBar, 0, "Error al actualizar")
          EndIf
          
          SetGadgetState(#ProgressBar, 0)
          HideGadget(#ProgressBar, #True)
          
        Case #Button_SaveReport
          file = SaveFileRequester("Guardar reporte", "Log.txt", "Text files|*.txt", 0)
          If file <> ""
            If CreateFile(0, file)
              For i = 0 To CountGadgetItems(#List_Packages) - 1
                selectedPackage = GetGadgetItemText(#List_Packages, i, 0)
                
                 desc.s = ""
                For j = 0 To ArraySize(BloatwarePackages()) - 1
                  If LCase(selectedPackage) = LCase(BloatwarePackages(j))
                    desc = BloatwareDescriptions(j)
                    Break
                  EndIf
                Next
                
                WriteStringN(0, "Reporte generado: " + FormatDate("%dd/%mm/%yyyy %hh:%ii", Date()))
                WriteStringN(0, "")
                WriteStringN(0, "Paquete: " + selectedPackage)
                WriteStringN(0, "Tipo: " + GetGadgetItemText(#List_Packages, i, 1))
                WriteStringN(0, "Estado: " + GetGadgetItemText(#List_Packages, i, 2))
                WriteStringN(0, "Descripción: " + desc)
                WriteStringN(0, "")
              Next
              CloseFile(0)
              MessageRequester("Éxito", "Reporte guardado", #PB_MessageRequester_Info)
            EndIf
          EndIf
          
        Case #Checkbox_SystemApps
          UpdatePackageList()
          
        Case #Input_Search
          If EventType() = #PB_EventType_Focus
            SetActiveGadget(#Input_Search)
          EndIf
      EndSelect
  EndSelect
Until quit = 1
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 90
; EnableXP