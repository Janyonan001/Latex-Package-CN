@echo off
cd /d "D:\GItHub\Latex-Package-CN\tcolorbox"

echo === Pass 1: xelatex ===
xelatex -shell-escape -interaction=nonstopmode tcolorbox.tex

echo === biber ===
biber tcolorbox

echo === Pass 2: xelatex ===
xelatex -shell-escape -interaction=nonstopmode tcolorbox.tex

echo === Pass 3: xelatex ===
xelatex -shell-escape -interaction=nonstopmode tcolorbox.tex

echo === makeindex ===
makeindex tcolorbox.idx

echo === Pass 4: xelatex ===
xelatex -shell-escape -interaction=nonstopmode tcolorbox.tex

echo === Pass 5: xelatex ===
xelatex -shell-escape -interaction=nonstopmode tcolorbox.tex

echo.
echo === Done! Output: tcolorbox.pdf ===
pause
