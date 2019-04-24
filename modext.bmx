'Compile with BlitzMax NG (bmk-3.31) (bcc-0.99) https://blitzmax.org/downloads/
'Brucey module 
'https://github.com/maxmods/bah.mod/tree/master/libcurl.mod
'https://github.com/maxmods/gman.mod

Framework BaH.libcurl
Import BRL.StandardIO
Import BRL.FileSystem
Import BRL.Retro
Import gman.zipengine

Print "CerberusX - External Modules Auto Download"
Global binPath:String = AppDir+"/"
Global update:TList=New TList
Global ModuleFolder:String="modules_ext"

'Get commandline
For Local k:Int=0 To AppArgs.length-1
	Local cline:String=AppArgs[k]	
	Local cmd:String
	Local opt:String=""
	If k>0
		Local split:String[]=cline.Split("=")
		cmd=Trim(Upper(split[0]))
		If split.length>1
			opt=Trim(split[1])
		EndIf
	EndIf
	Select cmd
		Case "-UPDATE"
			If opt=""
				update.AddLast "ALL"
			Else
				Local split:String[]=opt.Split(",")
				For Local folder:String=EachIn split
					update.AddLast folder
				Next
			EndIf
		Case "-INTO"
			If opt <> ""
				ModuleFolder=opt
			EndIf
	EndSelect
Next
Global modules_extPath:String = Left(binPath,Len(binPath)-4)+ModuleFolder+"/"
If FileType(modules_extPath)<>FILETYPE_DIR
	CreateDir(modules_extPath)
EndIf

'Phrease input file
Global lastDownload:String=""
Global file:TStream
?MacOS
	file=ReadFile(binPath+"modext.macos.txt")
?Win32
	file=ReadFile(binPath+"modext.winnt.txt")
?
If file
	Repeat 
		Local dat:String= ReadLine(file)
		dat=dat.Split("'")[0] 				'eliminate Rem
		dat=Replace(dat,Chr(9)," ")  		'eliminate Tab
		dat=Trim(dat)
		If dat<>""
			Local instruction:String=Trim(Upper(dat.Split("=")[0])) 'get instruction
			
			'check force replace instruction !
			Local NeedReplace:Int=0
			If Instr(instruction,"!")<>0 
				instruction=Replace(instruction,"!","")
				NeedReplace=1
			EndIf
			
			dat=Trim(dat.Split("=")[1]) 'get parameter
			Select instruction
				Case "DOWNLOAD"		'Instruction to download
					If Instr(dat,",")<>0
						'spacify the name
						Local name:String=ClearQuote(dat.Split(",")[1])
						dat=ClearQuote(dat.Split(",")[0])
						Download(Trim(dat),Trim(name),NeedReplace)
					Else
						'Not spacify the name
						dat=ClearQuote(dat)
						Download(Trim(dat),"",NeedReplace)
					EndIf
				Default 	'Instruction to copy / move
					Local from:String=Trim(ClearQuote(dat.Split(",")[0])) 
					Local into:String=Trim(ClearQuote(dat.Split(",")[1])) 
					Local needupdate:Int=1
					If NeedReplace=0						
						If FileType(modules_extPath+into)=FILETYPE_DIR
							needupdate=0
							If lastDownload+"/"=into
								needupdate=1
							EndIf
							For Local folder:String=EachIn update
								If folder=into Or folder="ALL"
									needupdate=1
								EndIf
							Next
						EndIf
					EndIf
					If needupdate
						If instruction="COPY"		
							CopyDir(modules_extPath+from+"/",modules_extPath+into+"/")
						EndIf
						If instruction="MOVE"	
							CopyDir(modules_extPath+from,modules_extPath+into)
							DeleteDir(modules_extPath+from,True)
						EndIf
					EndIf
			EndSelect
		EndIf
	Until Eof(file)
	CloseFile(file)	
EndIf
Print("Process complete")
Delay(2000)

'END

Function ClearQuote:String(dat:String)
	If Instr(dat,Chr(34))<>0
		dat=Replace(dat,Chr(34),"")	
	EndIf
	Return dat
EndFunction
Function Download(addr:String,name:String="",NeedReplace:Int=0)
	If name=""
		Local split:String[]=addr.Split("/")
		name = split[split.length-1]
	EndIf
	If NeedReplace=0
		'no need download if already exist
		If FileType(modules_extPath+name)=FILETYPE_DIR
 			Local needupdate:Int=0
			For Local folder:String=EachIn update
				If folder=name Or folder="ALL"
					needupdate=1
				EndIf
			Next
			If needupdate=0
				Return 
			EndIf
		EndIf
	EndIf
	
	'determin the actual download url and filePath destination
	Local url:String=""
	Local filePath:String=""
	If Instr(addr,"github.com")<>0
		If Right(addr,4)<>".zip" 
			url= addr+"/archive/master.zip"
			filePath=modules_extPath+name+".zip"
		Else
			url= addr
			filePath=modules_extPath+name+".zip"
		EndIf
	Else
		url= addr
		filePath=modules_extPath+name+".zip"
	EndIf
	
	'start actual download
	Print ("Downloading.. "+name)
	If ActualDownload(url,filePath)
		
		'if done unzip it
		Local zrObject:ZipReader=New ZipReader
		If zrObject.OpenZip(filePath)
			Print "   Unzip.. "+name
			For Local i:Int=0 To zrObject.getFileCount()-1
				Local zname:String= zrObject.getFileInfo(i).zipFileName
				Local fname:String
				Local pos:Int=Instr(zname,"/")
				If pos>0
					Local replacename:String=Left(zname,pos-1)
					fname=modules_extPath+Replace(zname,replacename,name)
				EndIf
				zrObject.ExtractFileToDisk(zname,fname)
			Next
			zrObject.CloseZip()
		Else
			Print "   FAIL to download "+name+" !"
		EndIf
		'then delete the zip
		DeleteFile(modules_extPath+name+".zip")
	Else
		Print "   FAIL to download "+name+" !"
		DeleteFile(modules_extPath+name+".zip")
	EndIf
EndFunction	
Function ActualDownload:Int(url:String,file:String)
	Local fileStream:TStream = OpenStream(file, False, True)
	If fileStream Then 
		Local url:String = url
		Local curl:TCurlEasy = TCurlEasy.Create();
		curl.setOptString(CURLOPT_URL, url)
		curl.setWriteStream(fileStream)
		curl.setOptInt(CURLOPT_FOLLOWLOCATION, 1) 	' follow redirects
		curl.setOptInt(CURLOPT_MAXREDIRS, 5) 		' maximum redirects
		curl.setOptInt(CURLOPT_CONNECTTIMEOUT, 15) 	' timeout
		curl.setOptInt(CURLOPT_SSL_VERIFYHOST, 0)	 
		curl.setOptInt(CURLOPT_SSL_VERIFYPEER, 0) 
		Local status:Int = curl.perform()
		If status = CURLM_OK
			curl.cleanup()
			CloseStream fileStream
			Return 1
		Else
			curl.cleanup()
			CloseStream fileStream
			Return 0 'something wrong
		EndIf
	Else
		Return 0 'cannot access file
	EndIf
EndFunction 


