@echo off
if "%1"=="--help" goto help
if "%1"=="clean" goto clean

where ponyc > nul
if errorlevel 1 goto noponyc

:build
set DEBUG=
if "%1"=="--debug" set DEBUG="--debug"
if not exist bin mkdir bin
echo Compiling stable...
ponyc stable -o bin %DEBUG%
goto done

:clean
echo Removing ./bin...
rmdir /s /q bin
goto done

:help
echo usage: make.bat [clean ^| --debug]
goto done

:noponyc
echo You need "ponyc.exe" (from https://github.com/ponylang/ponyc) in your PATH.
goto done

:done
