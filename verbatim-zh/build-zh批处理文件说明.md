## `build-zh.bat` 逐行详解

### 头部环境设置

```bat
@echo off
```
关闭命令回显——否则每一行命令本身都会打印到屏幕上，刷屏。

```bat
setlocal
```
启动局部环境块。本 bat 里 `set PATH=...`、`set SRC=...` 等改动只影响本 bat 运行期间，结束后自动还原，不污染系统环境变量。

```bat
cd /d "%~dp0"
```
切到 bat 文件**自身所在目录**。
- `%~dp0` 是 bat 内置变量，展开为 bat 文件所在的盘符+路径（末尾带反斜杠）。
- `/d` 参数表示跨盘符切换（比如 bat 在 D 盘而当前在 C 盘也能切过去）。
- 这样无论用户从哪里双击/调用这个 bat，都能在正确目录下编译。

```bat
set "PATH=C:\texlive\2026\bin\windows;%SystemRoot%\System32;%SystemRoot%;%PATH%"
```
重写 PATH，把三个目录**前置**：
1. `C:\texlive\2026\bin\windows` — xelatex.exe 所在目录（关键，否则找不到 xelatex）
2. `%SystemRoot%\System32` — chcp、findstr、cmd 内部命令依赖的目录
3. `%SystemRoot%` — 系统根目录
4. `%PATH%` — 保留原有 PATH

用 `set "VAR=value"`（带引号）的写法是为了避免末尾空格被误吞。

```bat
set "SRC=verbatim-zh.dtx"
set "BASE=verbatim-zh"
```
两个变量：
- `SRC` = 要编译的 dtx 文件名
- `BASE` = 去掉扩展名后的基名，用于拼 `.log`、`.pdf` 等产物名

> 以后换文件只需改这两行。

---

### 三遍编译

```bat
echo [1/3] First pass...
xelatex -interaction=nonstopmode %SRC% >nul 2>&1
```
- `-interaction=nonstopmode`：遇到错误不暂停等用户输入，直接继续（适合批处理）。
- `>nul 2>&1`：把 stdout 和 stderr 都重定向到 `nul`（丢弃），屏幕上不刷编译日志。错误信息仍在 `.log` 文件里。
- 第一遍：建立 `.aux` 交叉引用文件，此时目录/页码可能不准。

```bat
if errorlevel 1 (
  echo !! First pass failed. See %BASE%.log
  exit /b 1
)
```
检查上一条命令的退出码。`if errorlevel 1` 表示"退出码 ≥ 1"（即失败）。失败就提示并 `exit /b 1` 退出本 bat（不关闭父 cmd 窗口）。

第二遍同理——读第一遍写的 `.aux`，把交叉引用、目录、页码填对。

第三遍（第 28–29 行）**不检查退出码**，因为 hyperref/rerunfilecheck 有时会要求"再跑一遍稳定 PDF 书签"，即使前两遍已收敛，第三遍也无害；即使这一遍有非致命警告也不报错退出。

> 为什么不直接跑两遍？因为 ltxdoc + hyperref 在本文档上会提示 "File verbatim-zh.out has changed. Rerun to get outlines right"，第三遍消除这个警告。

---

### 错误扫描

```bat
"%SystemRoot%\System32\findstr.exe" /B /C:"! " %BASE%.log
```
用 `findstr` 在日志里找**以 `! ` 开头的行**——这是 LaTeX 致命错误的标志（每个错误都以 `! Error text` 开头）。
- `/B`：只匹配行首
- `/C:"! "`：把 `"! "` 当作字面字符串（含空格），不当成正则
- 用完整路径 `"%SystemRoot%\System32\findstr.exe"` 是为了避免某些精简环境下 PATH 里没有 System32（之前测试时踩过这个坑）。

```bat
if errorlevel 1 (
  echo  OK - no fatal errors found.
) else (
  echo  ^^ Errors above - inspect %BASE%.log
)
```
`findstr` 找到匹配时退出码为 0，找不到时为 1。所以这里逻辑反着读：
- `errorlevel 1`（findstr 没找到）→ "OK"
- `else`（找到了错误行）→ 提示去看日志

---

### 收尾

```bat
dir /b "%BASE%.pdf"
```
用 `/b`（bare 模式）只列文件名不列大小日期，确认 PDF 已生成。

```bat
endlocal
```
与第 2 行 `setlocal` 配对，结束局部环境块（其实 bat 退出时自动恢复，显式写更规范）。

---

### 典型运行输出

```
============================================
 Compiling verbatim-zh.dtx with XeLaTeX
============================================

[1/3] First pass...
[2/3] Second pass (resolve cross-references)...
[3/3] Third pass (resolve bookmarks/outline)...

============================================
 Checking for LaTeX errors (lines starting with !):
============================================
 OK - no fatal errors found.

============================================
 Output PDF:
============================================
verbatim-zh.pdf
```

如果第一遍失败（比如 dtx 里打错字），会立即打印 `!! First pass failed. See verbatim-zh.log` 并退出，不浪费时间跑后面两遍。