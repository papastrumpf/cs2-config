@echo off
rem Double-click to install the CS2 config (runs install.ps1). Close CS2 first.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause
