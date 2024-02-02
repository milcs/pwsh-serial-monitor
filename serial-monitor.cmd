@echo off
setlocal
::Running serial monitor

powershell.exe -ExecutionPolicy Bypass -File serial-monitor.ps1
:: Should you have a newver version of powershell you might want to switch to pwsh
::pwsh -ExecutionPolicy Bypass -File serial-monitor.ps1

endlocal
pause
exit



