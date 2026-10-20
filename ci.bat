@echo off
setlocal

cargo build --release
if errorlevel 1 exit /b %errorlevel%

cargo test
if errorlevel 1 exit /b %errorlevel%

exit /b 0
