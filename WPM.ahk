#NoEnv
#SingleInstance force
SetBatchLines -1
; Following values can be customized. Default values are recommended.
custom_min := 1
custom_wordcount := 5

Gui, font, w600 q5 s11
Gui, add, text, vTxt w500 Center, Hit Enter to begin; Escape to quit.
Gui, font, 
Gui, add, edit, vinp  w500 Center
Gui, add, text, verror_placeholder w50 cRed section, Errors:
Gui, add, text, vpoints_placeholder w50 xp x250 cGreen, Points:
Gui, add, text, vtime_placeholder xp+200, Time left:
Gui, add, text, vmistakes w50 cRed xs, 0
Gui, add, text, vpoints w50 cGreen xp x250, 0
Gui, add, text, vtime_sec xp+200 w50, % timer_in_secs := custom_min*60
Gui, -Caption +ToolWindow +LastFound

FetchWordList()
Gui, show, Center Autosize
points := mistakes := 0
Loop
{
	Input, tempvar, L1, {Enter}{Escape}
	if(Errorlevel == "EndKey:Enter")
		break
	else if(Errorlevel == "EndKey:Escape")
		ExitApp
}
gosub, Start
return

FetchWordList()
{
	global
		FileRead, wordlist, % A_ScriptDir "\wordlist.txt"
		if(ErrorLevel)
		{
			Msgbox Unable to load the wordlist or file not found.
			ExitApp
		}
		StringReplace, wordlist, wordlist, `r, %A_Space%, A
		StringSplit, wordlist, wordlist, `n
}

Stringify(words=1)
{
	global
	tempstr := ""
	Loop %words%
	{
		Random, ran, 1, %wordlist0%
		tempstr .= wordlist%ran%
	}
	return tempstr
}

ShowStats()
{
	global
	GrossWPM := ((mistakes + points) / 5) / custom_min
	NetWPM := GrossWPM - (mistakes / custom_min)
	Accuracy := (points / (points + mistakes)) * 100
	Msgbox % "`t" "Stats:`nGross WPM : " Round(GrossWPM, 2) "`nNet WPM : " Round(NetWPM, 2) "`nAccuracy : " Round(Accuracy, 2) "%"
}

Parser(string1, string2)
{
	global 
	Loop, parse, % string1
	{
		if(A_Loopfield == SubStr(string2, A_Index, 1))
		{
			points++
			GuiControl, Text, points, %points%
		}
		else
		{
			mistakes++
			GuiControl, Text, mistakes, %mistakes%
		}
	}
	
}
Start:
SetTimer, CountdownTimer, 1000
Loop
{
	temp := Stringify(custom_wordcount)
	len := strlen(temp)
	GuiControl, Text, Txt, %temp%
	Input, ov, V L%len%) T%timer_in_secs%
	if(strlen(temp) == strlen(ov))
		Parser(temp, ov)
	else
	{
		Parser(ov, temp)
		break
	}
	GuiControl, Text, inp, 
}
GuiControl, Text, Txt, Aww, you ran out of time!
GuiControl, Text, inp,
GuiControl, Disable, inp
ShowStats()
return

CountdownTimer:
	if(!timer_in_secs)
		SetTimer, CountdownTimer, Off
GuiControl, Text, time_sec, % timer_in_secs--
return

GuiEscape:
ExitApp
