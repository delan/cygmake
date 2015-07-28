' This script runs irssi.cmd invisibly, so that the mintty window appears by itself (with no cmd window.)
Set WshShell = CreateObject("WScript.Shell") 
WshShell.currentDirectory = Replace(WScript.ScriptFullName, WScript.ScriptName, "")
WshShell.Run chr(34) & "irssi.cmd" & Chr(34), 0
Set WshShell = Nothing