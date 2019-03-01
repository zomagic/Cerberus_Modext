OpenConsole()
UseZipPacker()
ConsoleTitle ("ModExt")  
PrintN ("Cerberus - Modules External Download")
If InitNetwork() = 0
  PrintN ("Can't initialize the network !")
  End
EndIf
Global binPath$ = GetPathPart(ProgramFilename())
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	Global SL$="/"
CompilerElse
	Global SL$="\"
CompilerEndIf
;---------READING COMMANDLINE
Global NewList update.s()
Global ModuleFolder$="modules_ext"
cline$=ProgramParameter()
While cline$<>""
	cmd$=Trim(UCase(StringField(cline$,1,"=")))
	opt$=Trim(StringField(cline$,2,"="))
	Select cmd$
		Case "-UPDATE"
			If opt$=""
				AddElement(update())
				update()="ALL"
			Else
				For k = 1 To CountString(opt$,",")+1
					folder$ = StringField(opt$, k, ",")
					AddElement(update())
					update()=folder$
				Next
			EndIf
		Case "-INTO"
			If opt$	<> ""
				ModuleFolder$=opt$
			EndIf
	EndSelect
	
	cline$=ProgramParameter()
Wend
Global modules_extPath$ = Left(binPath$,Len(binPath$)-4)+ModuleFolder$+SL$
If FileSize(modules_extPath$)<>-2
	CreateDirectory(modules_extPath$)
