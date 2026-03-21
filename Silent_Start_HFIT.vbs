Set WshShell = CreateObject("WScript.Shell")
batPath = "C:\HFIT_CampusLogin_Tools\CampusLogin_Supplement.bat"
WshShell.Run chr(34) & batPath & chr(34), 0, False
Set WshShell = Nothing
