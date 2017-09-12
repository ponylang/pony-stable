@echo off

if "%1"=="--help" goto help

set CONFIG=release
set DEBUG=
if "%1"=="config" (
  if "%2"=="debug" (
    set CONFIG=debug
    set DEBUG=--debug
  )
)
set BUILDDIR=build\%CONFIG%

if "%1"=="clean" goto clean

where ponyc > nul
if errorlevel 1 goto noponyc

:build
if not exist "%BUILDDIR%" mkdir "%BUILDDIR%""
echo Compiling: ponyc stable -o %BUILDDIR% %DEBUG%
ponyc stable -o %BUILDDIR% %DEBUG%
goto done

:clean
if not exist build goto done
echo Removing build
rmdir /s /q build
goto done

:help
echo usage: make.bat [clean] [config=release|debug]
goto done

:noponyc
echo You need "ponyc.exe" (from https://github.com/ponylang/ponyc) in your PATH.
goto done

:done
