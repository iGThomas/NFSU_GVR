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

The install will succeed but with some font errors missing which can be ignored. 

At some point on Disc 2 is asks for Net Framework version 1.1.4322. you can find it on the webarchiev for windows XP especially: https://archive.org/details/dotnetfx_202102

After installing the dotnet I was able to install the disc 2 but then got the error on some shell script that was ran by the disc located on C:\GvrPlus\1\scripts\GvRPlusExportDatabaseScript.exe:
Error: Database installation started.COM objectwith CLSID (10020200-E260-[truncated]) is either not valid or not registered. Failure changing Account Password.  Press enter to continue

I believe it's linekd to the cabinet username and password which is just cabinet/cabinet (to be continued)
