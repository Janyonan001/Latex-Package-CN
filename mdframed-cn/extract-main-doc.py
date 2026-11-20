# -*- coding: utf-8 -*-
r"""
把 mdframed.dtx 的文档描述部分展开为独立、自包含的 mdframed-doc.tex。

规则（依据 dtx 实际结构）：
- 导言：取自 driver 块（documentclass / 宏包 / surroundwithmdframed /
  EnableCrossrefs / CodelineIndex / OnlyDescription），不再 \DocInput dtx。
- 正文：245..1970 行（描述散文 + 示例清单）；
  1971 行起为修订历史 / Implementation / 实现代码 / 示例抽取块，整体剔除。
- docstrip 标签开关、%\iffalse / %\fi、StopEventually、注释掉的 RecordChanges
  等控制行不输出。
- 散文注释行去掉行首单个 '%'，其后内容（含缩进空格）原样保留。
- 裸行（tltxmdfexample 环境及其内部代码）原样保留。
"""

import re
from pathlib import Path

BASE = Path(r"C:\Users\JIN\Doubao\chats\2026-11-20\new-chat\mdframed-cn")
SRC = BASE / "mdframed.dtx"
DST = BASE / "mdframed-doc.tex"

# 有效正文行区间（1-based，含两端）
BODY_START = 245
BODY_END = 1970

# 整行丢弃的控制行
RE_TAG = re.compile(r"^\s*%<")                                   # docstrip 标签开关
RE_COND = re.compile(r"^\s*%\s*\\(iffalse|iftrue|fi)\b")        # docstrip 兼容条件
RE_STOP = re.compile(r"^\s*%\s*\\StopEventually")              # ltxdoc 收尾钩子
RE_RECORD = re.compile(r"^\s*%%?\s*\\RecordChanges")           # 注释掉的变更记录

# driver 导言（从 dtx 219-232、234-236 原样摘取）
PREAMBLE = r"""\setcounter{errorcontextlines}{999}
\documentclass[parskip=false,11pt,]{ltxmdf}
\usepackage{pdfpages}
\usepackage[framemethod=TikZ]{mdframed}
\usetikzlibrary{shadows}
\surroundwithmdframed[middlelinecolor=ltxmdfblue,middlelinewidth=1pt,%
                      roundcorner=10pt,innertopmargin=0pt,%
                      leftmargin=1cm,rightmargin=1cm,%
                      innerleftmargin=-15pt,innerrightmargin=-15pt,%
                      ignorelastdescenders,%
                      settings={\lstset{resetmargins}},%
                      skipbelow=\topskip,skipabove=\topskip,%
                      innerbottommargin=0pt,backgroundcolor=gray!10]%
                     {tltxmdfexample}

\EnableCrossrefs
\CodelineIndex
\OnlyDescription
\begin{document}
"""

lines = SRC.read_text(encoding="utf-8").splitlines()

out = [PREAMBLE]
body = []
dropped = 0

for idx, raw in enumerate(lines, start=1):
    if idx < BODY_START or idx > BODY_END:
        continue
    line = raw.rstrip("\n")

    if (RE_TAG.match(line) or RE_COND.match(line)
            or RE_STOP.match(line) or RE_RECORD.match(line)):
        dropped += 1
        continue

    stripped = line.lstrip()
    if stripped.startswith("%"):
        # 散文注释行：去掉第一个 '%'，保留其后的空格与内容
        # 找到第一个 '%' 的位置（含前导空白）
        pct = line.index("%")
        body.append(line[pct + 1:])
    else:
        # 裸行（示例环境 / 代码）原样保留
        body.append(line)

out.extend(body)
out.append("\n\\PrintIndex\n")
out.append("\\end{document}\n")

DST.write_text("\n".join(out), encoding="utf-8")
print(f"source lines scanned : {len(lines)}")
print(f"body lines kept      : {len(body)}")
print(f"control lines dropped: {dropped}")
print(f"written              : {DST}")
