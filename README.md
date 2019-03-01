# Cerberus_Modext

https://youtu.be/51EUSbSFIN0

Purpose: Auto download a collectioin of External Modules for CerberusX (https://www.cerberus-x.com/wordpress/)

Windows
-------
To use/install, copy this file into /bin/ folder of CerberusX
- modext_winnt.exe
- modext.winnt.txt

MacOs
-----
To use/install, copy this file into /bin/ folder of CerberusX
- modext_macos
- modext.macos.txt

The source file is using Purebasic (https://www.purebasic.com/)
This is the file.
- modext.pb

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
Please backup your modules if necessary.

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

Use DOWNLOAD command to download a file 
- First parameter is the download address. For module in Github you can just give the address of main repo name  
- The second parameter is folder name to be use in Cerberus\modules_ext\? .This is optional. If not supply it will use the github repo name or zip filename
- Use ! if infront of DOWNLOAD command to force to replace if folder already exist. This module will always update every run 

use COPY or MOVE command to copy or move from folder to another folder. Because sometime the main folder name is not the module name.
But only folder inside ..modules_ext\*.* is allow to be move/copy
- First parameter is the source folder (without ..modules_ext\ path)
- Second parameter is the destination folder (without ..modules_ext\ path)
- Use ! if infront of COPY or MOVE command to force to replace if folder already exist 


