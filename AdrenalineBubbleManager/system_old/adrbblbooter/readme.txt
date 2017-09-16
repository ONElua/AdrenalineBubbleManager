Adrenaline Bubble Booter (C) 2017 LMAN <leecherman>

Directly boot any game (ISO\CSO\PBP\PSOne) from any PSP Bubble in livearea,
With all features enabled, plugins, filter, savestates and PSOne sound enabled.

This is a separated plugin, which can be used with all new adrenaline versions,
so no worries with the compatibility issue or with updated adrenaline versions.

====================================================================================================

Donation:
If you wish to donate me some money, I'd really appreciate it.
Link: https://sites.google.com/site/theleecherman/donate

====================================================================================================

Homepage:
If you want to check for new updates, plugins, tools or want to contact me, visit my homepage:
Link: https://sites.google.com/site/theleecherman

====================================================================================================

Changelog:

v0.1:
-First public release.

v0.2:
-Updated some codes and instructions.

v0.3:
-Updated codes and made some tweaks.
 You can boot games from both ux0, ur0 partitions
 without changing the plugin's location.

v0.4:
-Added driver mode option to use march33 instead of inferno for each iso file.
-Added execute eboot.old or boot.bin option instead of eboot.bin for each iso file.
-Added support to load a custom startdat PNG boot image for each PSP bubbles.
 CHECK ADDITIONAL INFOS BELOW FOR THE DETAILS.

v0.5:
-Updated code and removed adrbblbooter_nostartdat.suprx -> added an option instead.
-Added uma0 partition support to boot games from it -> use the updated adrenaline version.
-Added np9660 driver mode option beside march33 and inferno driver.
-Added plugins state option to disable or enable all game and pops plugins for each game file.
-Added startdat boot image option to disable or enable startdat boot image for each game file.
 CHECK ADDITIONAL INFOS BELOW FOR THE DETAILS.

====================================================================================================

Usage:

-If this is your first time using adrenaline, read the author's instructions to install it correctly,
 otherwise it will not work, because this is depends on adrenaline, and make sure to install 
 adrenaline folder in the storage root 'ux0:adrenaline' after installing it, run it once.
-The bubble that you are using to boot Adrenaline, will be used also to boot ISO\CSO\PBP files.
-Add ISO\CSO\PBP files you want to boot it to 'ux0:pspemu/' or 'ur0:pspemu/' etc.
-Pay ATTENTION to the instruction, cause any mistakes will not make it work.

1)

To enable adrenaline bubble booter, copy 'adrbblbooter' folder to your PSVita storage root :

ux0:/adrbblbooter

2)

Add 'adrbblbooter.suprx' first in line before 'adrenaline.suprx' under *TITLEID in HENKaku config.txt :
Will use NPXX00001 as an example of the PSP bubble in livearea:

*NPXX00001
ux0:adrbblbooter/adrbblbooter.suprx
ux0:adrenaline/adrenaline.suprx

After that Reload HENKaku config.txt from molecularShell or from HENKaku settings.

3)

Go to 'ux0:adrbblbooter/bubblesdb' folder, and create a text file and
name it with any PSP Bubble TITLEID you want to make it boot (ISO\CSO\PBP\PSOne) file :

ux0:adrbblbooter/bubblesdb/NPXX00001.txt

Open the created file 'NPXX00001.txt' in notepad and add the full path to
the ISO\CSO\PBP\PSOne game into it ( must be a ms0: path, not ux0:pspemu also
you can change\update the path any-time) :

ms0:/PSP/GAME/FILER/EBOOT.PBP

Note: This line means in PSVita side as ( ux0:pspemu/PSP/GAME/FILER/EBOOT.PBP )

That's it, do these steps ( #2, #3 ) for each PSP bubble you want to auto\direct boot it.

If you want to remove bubble auto\direct boot for specific game,
just delete the text file which containing it's titleid name:

ux0:adrbblbooter/bubblesdb/NPXX00001.txt

====================================================================================================

Additional Infos:

To load a custom startdat boot image for each PSP bubbles: 
Copy PNG image file to 'ux0:adrbblbooter/bubblesdb' folder, then rename it
to any PSP bubbles title-id you want to make it display the startdat boot image.
The image size and format must be 480x272 PNG file, otherwise it will not work.
If the PNG image file doesn't exist, then it will display the default Adrenaline logo.
Also in this version, you can display any logo without booting games if you delete
the title-id.txt file from bubblesdb folder, an example of PNG file is located in bubblesdb folder.

To use MARCH33 or NP9660 driver ( default is INFERNO ) just append MARCH33 or NP9660 in a new line under
the game's file path, so it will look like this:
 
ms0:/ISO/GAME.ISO
MARCH33

To execute BOOT.BIN or EBOOT.OLD for prometheus ( default is EBOOT.BIN ) just append EBOOT.OLD or BOOT.BIN
in a new line under the driver mode option, so will look like this:

ms0:/ISO/GAME.ISO
MARCH33
EBOOT.OLD

To disable or enable all plugins ( default is CFW settings ) when booting games or pops, just append DISABLE or
ENABLE in a new line under the execute mode option, so it will look like this:

ms0:/ISO/GAME.ISO
MARCH33
EBOOT.OLD
DISABLE

To disable startdat image when booting bubble ( default is ENABLE ) just append DISABLE in a new line under
the plugins mode option, so it will look like this:

ms0:/ISO/GAME.ISO
MARCH33
EBOOT.OLD
DISABLE
DISABLE

To use default option for specific mode\line, just replace the option with DEFAULT:

ms0:/ISO/GAME.ISO
MARCH33
DEFAULT
DEFAULT
ENABLE

To use all default options, just add the game's file path to the PSP bubble title-id.txt files, just like the
previous versions:

ms0:/ISO/GAME.ISO

STRUCTURE of the %TITLED-ID%.TXT FILE IS AS THE FOLLOWING:

1st LINE = PATH TO THE ISO\CSO\PBP file.
2nd LINE = UMD DRIVER MODE INFERNO\MARCH33\NP9660.
3rd LINE = EXECUTE BOOT MODE EBOOT.BIN\EBOOT.OLD\BOOT.BIN.
4th LINE = PLUGINS STATE ENABLE\DISABLE.
5th LINE = STARTDAT STATE ENABLE\DISABLE.

Enjoy :)