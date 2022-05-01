# Cerberus_Modext

Purpose: Auto download a collectioin of External Modules for CerberusX (https://www.cerberus-x.com/wordpress/)

Windows
-------
To use, copy this file into /bin/ folder of CerberusX
- modext_winnt.exe
- modext.winnt.txt

MacOs
-----
To use, copy this file into /bin/ folder of CerberusX
- modext_macos
- modext.macos.txt

The source file is using BlitzMax
'Compile with BlitzMax NG (bmk-3.31) (bcc-0.99) https://blitzmax.org/downloads/
'Brucey module 
'https://github.com/maxmods/bah.mod/tree/master/libcurl.mod
'https://github.com/maxmods/gman.mod

Commandline Usage
-----------------
modext_winnt.exe [-into=**modulefolder**][-update[=**folder,folder,...**]]

If not supply -update in commandline(default) then the existing module will not be update. Only new module will be download.<br>
If -update[=**folder,folder,...**] didn't suply the list of folder, ALL module will be update. If supply, only those list be update

Use -into to give a folder name for your external module. If not supply default will use as **modules_ext**

Example1: modext_winnt.exe <br>
This will download everything but will skip if module already exist.<br>
Example2: modext_winnt.exe -into=my_module<br>
This will download into folder call **my_module**. <br>
Example3: modext_winnt.exe -update<br>
This will download everything and replace module that already exist.<br>
Example4: modext_winnt.exe -update=diddy,fantomCX<br>
This will download everything but will not replace anything except diddy and fantomCX modules will be replace.<br>

WARNING!! All existing module that share the same name will be replace by the new version if you run with -update.<br>
Please backup your modules if necessary. Better safe than sorry!

This is the list of module to be download by the app
- FantomCX
- Holzchopf module
- Fontmachine
- guiBasic
- vortex2
- realtime
- GIF Loader
- CRT tv shader
- SDL2_Mixer
- Diddy
- Flixel
- SimpleUI
- ..and probably several others.
You can change them in modext.winnt.txt file

# Command

The **modext.winnt.txt** and **modext.macos.txt** act like a source file to tell the program what to download or what to do with it.

There are 3 commands:

Use DOWNLOAD command to download a file:

    [!] DOWNLOAD = <link> , <module_name>

    This is the command to automatic download and unzip a module into <module_name>
    For module in Github just give the address of main repo name like "https://github.com/swoolcock/diddy"
    If <module_name> is not supply it will use repo name or zip file name.
    Use ! if infront of DOWNLOAD command to force to replace if folder already exist 

Use COPY or MOVE command to copy or move from folder to another folder:

    [!] MOVE = <fromFolder> , <toFolder>
    [!] COPY = <fromFolder> , <toFolder>

    Use COPY or MOVE command to copy or move from folder to another folder
    The way to name folder:
      -<fromFolder> and <toFolder> is not a real folder path.
      -is only deal with item inside modules_ext. Example name: "sdl2mixer\modules_ext\sdl2mixer" , "sdl2mixer"
      -Use ! if infront of COPY or MOVE command to force to replace if folder already exist 

Example source:
  
    DOWNLOAD = "https://github.com/MikeHart66/fantomCX/","fantomCX"
    DOWNLOAD = "https://github.com/zomagic/guiBasic","guiBasic"
    MOVE     = "guiBasic\guiBasic" , "guiBasic"
    DOWNLOAD = "https://github.com/swoolcock/diddy"
    MOVE     = "diddy\src\diddy" , "diddy"         		
    COPY     = "diddy\src\threading" , "threading" 	

