# Cerberus_Modext

https://youtu.be/51EUSbSFIN0

Purpose: Auto download a collectioin of External Modules for CerberusX (https://www.cerberus-x.com/wordpress/)

To use/install, copy this file into /bin/ folder of CerberusX
- modext.exe
- modext.winnt.txt

The source file is using Purebasic (https://www.purebasic.com/)
This is the file.
- modext.pb

WARNING!! Before run modext.exe, Please backup your Cerberus\modules_ext\ folder.
All existing file and folder in Cerberus\modules_ext\
will be replace by the new version once they are downloaded.

This is the list of module to be download by the app
- FantomCX
- Holzchopf module
- Fontmachine
- guiBasic
- vortex2
- realtime
- ..and several others.
You can change them in modext.winnt.txt file

The **modext.winnt.txt** act like a source file to tell the program what to download or what to do with it.
# Command
Use DOWNLOAD command to download a file 
- First parameter is the download address
- The second parameter is folder name to be use in Cerberus\modules_ext\? .This is optional. If not supply it will use the github project name or zip filename

use COPY or MOVE command to copy or move from folder to another folder. Because sometime the main folder name is not the module name.
But only folder inside ..modules_ext\*.* is allow to be move/copy
- First parameter is the source folder (without ..modules_ext\ path)
- Second parameter is the destination folder (without ..modules_ext\ path)


