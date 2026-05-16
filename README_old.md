# NFSU_GVR
Knowledge about the installation of the Need For Speed Underground: Global VR Arcade edition

Requirements:
Original NFSU System Recovery Disc from GlobalVR 
NFSU Global VR game installation Disc 1 & Disc 2

The system recovery disc is just a system restore disk from a Windows XPe (XP embedded) that was preconfigured for the Global VR arcade systems. 
Installing it on a Virtual Machine like VirtualBox or VMware will succeed but don't increase too much the RAM or CPU or it might fail and freeze on a black screen.
If you want to install it on a virtual machine with the recovery disks then fiddle around with the chipset versions and set the RAM to 2GB with 2CPU, increasing gave me black screen on disc boot or after installation

The game installation disc will fail to install on any system even on a XP SP3 since it searches for a specific field in the registry

For it to work on a normal XP you need to add the following registry inside:
HKLM\System\CurrentControlSet\Control\Session Manager\Environment

Add the following String type inside environment with the name as RUNTIMEOEMREV and value "NFS - UG,XP Embedded,HW Rev 865 e,05052005" (without the double quotes of course"

The following seem also related but don't make the installation block

String -> RUNTIMEGUID = {657AA858-5ACA-4F13-9855-E645192C4A8F}
String -> RUNTIMEPID = Q79DV-JVH86-MGXYC-67TQJ-Q2M2J
String -> RUNTIMESKUCODE = XPeCli

Fun fact if you install the system recovery disk and then run regedit it will open this exact path as if it's the last thing they checked/added before creating a restore image :)

When installing disc 1 it will give popups about locked file detection on some fonts, they can be ignored. An error about NvCpl.dll missing can also be seen if Nvidia drivers

At some point on Disc 2 is asks for Net Framework version 1.1.4322. you can find it on the webarchiev for windows XP especially: https://archive.org/details/dotnetfx_202102

After installing the dotnet I was able to install the disc 2 but then got the error on some shell script that was ran by the disc located on C:\GvrPlus\1\scripts\GvRPlusExportDatabaseScript.exe:
Error: Database installation started.COM objectwith CLSID (10020200-E260-[truncated]) is either not valid or not registered. Failure changing Account Password.  Press enter to continue

The database is required in this game since from what I read the whole frontend is made in SQL and then it somehow launches the UndergroundGVR.exe (game) through it with arguments (someone ported the game to Windows with some custom launcher)

To install the database I exported the setup files from the system recovery disk which was located inside c:\gvr\Database
There were two folders:  _MSDERelA and _SqlXml
the MSDRelA is the important one but it won't launch the setup because it requires special argument so copy the files inside the repo and install the setup like this: setup.exe SAPWD="q2Z35o" DISABLENETWORKPROTOCOLS=1 SECURITYMODE=SQL /qb
(added the default password found thanks to Ratface from Emuline.org)

After installing the game I noticed that the password was changed so I wanted to know what it was, I dug further, decrypted the GvrPlusExportDatabaseScript.exe file which was installed inside the GvrPlus folder after installing the game. Decryption was done by using dnSpy and opening the GvrPlusExportDatabaseScript.exe there I noticed some sort of encryption was happening and changing the DB password. With a small python script I decrypted the whole nfscabinetXml.enc file and got the raw nfscabinetXml which is the whole DB of the game.

The password was then also in plain text: Q31y2Z29wpEsd

To login into the DB command: osql -U sa -P Q31y2Z29wpEsd -S .

To view the DB easily in a UI view I downloaded an old SQL tool from microsoft: http://download.microsoft.com/download/SQLSVR2000/Trial/2000/NT45/EN-US/SQLEVAL.exe

Another requirement for the game to succesfully start is to have the nvidia drivers, unfortunately I couldn't (yet) start the game in VM but on a cheap laptop (Acer Aspire 9300) with AMD and Nvidia Go 6100 the game started once the drivers were installed for Video.

Fun fact the dongle isn't even needed to boot the game while it's needed when you run the game via the recovery disc. On a standalone XP SP3 there's probably some registry missing that I didn't copy about the dongle and it bypassed the dongle.

Career mode is greyed out because there's no smart card reader.

Game Controls:
Numpad 8 Accelerate
Numpad 4 Left
Numpad 6 Right
Key O - Operator Menu
Scrolling in operator mode via arrows
Key S - Start / Reset Car
Key N - Nitros
Key V - Change View
Key Q - Quit
Key E - E-brake
Key M - Reduce song volume - Stop Music - Change Song




