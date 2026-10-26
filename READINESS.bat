@echo off
chcp 65001 > nul
powershell -ExecutionPolicy Bypass -File "%~dp0READINESS.ps1"
pause
