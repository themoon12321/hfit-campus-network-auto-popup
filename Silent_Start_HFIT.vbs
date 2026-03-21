Set WshShell = CreateObject("WScript.Shell")
' 这里的路径要和你实际的文件夹名完全一致
batPath = "C:\HFIT_CampusLogin_Tools\CampusLogin_Supplement.bat"
' 用双引号包裹路径，解决空格问题
WshShell.Run chr(34) & batPath & chr(34), 0, False
Set WshShell = Nothing