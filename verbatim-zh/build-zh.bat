@echo off
setlocal
cd /d "%~dp0"

set "PATH=C:\texlive\2026\bin\windows;%SystemRoot%\System32;%SystemRoot%;%PATH%"
set "SRC=verbatim-zh.dtx"
set "BASE=verbatim-zh"

echo ============================================
echo  Compiling %SRC% with XeLaTeX
echo ============================================

echo.
echo [1/3] First pass...
xelatex -interaction=nonstopmode %SRC% >nul 2>&1
if errorlevel 1 (
  echo !! First pass failed. See %BASE%.log
  exit /b 1
)

echo [2/3] Second pass (resolve cross-references)...
xelatex -interaction=nonstopmode %SRC% >nul 2>&1
if errorlevel 1 (
  echo !! Second pass failed. See %BASE%.log
  exit /b 1
)

echo [3/3] Third pass (resolve bookmarks/outline)...
xelatex -interaction=nonstopmode %SRC% >nul 2>&1

echo.
echo ============================================
echo  Checking for LaTeX errors (lines starting with !):
echo ============================================
"%SystemRoot%\System32\findstr.exe" /B /C:"! " %BASE%.log
if errorlevel 1 (
  echo  OK - no fatal errors found.
) else (
  echo  ^^ Errors above - inspect %BASE%.log
)

echo.
echo ============================================
echo  Output PDF:
echo ============================================
dir /b "%BASE%.pdf"
endlocal