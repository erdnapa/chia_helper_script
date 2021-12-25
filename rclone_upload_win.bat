@echo off
SetLocal
SetLocal EnableDelayedExpansion
REM cd /D "%~dp0"

title Rclone Plot Uploader for Windows

if not exist "C:\Program Files (x86)\WinFsp\bin\winfsp-msil.dll" (
    echo "ERROR: Could not found winfsp-msil.dll in C:\Program Files (x86)\WinFsp\bin\"
    echo "Please install WinFsp!"
    goto :error_exit
)
set rclone_flags=-P --drive-chunk-size 512M
set local_disk=C:
set /p local_disk=" * Enter the local disk letter of your plots (default=%local_disk%): "
set plot_folder_list=Example_Plot_Folder1 Example_Plot_Folder2
set /p plot_folder_list=" * Enter your plot folders name (default=%plot_folder_list%): "
set rclone_path=%USERPROFILE%\rclone

set /p rclone_path=" * Enter your rclone path (default=%rclone_path%): "

if not exist %rclone_path%\rclone.exe (
    echo "ERROR: Could not found rclone.exe in %rclone_path%"
    goto :error_exit
)
if not exist %rclone_path%\rclone.conf (
    echo "ERROR: Could not found rclone.conf in %rclone_path%"
    goto :error_exit
)

:loop_gdrive
echo ^> rclone flags %rclone_flags%
for %%c in (%plot_folder_list%) do (
	mkdir %local_disk%\%%c >nul 2>&1
	cd /D %local_disk%\%%c >nul 2>&1
	for /f %%b in ('dir *.plot /b') do (
    	
		for /f "skip=1" %%a in ('wmic path win32_localtime get hour') do (
			set var=%%a >nul 2>&1
			set /a result=!var! / 1 >nul 2>&1
		)
		set remote_path=gdrive_service!result!
		echo [92m* !remote_path![0m
		echo ^> %local_disk%\%%c
       		%rclone_path%\rclone.exe --config="%rclone_path%\rclone.conf" move %local_disk%/%%c/%%b !remote_path!:%%c %rclone_flags%
	)
)

timeout -t 30 -nobreak > nul
cls
goto :loop_gdrive


:error_exit
pause
