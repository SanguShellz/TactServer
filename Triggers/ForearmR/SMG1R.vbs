Dim pythonExecutable, pythonScript, triggerMessage, intensity, duration
Dim objShell, objFSO, objINIFile, strLine

' Define paths
pythonExecutable = "..\..\.repo\Python\python.exe"
pythonScript = "..\..\.repo\Python\TactClient.py"
iniFilePath = "SMG1R_settings.ini"

' Read intensity and duration from INI file
Set objFSO = CreateObject("Scripting.FileSystemObject")

If objFSO.FileExists(iniFilePath) Then
    Set objINIFile = objFSO.OpenTextFile(iniFilePath, 1)
    Do Until objINIFile.AtEndOfStream
        strLine = objINIFile.ReadLine
        If InStr(LCase(strLine), "intensity") > 0 Then
            intensity = Split(strLine, "=")(1)
            intensity = Trim(intensity)
        End If
        If InStr(LCase(strLine), "duration") > 0 Then
            duration = Split(strLine, "=")(1)
            duration = Trim(duration)
        End If
    Loop
    objINIFile.Close
Else
    intensity = "0.6" ' Default value if file is missing
    duration = "1.0" ' Default value if file is missing
End If

' Construct trigger message
triggerMessage = "SMG1R_ForearmR_" & intensity & "_" & duration

' Run Python script
Set objShell = CreateObject("WScript.Shell")
objShell.Run "" & pythonExecutable & " " & pythonScript & " " & triggerMessage & "", 0, True
Set objShell = Nothing