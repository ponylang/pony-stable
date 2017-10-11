@echo off

if "%1"=="--help" goto help
if "%1"=="help" goto help

set GOTOCLEAN=false
if "%1"=="clean" (
  set GOTOCLEAN=true
  shift
)

set CONFIG=release
set DEBUG=
if "%1"=="config" (
  if "%2"=="debug" (
    set CONFIG=debug
    set DEBUG=--debug
  )
)

set BUILDDIR=build\%CONFIG%
if "%GOTOCLEAN%"=="true" goto clean

where ponyc > nul
if errorlevel 1 goto noponyc

:build
if not exist "%BUILDDIR%" mkdir "%BUILDDIR%""
echo Compiling: ponyc stable -o %BUILDDIR% %DEBUG%
set /p VERSION=<VERSION
if exist ".git" for /f %%i in ('git rev-parse --short HEAD') do set "VERSION=%VERSION%-%%i [%CONFIG%]"
if not exist ".git" set "VERSION=%VERSION% [%CONFIG%]"
setlocal enableextensions disabledelayedexpansion
for /f "delims=" %%i in ('type stable\version.pony.in ^& break ^> stable\version.pony') do (
  set "line=%%i"
  setlocal enabledelayedexpansion
  >>stable\version.pony echo(!line:%%%%VERSION%%%%=%VERSION%!
  endlocal
)
ponyc stable -o %BUILDDIR% %DEBUG%
goto done

:clean
if not exist "%BUILDDIR%" goto done
echo Removing "%BUILDDIR%"
rmdir /s /q "%BUILDDIR%"
goto done

:help
echo usage: make.bat [clean] [config=release|debug]
goto done

:noponyc
echo You need "ponyc.exe" (from https://github.com/ponylang/ponyc) in your PATH.
goto done

:done
