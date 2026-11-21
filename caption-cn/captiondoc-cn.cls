%%
%% captiondoc-cn.cls —— caption 文档（中文译本）使用的文档类
%% 基于原 captiondoc.cls，接入 ctex 中文排版支持。
%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{captiondoc-cn}[2026/11/21 中文译本文档类]

\hbadness=9999 \newcount\hbadness \hfuzz=100pt % 让 TeX 保持安静。

\PassOptionsToPackage{breaklinks=true}{hyperref}

% 先加载基础文档类（完成字号等初始化），再接入中文排版内核
\LoadClassWithOptions{ltxdoc}
\PassOptionsToPackage{UTF8,fontset=windows}{ctex}
\RequirePackage{ctex}
\setlength\parindent{0pt}
\setlength\parskip{\smallskipamount}
\addtolength\marginparwidth{15pt}
\setlength\leftmargini{2em}% 默认 = 2.5em

\renewcommand\partname{部分}

\RequirePackage{ifpdf}
\ifpdf
  \RequirePackage{mathptmx,courier}
  \RequirePackage[scaled=0.90]{helvet}
\fi

\RequirePackage{hypdoc}
\ifpdf\RequirePackage{hypdestopt}\fi
\hypersetup{pdfstartpage={},pdfstartview={}}
\hypersetup{breaklinks=true}
\let\subsectionautorefname\sectionautorefname
\let\subsubsectionautorefname\sectionautorefname

\DeclareRobustCommand*\eTeX{\leavevmode\hbox{$\varepsilon$}-\TeX}

\DeclareRobustCommand*\AmS{\texorpdfstring
  {{\protect\usefont{OMS}{cmsy}{m}{n}A\kern-.1667em\lower.5ex\hbox{M}\kern-.125emS}}%
  {AMS}}
\DeclareRobustCommand*\KOMAScript{\textsf{K\kern.05em O\kern.05em M\kern.05em A\kern.1em-\kern.1em Script}}
\DeclareRobustCommand*\NTG{NTG}
\DeclareRobustCommand*\SmF{SMF}

\newcommand*\NEWfeature{\NEW{新特性}}
\newcommand*\NEWdescription{\NEW{新说明}}
\newcommand*\NEW[1]{\@ifstar{\@NEW{#1}{\vskip2pt}}{\@NEW{#1}{}}}
\newcommand*\@NEW[3]{\MARGINSYM{#2\footnotesize#1\\#3}}
\newcommand*\MARGINSYM[1]{\hskip 1sp \marginpar{\raggedleft\textcolor{blue}{{#1}}}}

\newcommand*\LineBreak{\linebreak[3]}
\newcommand*\PageBreak{\pagebreak[3]}

\makeatletter
\newcommand*\longref{\@ifstar{\@longref\ref}{\@longref\autoref}}
\newcommand*\Longref{\@ifstar{\@longref\Ref}{\@longref\Autoref}}
\def\@longref#1#2{#1{#2}: \textit{\nameref{#2}}}
\makeatother

\newcommand*\See[1]{\nopagebreak{\small （参见 #1）}}
\renewcommand*\sectionautorefname{小节}
\renewcommand*\subsectionautorefname{小节}
\renewcommand*\subsubsectionautorefname{小节}

% 修复中文目录中编号与标题之间缺失的空格（如 F.21.10longtable）
\makeatletter
\let\captioncn@orig@l@subsubsection\l@subsubsection
\renewcommand\l@subsubsection[2]{%
  \captioncn@orig@l@subsubsection{\numberline{#1\,\,}}{#2}}
\makeatother

\newenvironment{Options}[1]%
  {\list{}{\renewcommand\makelabel[1]{\texttt{##1}\hfil}%
   \settowidth\labelwidth{\texttt{#1\space}}%
   \setlength\leftmargin{10pt}%
   \addtolength\leftmargin{\labelwidth}%
   \addtolength\leftmargin{\labelsep}}}%
  {\endlist}

\newcommand*\purerm[1]{{\upshape\mdseries\rmfamily #1}}
\newcommand*\puresf[1]{{\upshape\mdseries\sffamily #1}}
\newcommand*\purett[1]{{\upshape\mdseries\ttfamily #1}}
\let\cls\puresf \let\pkg\puresf
\let\env\purett \let\opt\purett

\newcommand*\csmarg[1]{\texttt{\char`\{#1\char`\}}}
\newcommand*\csoarg[1]{\texttt{\char`\[#1\char`\]}}
\newcommand*\issue[2][GitLab]{#1 议题~\##2}
\newcommand*\version[2][]{v$#2$}
\newcommand*\changenote[1]{}

\RequirePackage{marvosym}
\makeatletter
\newcommand*\INFO{\@ifstar{\@INFO{}}{\@INFO{\vbox to \ht\strutbox}}}
\newcommand*\@INFO[1]{\MARGINSYM{#1{\LARGE\Info}}}
\makeatother

\RequirePackage[alpine]{ifsym}
\newenvironment{background}{\par\bigskip\csname background*\endcsname}{\csname endbackground*\endcsname}
\newenvironment{background*}{\small\MARGINSYM{\Mountain}\ignorespaces}{\par}

\RequirePackage[bottom]{footmisc}

% 中文文档术语重定义（供驱动头与正文使用）
\providecommand*\DefaultNoteText{注}
\renewcommand*\listfigurename{插图列表}
\renewcommand*\listtablename{表格列表}
\renewcommand*\abstractname{摘要}

\endinput
