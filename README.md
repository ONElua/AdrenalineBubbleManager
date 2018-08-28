# Adrenaline Bubbles Manager
**Create and organize your direct adrenaline bubbles.**

![header](ContentSelection.png)

### Description ###
This useful application allows you to make personalized bubbles with 'icon' and 'title' of your PSP content (HBS/PSX/ISO/CSO) quick and easy, using the 'LMAN' plugin, forgetting completely of the tedious and long manual method.

## IMPORTANT ##
**Adrenaline Bubbles Manager (ABM) purpose is to create the bubbles and necesary links to boot chosen psp iso/cso/pbp files with adrenaline v6.x through Lman's plugin adrbblbooter, all done within the ps vita, but, ABM does not change cpu speed, any issue related with that should be mentioned to Lman or the_flow**

![header](Bubbles.png)

### Adrenaline Version v6.7 ###
### Adrenaline Bubble Booter Version v0.8 ###
### Adrenaline Bubbles Manager Current Version: 5.13 ###

### Instructions ###
1. **Install Adrenaline v6.7**
Make sure Adrenaline works correctly, to be able to boot Adrenaline opening it just once, it is highly recommended to add the following line below the kernel line in ur0:tai/config.txt.<br>
*KERNEL<br>
ux0:app/PSPEMUCFW/sce_module/adrenaline_kernel.skprx

2. After taking care of step 1, then you can start using Adrenaline Bubbles Manager to create bubbles for your PSP/PSX content.

### Changelog 5.13 ###
- Now you can select the SetPack for each bubble. Press R on the selected game.<br>
- Fixed error with the STITLE when creating bubbles (max length 52).<br>

### Changelog 5.12 ###
- Added PSP/PSX image set for bubble creation.<br>
- Added option description at submenu.<br>
- Added Adrenaline customized option enable/disable to ABM submenu.<br>
- Added a new bubble color similar to original PSP/PSX bubbles.<br>
- Added chinese support (download font from github repo and place at ux0:data/ABM/font)<br>

### Changelog 5.11 ###
- Compatible with Adrenaline v6.7 and Adrenaline Bubble Booter v.08<br>

