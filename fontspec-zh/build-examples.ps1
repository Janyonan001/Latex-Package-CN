# 预编译 fontspec 文档中的示例，生成 standalone 示例 PDF。
# 用法：先跑一遍 xelatex 主文档生成 zzz-*.tex 源码，再执行本脚本，
#       最后再跑一遍主文档以引入示例 PDF。
$ErrorActionPreference = 'Continue'
Set-Location $PSScriptRoot

$wrap = @'
\documentclass[margin=0.2mm]{standalone}
\usepackage{booktabs,ifthen,graphicx,xcolor,varwidth}
\usepackage{fontspec}
\defaultfontfeatures{Ligatures=TeX}
\begin{document}
\begin{varwidth}{0.7\linewidth}
\input __SRC__
\end{varwidth}
\end{document}
'@

$src = Get-ChildItem -Filter 'zzz-*.tex' |
       Where-Object { $_.Name -notmatch '-(wrap|test)\.tex$' }

$ok = 0
$fail = @()

foreach ($f in $src) {
    $base = $f.BaseName
    $parts = $base -split '-'
    if ($parts[2] -eq 'X') { $eng = 'xelatex' } else { $eng = 'lualatex' }
    $wrapFile = "$base-wrap.tex"
    $body = $wrap -replace '__SRC__', $f.Name
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot $wrapFile), $body,
        (New-Object Text.UTF8Encoding($false)))

    $pdf = "$base.pdf"
    if (Test-Path $pdf) { Remove-Item $pdf -Force }

    & $eng -interaction=nonstopmode "-jobname=$base" $wrapFile 2>&1 |
        Out-File "$base-build.log" -Encoding utf8

    # 依赖缺失字体的示例会编译出近乎空白的 PDF；删除以便主文档回退到缺图提示。
    if ((Test-Path $pdf) -and ((Get-Item $pdf).Length -lt 1200)) {
        Remove-Item $pdf -Force
    }

    if (Test-Path $pdf) { $ok++ } else { $fail += $base }
}

Write-Output ("OK: {0} / {1}" -f $ok, $src.Count)
if ($fail.Count -gt 0) { Write-Output 'FAILED:'; $fail }
