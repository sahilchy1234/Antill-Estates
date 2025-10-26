@echo off
echo ================================
echo Image Optimization Script
echo ================================
echo.

REM Check if ImageMagick is installed
where magick >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ImageMagick not found!
    echo Please download and install from: https://imagemagick.org/script/download.php
    echo.
    echo Alternative: Use online tools like TinyPNG.com or Squoosh.app
    pause
    exit /b 1
)

echo Creating backup...
if not exist "assets_backup" mkdir assets_backup
xcopy /E /I /Y assets assets_backup\assets >nul

echo.
echo Optimizing images (this may take a while)...
echo.

REM Optimize images in assets/images
for /r "assets\images" %%f in (*.png) do (
    echo Optimizing: %%~nxf
    magick "%%f" -strip -quality 85 -define png:compression-filter=5 -define png:compression-level=9 "%%f"
)

REM Optimize and resize flags
for /r "assets\flags" %%f in (*.png) do (
    echo Optimizing flag: %%~nxf
    magick "%%f" -strip -quality 80 -resize 80x80^> -define png:compression-filter=5 -define png:compression-level=9 "%%f"
)

echo.
echo ================================
echo Optimization Complete!
echo ================================
echo Backup saved in: assets_backup\
echo.
echo To restore backup if needed:
echo   rmdir /s /q assets
echo   move assets_backup\assets assets
echo.
pause