### Changelog 5.10 ###
- Fixed reboot error (reboot loop). :( <br>

### Changelog 5.09 ###
- Fix support for iso/cso/pbp in xmc0.<br>
- Sort by Device (ux0,ur0,uma0, imc0, xmc0).<br>

### Changelog 5.08 ###
- Now ABM scans and shows PSP/PSX original games, but qwikrazor87's plugin is needed (npdrm_free.prx).
- Compatible with Adrenaline v6.6 and Adrenaline Bubble Booter v.07<br>
- Added support for iso/cso/pbp in xmc0 (Use Vitashell for mount xmc0).<br>
- Fix "startup.png" images<br>
- Support added for frameX.png images (with X from 1 to 5).<br>
- Sort by ID.<br>
- Light aesthetic changes and clean up code.<br>

### Changelog 5.07 ###
- Fix error C2-12828-1 on ABM bubbles.<br>
- Added Auto Repair boot.bin option on the START button submenu (changes the customized option to YES on the old Bubbles from ABM 5.04).<br>
- Now the bg0.png is shown at Bubbles Edit screen.<br>

### Changelog 5.06 ###
- Fixed reboot error (reboot loop).<br>

### Changelog 5.05 ###
- Compatible with Adrenaline v6.4 and Adrenaline Bubble Booter v.06<br>
- Auto-Conversion of boot.inf files to boot.bin files needed for ABB v.06<br>
- In the Edit Bubble Screen this are the available combinations:<br>
- Driver (INFERNO/MARCH33/NP9660).<br>
- Execute (EBOOT.BIN/EBOOT.OLD/BOOT.BIN).<br>
- Customized: (YES/NO).<br>
- Now when showing the bubble's linked game path will be highlighted green if the content is found, if not found will be highlighted orange.<br>
- *NOTE: If the game linked to your bubble is not there anymore the bubble will open Adrenaline or throw an error.<br>

### Changelog 5.04 ###
- Now you can disable the 8bit image conversion when creating or editing ABM bubbles.<br>
*NOTE: You must be sure the images you are using are in compatible format, otherwise the bubble will fail. Enter the submenu to change this settings with start.<br>
- Some changes in the list of Inject Imgs.<br>

### Changelog 5.03 ###
- New option to set default pic0 and bg0 images and your own xml file for your bubbles (up to 5 sets provided by you: ux0:ABM/Set1 to ux0:ABM/Set5).<br>
- New option to sort: Category.<br>

### Changelog 5.02 ###
- Fixed data.inf error.<br>
- Added config.bin on each bubble (adrenaline boot screen disabled).<br>
- New graphics by Wz-Jk.<br>

### Changelog 5.01 ###
- Compatible with Adrenaline v6.3 thanks to Lman.<br>
- Added npdrmfree enable/disable option to ABM bubble edit screen.<br>
- Added ux0:data/ABM/crc.ini to detect the CRC32 of the skprx modules.<br>

**NOTE:** With lman plugins update, now every bubble saves its own adrenaline configs if you like to disable adrenaline boot screen you have to do that for every bubble.<br>

### Changelog 5.00 ###
- Added submenu for Extra Setting.<br>
- Added hability to inject images to ABM bubbles.<br>

### Controls ###

**Adrenaline Bubbles Manager does recognize the accept/cancel buttons According to console region.**

## iso/cso/pbp content selection screen ##

*Creating Bubbles*

- **L/R:** To switch the way the bubble will look like in Livearea (original icon look/stretched icon look)<br>
- **Left/Right:** To change the bubble background color for the selected content (when using original size not stretched icons, 17 available colors ).<br>
- **Square:** Multiple Selection.<br>
- **Start:** Open Extra Settings menu (set default bubble color, sort list, Adrenaline version check, Adrenaline Bubbles Manager version check).<br>
- **X:** Create Bubbles.<br>
- **O:** Configurate/Edit Bubbles.<br>

*Extra Settings*

This option allows you to set some preferences as default for ABM such as:
- Set sort list of your iso/cso/pbp.<br>
- Select the default color for your bubbles.<br>
- Enable/Disable ABM updates.<br>
- Adrenaline version check.<br>
	This option disables/enables ABM to check the Adrenaline version you have installed in your ps vita. 

![header](ExtraSettings.png)

### NOTE: ###
**If your Adrenaline.vpk gets updated online to a higher version used by ABM, then you'll have to disable this option
to avoid reinstalling the adrbblbooter plugins to the PSPEMUCFW folder everytime you open ABM.**

## Bubble edit screen ##

*Editing Bubbles*

**Triangle:** Allows to edit the configuration file boot.inf<br>
	Change driver: "INFERNO", "MARCH33", "NP9660"<br>
	Changes the .bin booting mode: "EBOOT.BIN", "BOOT.BIN", "EBOOT.OLD"<br>
	Disable/Enable plugins: "ENABLE", "DISABLE"<br>
	Disable/Enable npdrmfree: "ENABLE", "DISABLE"<br>

![header](BubbleEdit.png)

*Uninstall Bubbles*
- Press select (single) or start (all) to select bubbles you wish to uninstall.
- Square: To uninstall the selected bubbles.

*Insert Images*

This option allows you to Insert your desired images to the selected bubble, this will improve the looks of your bubbles in Livearea.

To use this feature you have to follow the instructions below:<br>
1. Download or create the images to insert, those images to use have to be renamed and resized to:<br>
- icon0.png			128x128<br>
- startup.png		280x158 (max)<br>   
- pic0.png			960x544<br>   
- bg0.png			840x500<br>
2. Create a new folder, rename to anything you want, recommended to use your game name, inside this folder place the images created in step 1.<br>
3. Copy/paste your newly created folder with the images inside to the path ux0:ABM/<br>

![header](PreviewsImgs.png)

### NOTE: ###
Make sure the images are renamed as mentioned above and to be in png format, also make sure the images are resized to corresponding sizes mentioned avobe (if your images sizes are close to specs they will work too).<br>
You can add your own template.xml file. (Make sure the images names are the same to images linked in the template.xml).

To insert new images to any selected bubble, when you are in the Edit Bubble menu:<br>
- **X:** To open images folder list.<br>

In images folder list:
- **X:** To choose the folder where you have the images to insert (preview of the images will be shown).<br>
- **O:** To go back.<br>

After choosing a folder, when you can see the images previews:<br>
-- **O:** To go back.<br>
- **START:** Insert the previewed images to chosen bubble.<br>

### Credits ###
- eCFW Adrenaline By TheFloW.
- Adrenaline Bubble Booter By LMAN 'leecherman'
- startup.png By Freakler.
- Testers @_Falaschi_, @baltazarregala4.
- Some graphics By WZ-JK.

## Donation ##
In case you want to support the work of the team on the vita, you can always donate for some coffee. Any amount is highly appreciated:

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=YHZ5XBWEXP8ZY&lc=MX&item_name=ONElua%20Team%20Projects&item_number=AdrenalineBubbleManager&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