EndIf
Global lastDownload$=""
Procedure Download(addr$,name$="",replace=0)
	If name$="":name$ = StringField(addr$,CountString(addr$,"/")+1, "/"):EndIf
	Print ("Process: "+name$)
	If replace=0
		If FileSize(modules_extPath$+name$)=-2 ;check folder exist?
			needupdate=0
			ForEach update() 
				If update()=name$ Or update()="ALL"
					needupdate=1
				EndIf
			Next
			If needupdate=0
				PrintN (" - skip!")
				ProcedureReturn 
			EndIf
		EndIf
	EndIf
	Print (" - download .")
	progressState=0
	If FindString(addr$,"github.com")<>0
		If Right(addr$,4)<>".zip"
			Download = ReceiveHTTPFile(addr$+"/archive/master.zip", modules_extPath$+name$+".zip",#PB_HTTP_Asynchronous)
		Else
			Download = ReceiveHTTPFile(addr$,modules_extPath$+name$+".zip",#PB_HTTP_Asynchronous)
		EndIf
	Else
		Download = ReceiveHTTPFile(addr$,modules_extPath$+name$+".zip",#PB_HTTP_Asynchronous)
	EndIf
	If Download
		lastDownload$=name$
 	    Repeat
 			Progress = HTTPProgress(Download)
 			Select Progress
 			Case #PB_Http_Success	
 				Print(" uncompress")
 				CreateDirectory(modules_extPath$+name$)
 				If OpenPack(0,modules_extPath$+name$+".zip") 
					If ExaminePack(0)
						While NextPackEntry(0)
							If PackEntryType(0)=#PB_Packer_Directory
								filename$=modules_extPath$+PackEntryName(0)
								pos=FindString(PackEntryName(0),"/")
								If pos>0
									;find the name of first folder to be rename
									replacename$=Left(PackEntryName(0),pos-1)
									filename$=ReplaceString(filename$,replacename$,name$)
								EndIf
								CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
									filename$=ReplaceString(filename$,"\","/")
								CompilerElse
									filename$=ReplaceString(filename$,"/","\")
								CompilerEndIf
								;Debug filename$
								CreateDirectory(filename$)
							Else
								filename$=modules_extPath$+PackEntryName(0)
								pos=FindString(PackEntryName(0),"/")
								If pos>0
									;find the name of first folder to be rename
									replacename$=Left(PackEntryName(0),pos-1)
									filename$=ReplaceString(filename$,replacename$,name$)
								EndIf
								CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
									filename$=ReplaceString(filename$,"\","/")
								CompilerElse
									filename$=ReplaceString(filename$,"/","\")
								CompilerEndIf
								;Debug filename$
								UncompressPackFile(0, filename$)
							EndIf
						Wend
					EndIf
					ClosePack(0)		
					PrintN(" - done")
					DeleteFile(modules_extPath$+name$+".zip")
				EndIf
 				ProcedureReturn 
 			Case #PB_Http_Failed
 				PrintN (" - download failed")
 				ProcedureReturn 
 			Case #PB_Http_Aborted
 				PrintN (" - download aborted")
 				ProcedureReturn 
 			Default
 				progressState=progressState+1
 				If progressState=1:Print ("."):EndIf
 				If progressState>5:progressState=0:EndIf
 			EndSelect
 			Delay(500) ; Don't stole the whole CPU
 		ForEver
 	Else
 		PrintN ("Download error")	
 	EndIf
 EndProcedure
;---------READING INPUT
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	file=ReadFile(#PB_Any, binPath$+"modext.macos.txt",#PB_UTF8)
CompilerElse
	file=ReadFile(#PB_Any, binPath$+"modext.winnt.txt",#PB_UTF8)
CompilerEndIf
If file<>0
	Repeat
		dat$=ReadString(file)	
		dat$=StringField(dat$,1,"'") ;eliminate rem
		dat$=ReplaceString(dat$,Chr(9),"")
		instruction$=Trim(UCase(StringField(dat$,1,"="))) ;get instruction
		replace=0
		If FindString(instruction$,"!")<>0
			instruction$=Trim(ReplaceString(instruction$,"!",""))
			replace=1
		EndIf
		dat$=Trim(StringField(dat$,2,"=")) ;get parameter
		Select instruction$
			Case "DOWNLOAD"
				If FindString(dat$,",")<>0
					;spacify the name
					name$=StringField(dat$,2,",")
					If FindString(name$,Chr(34))<>0
						name$=ReplaceString(name$,Chr(34),"")	
					EndIf
					dat$=StringField(dat$,1,",")
					If FindString(dat$,Chr(34))<>0
						dat$=ReplaceString(dat$,Chr(34),"")	
					EndIf
					Download(Trim(dat$),Trim(name$),replace)
				Else
					;not spacify the name
					If FindString(dat$,Chr(34))<>0
						dat$=ReplaceString(dat$,Chr(34),"")	
					EndIf
					Download(Trim(dat$),"",replace)
				EndIf
			Case "COPY"
				from$=StringField(dat$,1,",")
				If FindString(from$,Chr(34))<>0
					from$=ReplaceString(from$,Chr(34),"")	
				EndIf
				from$=Trim(from$)+SL$
				into$=StringField(dat$,2,",")
				If FindString(into$,Chr(34))<>0
					into$=ReplaceString(into$,Chr(34),"")	
				EndIf
				into$=Trim(into$)+SL$
				If replace=0
					If FileSize(modules_extPath$+into$)=-2 ;check folder exist?
						needupdate=0
						If lastDownload$+SL$=into$
							needupdate=1
						EndIf
						ForEach update() 
							If update()=name$ Or update()="ALL"
								needupdate=1
							EndIf
						Next
						If needupdate=0
							Goto done
						EndIf
					EndIf
				EndIf	
				;Debug "copy "+into$
				CopyDirectory(modules_extPath$+from$,modules_extPath$+into$,"",#PB_FileSystem_Recursive)
			Case "MOVE"
				from$=StringField(dat$,1,",")
				If FindString(from$,Chr(34))<>0
					from$=ReplaceString(from$,Chr(34),"")	
				EndIf
				from$=Trim(from$)+SL$
				into$=StringField(dat$,2,",")
				If FindString(into$,Chr(34))<>0
					into$=ReplaceString(into$,Chr(34),"")	
				EndIf
				into$=Trim(into$)+SL$
				If replace=0
					If FileSize(modules_extPath$+into$)=-2 ;check folder exist?
						needupdate=0
						If lastDownload$+SL$=into$
							needupdate=1
						EndIf
						ForEach update() 
							If update()=name$ Or update()="ALL"
								needupdate=1
							EndIf
						Next
						If needupdate=0
							Goto done
						EndIf
					EndIf
				EndIf	
				;Debug "move "+into$
				CopyDirectory(modules_extPath$+from$,modules_extPath$+into$,"",#PB_FileSystem_Recursive)
				DeleteDirectory(modules_extPath$+from$,"",#PB_FileSystem_Recursive)
		EndSelect
		done:
	Until Eof(file)
	CloseFile(file)	
EndIf
PrintN("Process Completed")
Delay(2000)
CloseConsole()
; IDE Options = PureBasic 5.41 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 234
; FirstLine = 154
; Folding = v
; EnableXP
; Executable = modext_winnt.exe
; CommandLine = -update=diddy -into=mod_my
; CompileSourceDirectory