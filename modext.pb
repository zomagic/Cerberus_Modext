OpenConsole()
EnableGraphicalConsole(1)
ConsoleCursor(0)
UseZipPacker()

ConsoleTitle ("ModExt")  
PrintN ("Cerberus - Modules External Download")
If InitNetwork() = 0
  PrintN ("Can't initialize the network !")
  End
EndIf
Global binPath$ = GetPathPart(ProgramFilename())
Global modules_extPath$ = Left(binPath$,Len(binPath$)-4)+"modules_ext\"
Global ConsoleY=0
Procedure Download(addr$,name$="")
	If name$=""
		replacename$=""
		name$ = StringField(addr$,CountString(addr$,"/")+1, "/")
	Else
		replacename$ = StringField(addr$,CountString(addr$,"/")+1, "/")
	EndIf
	Print ("Process: "+name$)
	ConsoleY=ConsoleY+1
	progressState=0
 	Download = ReceiveHTTPFile(addr$+"/archive/master.zip", modules_extPath$+name$+".zip",#PB_HTTP_Asynchronous)
 	If Download
 	    Repeat
 			Progress = HTTPProgress(Download)
 			Select Progress
 			Case #PB_Http_Success
 				ConsoleLocate(Len(name$)+10,ConsoleY)		
 				Print("- uncompress")
 				CreateDirectory(modules_extPath$+name$)
 				If OpenPack(0,modules_extPath$+name$+".zip") 
					; List all the entries
					If ExaminePack(0)
						While NextPackEntry(0)
							If PackEntryType(0)=#PB_Packer_Directory
								filename$=modules_extPath$+PackEntryName(0)
								filename$=ReplaceString(filename$,"-master","")
								If replacename$<>""
									filename$=ReplaceString(filename$,replacename$,name$)
								EndIf
								filename$=ReplaceString(filename$,"/","\")
								CreateDirectory(filename$)
							Else
								filename$=modules_extPath$+PackEntryName(0)
								filename$=ReplaceString(filename$,"-master","")
								If replacename$<>""
									filename$=ReplaceString(filename$,replacename$,name$)
								EndIf
								filename$=ReplaceString(filename$,"/","\")
								UncompressPackFile(0, filename$)
							EndIf
						Wend
					EndIf
					ClosePack(0)
					ConsoleLocate(Len(name$)+10,ConsoleY)		
					PrintN("- done      ")
					DeleteFile(modules_extPath$+name$+".zip")
				EndIf
 				ProcedureReturn 
 			Case #PB_Http_Failed
 				ConsoleLocate(Len(name$)+10,ConsoleY)
 				PrintN ("- download failed")
 				ProcedureReturn 
 			Case #PB_Http_Aborted
 				ConsoleLocate(Len(name$)+10,ConsoleY)
 				PrintN ("- download aborted")
 				ProcedureReturn 
 			Default
 				ConsoleLocate(Len(name$)+10,ConsoleY)
 				progressState=progressState+1
 				If progressState>4 
 					progressState=1
 				EndIf
 				Print ("- download ")
 				Select progressState
 				Case 1
 					Print ("|")
 				Case 2
 					Print ("/")
 				Case 3
 					Print ("-")
 				Case 4
 					Print ("\")
 				EndSelect
 			EndSelect
 			Delay(500) ; Don't stole the whole CPU
 		ForEver
 		
 	Else
 		PrintN ("Download error")	
 	EndIf
EndProcedure

file=ReadFile(#PB_Any, binPath$+"modext.txt",#PB_UTF8)
If file<>0
	Repeat
		dat$=ReadString(file)
		instruction$=UCase(StringField(dat$,1,"="))
		dat$=StringField(dat$,2,"=")
		Select instruction$
			Case "DOWNLOAD"
				If FindString(dat$,",")<>0
					name$=StringField(dat$,2,",")
					If FindString(name$,Chr(34))<>0
						name$=ReplaceString(name$,Chr(34),"")	
					EndIf
					dat$=StringField(dat$,1,",")
					If FindString(dat$,Chr(34))<>0
						dat$=ReplaceString(dat$,Chr(34),"")	
					EndIf
					Download(dat$,name$)
				Else
					If FindString(dat$,Chr(34))<>0
						dat$=ReplaceString(dat$,Chr(34),"")	
					EndIf
					Download(dat$)
				EndIf
			Case "COPY"
				from$=StringField(dat$,1,",")
				If FindString(from$,Chr(34))<>0
					from$=ReplaceString(from$,Chr(34),"")	
				EndIf
				into$=StringField(dat$,2,",")
				If FindString(into$,Chr(34))<>0
					into$=ReplaceString(into$,Chr(34),"")	
				EndIf
				CopyDirectory(modules_extPath$+from$,modules_extPath$+into$,"",#PB_FileSystem_Recursive)
				DeleteDirectory(modules_extPath$+from$,"",#PB_FileSystem_Recursive)
		EndSelect
	Until Eof(file)
	CloseFile(file)	
EndIf
PrintN("Process Completed")
Delay(2000)
CloseConsole()


; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 3
; Folding = +
; EnableUnicode
; EnableXP
; Executable = modext.exe
; CompileSourceDirectory