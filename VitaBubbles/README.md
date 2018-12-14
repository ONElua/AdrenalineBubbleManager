# Themes for ONEMenu PSVita

### Shared your theme ###
If you want to share your theme and upload it so that anyone can use it, create a upload request that contains the following information:
- Title
- Author
- Version
- ID (10 alphanumeric digits in capital letters)
And the compressed subject such as <ID> .zip likewise the name of the internal folder on the tablet should be <ID>

### NOTE:<br>
When a CustomTheme is installed the corresponding folder and files are moved to ux0:data/customtheme and for uninstalling any of these CustomThemes you'll be given the option to eliminate the folder and files of the CustomTheme, if you choose not to eliminate them, then the resources of said CustomTheme will be moved to the path ux0:data/uninstall_customtheme for reinstalling in the futured.<br>

The Themes for ONEMenu have to be placed in the path ux0:data/ONEMENU/themes following mostly the same instructions as for AppManager Themes.<br>

Note: Remember an option its been added to download themes directly to the path mentioned below :)

The Themes for ONEMenu have to be placed in the path ux0:data/ONEMENU/themes.<br>

![header](screenshots/1MENUVITA6.png)

![header](screenshots/themes2.png)

++ Create a new folder with the theme name and place the next resources inside:.<br>

**font.ttf**        Font ttf for your Theme (Optional).<br>

**back.png**        Background image for your icons (960*544).<br>

**icodef.png**      Default icon to blit instead of the app/game icon0 when the original icon0 can't be loaded (100*100).<br>

**buttons1.png**    Image Sprites (160*20).<br>


  1. position 0				Cross button

  1. position 1				Triangle button

  1. position 2				Square button

  1. position 3				Circle button

  1. position 4				Plugin icon for games with plugins enabled to it's GAMEID in the config.txt

  1. position 5				Clon icon for cloned psp bubbles.

  1. position 6				For battery in use.

  1. position 7				For battery charging.

  1. position 8				For Favorites.


**buttons2.png**    Image Sprites (120*20)
  
**wifi.png**        Image Sprites (132*22)

**cover.png**       Image for Song Cover in Music section (369x369)

**music.png**       Image for Music section (960*544)

**editor.png**     Image for the Text Editor (960*544)

**ftp.png**         Background Image for FTP port message (960*544)

**list.png**        Image for ExplorerFiles and vpk/iso/cso search results found on memory card (960*544)

**themesmanager.png** Background Image for ONEMenu theme selection section (960*544)

**preview.png**     Your image preview for your theme for ONEMenu (391*219)

**icons.png**       Sprites (112x16) must follow next order:

  1. position 0			    Icon to blit for general files

  1. position 1				Icon to blit for folders

  1. position 2				Icon to blit for: pbp, prx, bin, suprx, skprx files

  1. position 3				Icon to blit for: png, gif, jpg, bmp image files

  1. position 4				Icon to blit for: mp3, s3m, wav, at3, ogg sound files

  1. position 5				Icon to blit for: vpk, rar, zip files

  1. position 6				Icon to blit for: iso, cso, dax files


*Label Categories*

**PSVITA.png**   PSVita Games (250*66).<br>

**HBVITA.png**   Homebrews Vita (250*66).<br>

**PSM.png**      PSM Games (250*66).<br>

**RETRO.png**    PSP & PS1 Games (250*66).<br>

**ADRBB.png**    Adrenaline Bubbles Games (250*66).<br>


# Create a ini file

**theme.ini**

This .ini file stores the text printing colors according to file extension.<br>
*Change only the Hex-Dec part for the desired color. (ABGR format)<br>

TITLE = "Name of your theme".<br>
AUTHOR = "Name of Author".<br>

*# Text and background color.*<br>
TXTCOLOR		= 0xFFFFFFFF<br>
TXTBKGCOLOR		= 0x64000000

*#Submenu color bar on selected icon.*<br>
BARCOLOR        = 0x64330066

*#Header color.*<br>
TITLECOLOR      = 0xFF9999FF

*#Path text color (File Explorer).*<br>
PATHCOLOR       = 0xA09999FF

*#Date and time indicator text color.*<br>
DATETIMECOLOR   = 0xFF7300E6

*#Folder/File count in the file explorer.*<br>
COUNTCOLOR	= 0XFF0000FF

*#Draw the bars in the callbacks section.*<br>
CBACKSBARCOLOR	= 0x64FFFFFF

#File type text color for File Explorer.*<br>
SELCOLOR        = 0x64530689<br>
SFOCOLOR        = 0XFFFF07FF<br>
BINCOLOR        = 0XFF0041C3<br>
MUSICCOLOR      = 0xFFFFFF00<br>
IMAGECOLOR      = 0xFF00FF00<br>
ARCHIVECOLOR    = 0xFFFF00CC<br>
MARKEDCOLOR     = 0x2AFF00FF<br>
FTPCOLOR		= 0xFFFF66FF<br>

*#Battery percentage text color.*<br>
PERCENTCOLOR	= 0x6426004D

*#Battery status indicator bar color.*<br>
BATTERYCOLOR	= 0x6453CE43<br>
LOWBATTERYCOLOR	= 0xFF0000B3<br>

*#Rectangle and gradient color for selected icon (PS4 Theme).*<br>
GRADRECTCOLOR	= 0x64330066<br>
GRADSHADOWCOLOR = 0xC8FFFFFF<br>

*Change only the Hex-Dec part for the desired color. (ABGR format)<br>
Recommended website: ([Colors Hex](https://www.w3schools.com/colors/colors_hexadecimal.asp)).<br>

![header](screenshots/themes1.png)
