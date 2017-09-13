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
