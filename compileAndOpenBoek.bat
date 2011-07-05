@echo off
cd C:\Users\Simon Buelens\Documents\Unief\2de master\thesis\boek\
IF "%~1"=="" (
	set "var=boek"
	GOTO compile
) ELSE (
	echo Searching for %1
		if EXIST "%~1.tex" (
			echo Creating wrapper for %1 called "%1 full.tex"
			set "file=%~1 full.tex"
			echo Writing to "%file%"
			type create_full_begin.txt> "%file%"
			echo \include{%~1}>>"%file%"
			echo \backmatter>>"%file%"
			echo \end{document}>>"%file%"
			set "var=%~1 full"
			GOTO compile
		)	ELSE (
			echo Could not find %1
		)
)
GOTO finish
:compile
echo Closing acrobat reader if open
taskkill /f /im acro* 2>NUL
echo Compiling "%var%"
xelatex "%var%.tex" --quiet
echo Opening new pdf
start acrord32.exe %var%.pdf
:finish
cd %HOMEPATH%