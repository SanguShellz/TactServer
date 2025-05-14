#SingleInstance, Force
#NoTrayIcon
#NoEnv

OnMessage(0x0200, "WM_MOUSEMOVE")

; ======================
; :::::::: GUI  ::::::::
; ======================
Gui, Margin, 0, 0
Gui, Color, FFFFFF, e9ecf4 
Gui, Font, % (FontOptions := "s10 bold"), % (FontName := "Verdana")
hBM := CreateSolidBitmap(260, 5, 0xF59E30)

;|| Trigger Selection DropDownList
Gui, Add, Picture, Section x0 y0 w260 h21 +Border, % P "..\.repo\images\Banners\Trigger Selection.jpg"

Gui, Add, ComboBox, section xs+5 y+4 w250 vTriggerList gTriggerList +HwndTrigList 

;Trigger Settings
Gui, Add, text,section xs+0 y+6 w10, I:
Gui, Add, Edit,x+1 ys-2 w60 vIntensity

Intensity_TT := "Intensity settings"

Gui, Add, text,x+5 ys+0 w10, D:
Gui, Add, Edit, x+1 ys-2 w50 vDuration

Duration_TT := "Duration settings"

;Save selected trigger settings changes
Gui, Add, Picture, section x+2 ys+0 w18 h18 vSaveSettings gSaveSettings,% P "D:\My Games\Apps\bHaptics\TactServer\.repo\images\SaveGreen.jpg"

Gui, Add, Picture, xs+0 ys+0 w18 h18 vSaveSettings1 gSaveSettings,% P "D:\My Games\Apps\bHaptics\TactServer\.repo\images\Save.jpg"

SaveSettings_TT := "Save Trigger Settings"

;|| Trigger Tact pattern
Gui, Add, Picture,  x+3 ys+0 w18 h18 vRunTrigger gRunTrigger,% P "..\.repo\images\play.png"

RunTrigger_TT := "Trigger Tact Pattern"

; Add Selected Trigger to Multi-Trogger List 
Gui, Add, Picture, x+39 ys-4 w28 h28 vAddTrigger gAddTrigger,% P "..\.repo\images\arrow.jpg"

AddTrigger_TT := "Select, Add TactPattern to ListBox"

;---HorizLine---
Gui, Add, Picture,section x0 y+3 w260 h5, HBITMAP:*%hBM%

Gui, Add, ListBox,section x5 y+4 w250 h50 vTriggerBox gTriggerBox +HwndTrigBox , 

;|| Delete Trigger Button.
Gui, Add, Picture, xs+0 y+3 w18 h23 vDeleteTrigger gDeleteTrigger,% P "..\.repo\images\Trash.png"

DeleteTrigger_TT := "Delete Selected Trigger from ListBox"

;|| Save MultiTrigger 
Gui, Add, Picture, Section x0 y+6 w260 h21, % P "..\.repo\images\Banners\MultiTrigger.jpg"

Gui, Add, text, section x5 y+4 w10, S:
Gui, Add, Edit, x+5 ys+0 w230 vSubFolderName

SubFolderName_TT := "Name Subfolder"

Gui, Add, text, section x5 y+4 w10, M:
Gui, Add, Edit, x+2 ys+0 w230 vMultiTriggerName

MultiTriggerName_TT := "Name MultiTrigger"

;---HorizLine---
Gui, Add, Picture,section x0 y+3 w260 h5, HBITMAP:*%hBM%

;|| ;Save Multi-Trigger
Gui, Add, Picture, section x5 y+4  w22 h22 vSaveMultiTrigger gSaveMultiTrigger,% P "..\.repo\images\Save.jpg"

Gui, Add, Picture, section xs+0 ys+0  w22 h22 vSaveMultiTrigger1 gSaveMultiTrigger,% P "..\.repo\images\SaveGreen.jpg"

SaveMultiTrigger_TT := "Save MultiTrigger"

;|| Save and Play Saved Multi-Trigger
Gui, Add, Picture, x+4 ys+2 w18 h18 vPlayMultiTrigger gRunMultiTrigger,% P "..\.repo\images\play.png"

RunMultiTrigger_TT := "Run Saved MultiTrigger"

Gui, Add, ComboBox,section x5 y+6 w250 vMultiTriggerList gMultiTriggerList + hwndMultiTrigList

MultiTriggerList_TT := "Search or select MultiTrigger"

Gui, Add, Picture, section xs+0 y+3 w18 h23 vDeleteMultiTrigger gDeleteMultiTrigger,% P "..\.repo\images\Trash.png"

;--bottom padding--
Gui, Add, Text, section x0 y+10 w260 h0 0x10 

;---GUI ENDr---
Gui, Show, , MultiTrigger GUI, w260 AutoSize 

TriggerList := ""
MultiTriggerList := ""

LoadTriggerList()
gosub, MultiTriggerListINI
LoadMultiTriggerList()

return

GuiClose:
    ExitApp
    
; =============================
; :::::::: SUBROUTINES ::::::::
; =============================
TriggerList:
    ; Run auto-complete. If it isn’t complete/valid, exit.
    valid := CbAutoComplete("TriggerList")
    if (!valid)
        Return

    Gui, Submit, NoHide
    SelectedTactPattern := Trim(TriggerList, " `t`r`n")
    if (SelectedTactPattern != "") {
        firstUnderscorePos := InStr(SelectedTactPattern, "_")
        if (firstUnderscorePos) {
            Subfolder := Trim(SubStr(SelectedTactPattern, 1, firstUnderscorePos - 1), " `t`r`n")
            FileName    := Trim(SubStr(SelectedTactPattern, firstUnderscorePos + 1), " `t`r`n")
            
            iniFilePath := A_ScriptDir . "\..\Triggers\" . Subfolder . "\" . FileName . "_settings.ini"
            if (FileExist(iniFilePath)) {
                IniRead, intensity, %iniFilePath%, Settings, intensity  
                IniRead, duration,  %iniFilePath%, Settings, duration 

                GuiControl, , Intensity, %intensity%
                GuiControl, , Duration, %duration%
            } else {
                MsgBox, Settings file not found:`n%iniFilePath%
            }
        } else {
            MsgBox, Invalid trigger format!
        }
    }
Return

SaveSettings:
	Gui, Submit, NoHide
	SelectedTactPattern := Trim(TriggerList)

	if (SelectedTactPattern != "") {
	
		loop, 3 {
		GuiControl, Hide, SaveSettings
		GuiControl, Show, SaveSettings1 
		sleep, 100
		GuiControl, Show, SaveSettings
		GuiControl, Hide, SaveSettings1 
		sleep, 200
		}
	
		StringSplit, Parts, SelectedTactPattern, _

		if (Parts0 == 2) {
			Subfolder := Trim(Parts1)
			FileName := Trim(Parts2)
			FileName := RegExReplace(FileName, "^\s+|\s+$") 

			iniFilePath := A_ScriptDir "\..\Triggers\" Subfolder "\" FileName "_settings.ini"

			IniWrite, %Intensity%, %iniFilePath%, Settings, intensity
			IniWrite, %Duration%, %iniFilePath%, Settings, duration
		}
	}
	Return

RunTrigger:
    Gui, Submit, NoHide
    SelectedTactPattern := Trim(TriggerList)

    if (SelectedTactPattern != "") {
        StringSplit, Parts, SelectedTactPattern, _

        if (Parts0 == 2) {
            Subfolder := Trim(Parts1)
            FileName := Trim(Parts2)
            FileName := RegExReplace(FileName, "^\s+|\s+$") 
            FileName := FileName ".vbs"
 

            TriggersPath := A_WorkingDir "\..\Triggers\" Subfolder
            VBScriptPath := TriggersPath "\" FileName

            SetWorkingDir, %TriggersPath%

            ; Run the VBScript
            Run, %FileName%
        } else {
            MsgBox, Invalid format for the selected item.
        }
    } else {
		MsgBox, Please select a trigger pattern.
    }
    return
	
AddTrigger:
    Gui, Submit, NoHide
    SelectedTactPattern := Trim(TriggerList)
    InputText := Trim(InputBox)
    
    if (SelectedTactPattern != "")
        GuiControl, , TriggerBox, %SelectedTactPattern%`n

    if (InputText != "") {
        GuiControl, , TriggerBox, %InputText%
        GuiControl, , InputBox, 
    }
    return
	
DeleteTrigger:
    Gui, Submit, NoHide
    SelectedTactPattern := Trim(TriggerList)
    
    SelectedIndex := LBEX_GetCurrentSel(TrigBox)

    if (SelectedIndex > 0) {
        LBEX_Delete(TrigBox, SelectedIndex)
    } else {
        MsgBox, Please select an item to delete.
    }
    return
	
TriggerBox:
    Gui, Submit, NoHide
    ; Retrieve the text of the selected item from the ListBox
    GuiControlGet, selectedTrigger, , TriggerBox, Choice
    selectedTrigger := Trim(selectedTrigger, " `t`r`n")
    
    if (selectedTrigger != "")
    {
        ; Set the matching item in the DropDownList
        GuiControl, Choose, TriggerList, %selectedTrigger%
        ; Now force the TriggerList code to run so that the intensity and duration fields update
        Gosub, TriggerList
    }
return

SaveMultiTrigger:
    Gui, Submit, NoHide
    FileName := Trim(MultiTriggerName) ".vbs"
    SubFolder := Trim(SubFolderName)

    ScriptFolder := "\"

    if (FileName != ".vbs") {
        if (SubFolder != "") {
            SubFolderPath := A_ScriptDir "\" ScriptFolder "\" SubFolder
            if (!FileExist(SubFolderPath))
                FileCreateDir %SubFolderPath%

            ItemCount := LBEX_GetCount(TrigBox)

            if (ItemCount > 0) {
                loop, 3 {
                    GuiControl, Hide, SaveMultiTrigger1
                    GuiControl, Show, SaveMultiTrigger   
                    sleep, 100
                    GuiControl, Show, SaveMultiTrigger1
                    GuiControl, Hide, SaveMultiTrigger 
                    sleep, 200
                }
                FullPath := SubFolderPath "\" FileName
                MultiSettingsFile := SubFolderPath "\" MultiTriggerName "_multisettings.ini"
                VBScriptContent := "Dim triggerMessages" . "`n"
                VBScriptContent := VBScriptContent . "Dim pythonExecutable, pythonScript, objShell" . "`n"
                VBScriptContent := VBScriptContent . "Dim objFSO, objINIFile, strLine, intensity, duration" . "`n`n"
                VBScriptContent := VBScriptContent . "pythonExecutable = ""..\..\.repo\Python\python.exe""" . "`n"
                VBScriptContent := VBScriptContent . "pythonScript = ""..\..\.repo\Python\TactClient.py""" . "`n`n"
                VBScriptContent := VBScriptContent . "Set objShell = CreateObject(""WScript.Shell"")" . "`n"
                VBScriptContent := VBScriptContent . "Set objFSO = CreateObject(""Scripting.FileSystemObject"")" . "`n`n"

                MultiSettingsContent := ""

                Loop, % ItemCount {
                    ItemText := LBEX_GetText(TrigBox, A_Index)
                    ItemText := RegExReplace(ItemText, "^\s+|\s+$", "")

                    StringSplit, itemArray, ItemText, _

                    iniFilePath := A_ScriptDir "\..\Triggers\" itemArray1 "\" itemArray2 "_settings.ini"
					
                    if (FileExist(iniFilePath)) {
                        IniRead, intensity, %iniFilePath%, Settings, intensity

                        IniRead, duration, %iniFilePath%, Settings, duration
                    }

                    intensity := intensity
                    duration := duration

                    MultiSettingsContent := MultiSettingsContent . "[" . itemArray2 "_" itemArray1 . "]" . "`n"
                    MultiSettingsContent := MultiSettingsContent . "intensity = " . intensity . "`n"
                    MultiSettingsContent := MultiSettingsContent . "duration = " . duration . "`n`n"

                    VBScriptContent := VBScriptContent . "iniFilePath = """ . MultiTriggerName . "_multisettings.ini""" . "`n"
                    VBScriptContent := VBScriptContent . "If objFSO.FileExists(iniFilePath) Then" . "`n"
                    VBScriptContent := VBScriptContent . "    Set objINIFile = objFSO.OpenTextFile(iniFilePath, 1)" . "`n"
                    VBScriptContent := VBScriptContent . "    Do Until objINIFile.AtEndOfStream" . "`n"
                    VBScriptContent := VBScriptContent . "        strLine = objINIFile.ReadLine" . "`n"
                    VBScriptContent := VBScriptContent . "        If InStr(LCase(strLine), ""intensity"") > 0 Then" . "`n"
                    VBScriptContent := VBScriptContent . "            arrSplit = Split(strLine, ""="")" . "`n"
                    VBScriptContent := VBScriptContent . "            If UBound(arrSplit) > 0 Then intensity = Trim(arrSplit(1))" . "`n"
                    VBScriptContent := VBScriptContent . "        End If" . "`n"
                    VBScriptContent := VBScriptContent . "        If InStr(LCase(strLine), ""duration"") > 0 Then" . "`n"
                    VBScriptContent := VBScriptContent . "            arrSplit = Split(strLine, ""="")" . "`n"
                    VBScriptContent := VBScriptContent . "            If UBound(arrSplit) > 0 Then duration = Trim(arrSplit(1))" . "`n"
                    VBScriptContent := VBScriptContent . "        End If" . "`n"
                    VBScriptContent := VBScriptContent . "    Loop" . "`n"
                    VBScriptContent := VBScriptContent . "    objINIFile.Close" . "`n"
                    VBScriptContent := VBScriptContent . "Else" . "`n"
                    VBScriptContent := VBScriptContent . "    intensity = ""0.6""" . "`n"
                    VBScriptContent := VBScriptContent . "    duration = ""1.0""" . "`n"
                    VBScriptContent := VBScriptContent . "End If" . "`n`n"
                    VBScriptContent := VBScriptContent . "triggerMessage = """ . itemArray2 "_" itemArray1 . """" . " & ""_"" & intensity & ""_"" & duration" . "`n"
                    VBScriptContent := VBScriptContent . "objShell.Run """" & pythonExecutable & "" "" & pythonScript & "" "" & """" & triggerMessage & """", 0, True" . "`n`n"
                }

                VBScriptContent := VBScriptContent . "Set objShell = Nothing" . "`n"
                VBScriptContent := VBScriptContent . "Set objFSO = Nothing" . "`n"

                FileDelete, %FullPath%
                FileAppend, %VBScriptContent%, %FullPath%

                FileDelete, %MultiSettingsFile%
                FileAppend, %MultiSettingsContent%, %MultiSettingsFile%

                sleep, 100

                gosub, MultiTriggerListINI

                sleep, 100

			    gosub, Select
                
            } else {
                MsgBox, No items in the ListBox to save.
            }
        } else {
            MsgBox, Please enter a subfolder name.
        }
    } else {
        MsgBox, Please enter a name for the MultiTrigger.
    }
    return
	
	MultiTriggerList:
    ; Run auto-complete for the multi trigger list.
    valid := CbAutoComplete("MultiTriggerList")
    if (!valid)
        Return

    Gui, Submit, NoHide
    GuiControlGet, SelectedMultiTrigger,, MultiTriggerList
    if (SelectedMultiTrigger != "")
        Gosub, LoadMultiTrigger
Return
	
MultiTriggerListINI:
	scriptDir := A_ScriptDir
	iniFile := scriptDir . "\MultiTriggerList.ini"

	filesData := {}

	Loop, Files, %scriptDir%\*.*, D
	{
		folder := A_LoopFileName
		folderPath := A_LoopFileFullPath
		fileArray := []
		
		Loop, Files, %folderPath%\*.vbs, F
		{
			 fileArray.Push(A_LoopFileName)
		}
		
		if (fileArray.Length() > 0)
			filesData[folder] := fileArray
	}

	FileDelete, %iniFile%

	hasEntries := false
	for key, value in filesData
	{
		hasEntries := true
		break
	}

	if (!hasEntries)
	{
		FileAppend, , %iniFile%
		return
	}

	folders := []
	for folder, arr in filesData
		folders.Push(folder)
	folders.Sort()

	index := 1

	for indexFolder, folder in folders
	{
		fileArray := filesData[folder]
		fileArray.Sort()
		
		for indexFile, file in fileArray
		{
			SplitPath, file, , , , nameNoExt
			value := nameNoExt . "_" . folder
			IniWrite, %value%, %iniFile%, MultiTriggers, %index%
			index++
		}
	}
	Return

RunMultiTrigger:
    Gui, Submit, NoHide
    MultiTriggerName := Trim(MultiTriggerName)
    SubFolderName := Trim(SubFolderName)

    if (SubFolderName != "" and MultiTriggerName != "") {

        VBScriptPath := A_ScriptDir "\" SubFolderName "\" MultiTriggerName ".vbs"

        SetWorkingDir, %A_ScriptDir%\%SubFolderName%

        if (FileExist(VBScriptPath)) {

            Run, % MultiTriggerName ".vbs"
        } else {
            MsgBox, VBScript file not found: %VBScriptPath%
        }
    } else {
        MsgBox, Please enter a subfolder name and a MultiTrigger name.
    }
    return
	
LoadMultiTrigger:
    Gui, Submit, NoHide
    SelectedMultiTrigger := Trim(MultiTriggerList)
    
    LBEX_DeleteAll(TrigBox)
    
    if (SelectedMultiTrigger != "") {

        StringSplit, SelectedParts, SelectedMultiTrigger, _
        if (SelectedParts0 == 2) {
            SubFolder := RegExReplace(SelectedParts1, "^\s+|\s+$")
            MultiTriggerName := RegExReplace(SelectedParts2, "^\s+|\s+$")
            FullPath := A_ScriptDir . "\" . SubFolder . "\" . MultiTriggerName . ".vbs"
            
            if (FileExist(FullPath)) {
                FileRead, ScriptContent, %FullPath%
                if (ScriptContent = "") {
                    MsgBox, The file is empty:`n%FullPath%
                    return
                }
                
                Loop, Parse, ScriptContent, `n, `r
                {
                    line := A_LoopField
                    if (RegExMatch(line, "i)triggerMessage\s*=\s*""([^""]+)""", m)) {
                        origTrigger := m1
                        StringSplit, tParts, origTrigger, _
                        if (tParts0 == 2) {
                            reversedTrigger := tParts2 "_" tParts1
                            LBEX_Add(TrigBox, reversedTrigger)
                        } else {
                            LBEX_Add(TrigBox, origTrigger)
                        }
                    }
                }
                if (LBEX_GetCount(TrigBox) = 0) {
                    MsgBox, No trigger messages found in:`n%FullPath%
                }
            } else {
                MsgBox, VBScript file not found:`n%FullPath%
            }
            
            GuiControl,, SubFolderName, %SubFolder%
            GuiControl,, MultiTriggerName, %MultiTriggerName%
        } else {
            MsgBox, Invalid format for the selected multi-trigger. Expected "SubFolder_MultiTriggerName"
        }
    } else {
        MsgBox, Please select a multi-trigger script.
    }
    return
	
DeleteMultiTrigger:
    Gui, Submit, NoHide
    SelectedMultiTrigger := Trim(MultiTriggerList)
    if (SelectedMultiTrigger != "")
    {
        StringSplit, SelectedParts, SelectedMultiTrigger, _
        if (SelectedParts0 = 2)
        {
            SubFolder := RegExReplace(SelectedParts1, "^\s+|\s+$")
            MultiTriggerName := RegExReplace(SelectedParts2, "^\s+|\s+$")
            
            MultiTriggerPath := A_ScriptDir . "\" . SubFolder . "\" . MultiTriggerName . ".vbs"
            MultiSettingsPath := A_ScriptDir . "\" . SubFolder . "\" . MultiTriggerName . "_multisettings.ini"
            
            if (FileExist(MultiTriggerPath))
            {
                Loop, 2
                {
                    FileDelete, %MultiTriggerPath%
                    if !FileExist(MultiTriggerPath)
                        break
                    Sleep, 100
                }
            }
            
            if (FileExist(MultiSettingsPath))
            {
                Loop, 2
                {
                    FileDelete, %MultiSettingsPath%
                    if !FileExist(MultiSettingsPath)
                        break
                    Sleep, 100
                }
            }
            
            if (!FileExist(MultiTriggerPath) && !FileExist(MultiSettingsPath))
            {
                FolderPath := A_ScriptDir . "\" . SubFolder
                isEmpty := true
                Loop, Files, % FolderPath "\*"
                {
                    isEmpty := false
                    break  
                }
                if (isEmpty)
                {
                    FileRemoveDir, %FolderPath%
                }
            }
            else
            {
                MsgBox, 16, Error, Error: Unable to delete one or both files.`nCheck if the files are open or in use.
            }
            
            Sleep, 100

            gosub, MultiTriggerListINI

            Sleep, 100
    				
            Gosub, Clear
        }
    }
    else
    {
        MsgBox, 16, Error, Please select a MultiTrigger to delete.
    }
Return

Clear:
	GuiControl,, Intensity, 
	GuiControl,, Duration, 
	GuiControl,, SubFolderName
	GuiControl,, MultiTriggerName
	GuiControl,, TriggerList, |
	GuiControl,, MultiTriggerList, |
	GuiControl,, TriggerBox, |
	LoadTriggerList()
	LoadMultiTriggerList()
	Return

Select:
    GuiControlGet, SubFolderName
    GuiControlGet, MultiTriggerName

    ExpectedSelection := SubFolderName "_" MultiTriggerName  ; Match stored format

    GuiControl,, MultiTriggerList, |  ; Clear the ComboBox list
    LoadMultiTriggerList()  ; Reload the updated list

    ; Ensure exact selection
    SetTimer, SelectSavedMultiTrigger, -100
	
	gosub, ClearTrigger
Return

SelectSavedMultiTrigger:
    GuiControl, ChooseString, MultiTriggerList, %ExpectedSelection%
Return

ClearTrigger:
	GuiControl,, Intensity, 
	GuiControl,, Duration, 
	GuiControl,, TriggerList, |
	LoadTriggerList()
	Return
    
; ===========================
; :::::::: FUNCTIONS ::::::::
; =========================== 
LoadTriggerList() {
    IniRead, TactPatterns, ..\Triggers\TriggerList.ini, TactPatterns

    Loop, Parse, TactPatterns, `n
    {
        key := A_LoopField
        StringSplit, keyArray, key, =
        value := Trim(keyArray2)
        StringSplit, valueArray, value, _

        if (valueArray0 == 2)
            GuiControl, , TriggerList, % valueArray2 "_" valueArray1 "`n"
    }
    return
}

LoadMultiTriggerList() {
    FilePath := A_ScriptDir "\MultiTriggerList.ini"
	
	;FilePath := A_ScriptDir "\..\.repo\Bin\MultiTriggerList.ini"
		
    if !FileExist(FilePath) {
        MsgBox, % "INI file not found: " FilePath
        return
    }
    
    IniRead, MultiTrig, % FilePath, MultiTriggers

	/*
    if (MultiTrig = "ERROR" || MultiTrig = "") {
        MsgBox, "Failed to load MultiTriggers from INI."
        return
    }
	*/

    ; Parse the MultiTriggers list
    Loop, Parse, MultiTrig, `n, `r
    {
        if (A_LoopField = "")
            continue

        MultiTrigkeyArray := StrSplit(A_LoopField, "=")
        if (MultiTrigkeyArray.MaxIndex() < 2)
            continue

        MultiTrigValue := Trim(MultiTrigkeyArray[2])
        MultiTrigValueArray := StrSplit(MultiTrigValue, "_")

        if (MultiTrigValueArray.MaxIndex() == 2)
            GuiControl, , MultiTriggerList, % MultiTrigValueArray[2] "_" MultiTrigValueArray[1] "`n"
    }
}

WM_MOUSEMOVE()
{    
    static CurrControl := "", PrevControl := ""

    CurrControl := A_GuiControl
    
    if (CurrControl != PrevControl && CurrControl != "") 
    {
        SetTimer, DisplayToolTip, 200
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
        SetTimer, DisplayToolTip, Off
        if (%CurrControl%_TT) 
        {
            Gui, ToolTipGui: Destroy  
            Gui, ToolTipGui: +AlwaysOnTop +ToolWindow -Caption
            Gui, ToolTipGui: Margin, 10, 5
			Gui, ToolTipGui: Font, bold s10, Verdana
			Gui, ToolTipGui: Color, e9eade

            Gui, ToolTipGui: Add, Text,, % %CurrControl%_TT  
            
            CoordMode, Mouse, Screen
            MouseGetPos, xpos, ypos
            xpos += 10  
            ypos += 25  

            Gui, ToolTipGui: Show, x%xpos% y%ypos% NoActivate, ToolTip
        }
        SetTimer, RemoveToolTip, 2000
    return

    RemoveToolTip:
        SetTimer, RemoveToolTip, Off
        Gui, ToolTipGui: Destroy
    return
}

LBEX_Add(MultiTrigList, ByRef String) {
   Static LB_ADDSTRING := 0x0180
   SendMessage, % LB_ADDSTRING, 0, % &String,, % "ahk_id " . MultiTrigList
   Return (ErrorLevel + 1)
}

LBEX_Delete(MultiTrigList, Index) {
   Static LB_DELETESTRING := 0x0182
   SendMessage, % LB_DELETESTRING, % (Index - 1), 0, , % "ahk_id " . MultiTrigList
   Return ErrorLevel
}

LBEX_DeleteAll(MultiTrigList) {
   Static LB_RESETCONTENT := 0x0184
   SendMessage, % LB_RESETCONTENT, 0, 0, , % "ahk_id " . MultiTrigList
   Return True
}

LBEX_GetCount(MultiTrigList) {
   Static LB_GETCOUNT := 0x018B
   SendMessage, % LB_GETCOUNT, 0, 0, , % "ahk_id " . MultiTrigList
   Return ErrorLevel
}

LBEX_GetCurrentSel(MultiTrigList) {
   Static LB_GETCURSEL := 0x0188
   SendMessage, % LB_GETCURSEL, 0, 0, , % "ahk_id " . MultiTrigList
   Return (ErrorLevel + 1)
}

LBEX_GetText(MultiTrigList, Index) {
   Static LB_GETTEXT := 0x0189
   Len := LBEX_GetTextLen(MultiTrigList, Index)
   If (Len = -1)
      Return ""
   VarSetCapacity(Text, Len << !!A_IsUnicode, 0)
   SendMessage, % LB_GETTEXT, % (Index - 1), % &Text, , % "ahk_id " . MultiTrigList
   Return StrGet(&Text, Len)
}

LBEX_GetTextLen(MultiTrigList, Index) {
   Static LB_GETTEXTLEN := 0x018A
   SendMessage, % LB_GETTEXTLEN, % (Index - 1), 0, , % "ahk_id " . MultiTrigList
   Return ErrorLevel
}

CbAutoComplete(ControlName)
{
    ; Allow user to edit with Delete or Backspace without auto-completing.
    if (GetKeyState("Delete", "P") || GetKeyState("Backspace", "P"))
        return 0
    
    GuiControlGet, lHwnd, Hwnd, %ControlName%
    if (!lHwnd)
        return 0
    
    ; Get the current selection range.
    SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%  ; CB_GETEDITSEL
    MakeShort(ErrorLevel, Start, End)
    
    GuiControlGet, CurContent,, %lHwnd%
    ; Attempt auto-completion using the current text.
    GuiControl, ChooseString, %ControlName%, %CurContent%
    
    if (ErrorLevel) {
        ; No match found—restore text and selection.
        ControlSetText,, %CurContent%, ahk_id %lHwnd%
        PostMessage, 0x0142, 0, MakeLong(Start, End),, ahk_id %lHwnd%  ; CB_SETEDITSEL
        return 0
    }
    
    ; A match was found; update the selection.
    GuiControlGet, CurContent,, %lHwnd%
    PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
    
    return 1  ; Indicate a successful auto-completion.
}

MakeLong(LoWord, HiWord)
{
    return (HiWord << 16) | (LoWord & 0xffff)
}

MakeShort(Long, ByRef LoWord, ByRef HiWord)
{
    LoWord := Long & 0xffff
    HiWord := Long >> 16
}

CreateSolidBitmap(w, h, color) {
    hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", DllCall("GetDC", "UInt", 0, "Ptr"), "Int", w, "Int", h, "Ptr")
    obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm, "Ptr")
    brush := DllCall("CreateSolidBrush", "UInt", color, "Ptr")
    rect := VarSetCapacity(RECT, 16, 0), NumPut(w, RECT, 8, "Int"), NumPut(h, RECT, 12, "Int")
    DllCall("FillRect", "Ptr", hdc, "Ptr", &RECT, "Ptr", brush)
    DllCall("DeleteObject", "Ptr", brush)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", obm, "Ptr")
    DllCall("DeleteDC", "Ptr", hdc)
    return hbm
}

DeleteObject(hBM) {
    DllCall("DeleteObject", "Ptr", hBM)
}
