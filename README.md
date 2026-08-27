# Adrenaline Bubbles Manager
**Create and organize your direct adrenaline bubbles.**

Compatible with both TheOfficialFloW/Adrenaline v7 and isage/Adrenaline 8.0.2<br>
Automatically replaces AdrBubbleBooter and relevant Adrenaline modules with ones found in:
* My open-source version of AdrBubbleBooter: https://github.com/shoui520/AdrBubbleBooter-oss/releases/tag/v1.3-MENU-LABEL-FIX
* My TheOfficialFloW/Adrenaline fork, with low-latency 2× PSP upscaling: https://github.com/shoui520/Adrenaline
* If you use isage/Adrenaline, my adrbubble-v8.0.2 version, which also includes the same changes: https://github.com/shoui520/Adrenaline-isage/releases/tag/adrbubble-v8.0.2 - comes with the ISAGECOMPAT version of AdrBubbleBooter

Upstream ONELua/AdrenalineBubbleManager and LMAN's AdrBubbleBooter v1.3 mislabel the UMD drivers. So all your bubbles that apparently use "INFERNO" are actually using NP9660. This version fixes that and also automatically in-place patches all your existing bubbles to correctly use INFERNO.<br>

Updating is simple:
* Install the latest .vpk with VitaShell.
* Launch Adrenaline Bubbles Manager, it will automatically replace your Adrenaline modules with the updated versions. This will require a Vita reboot.
* Once rebooted, launch Adrenaline, then exit PspEmu application.
* Launch AdrenalineBubbleManager and continue to use it as usual.

![header](ContentSelection.png)

### Description ###
This useful application allows you to make personalized bubbles with 'icon' and 'title' of your PSP content (HBS/PSX/ISO/CSO) quick and easy, using the 'LMAN' plugin, forgetting completely of the tedious and long manual method.

## IMPORTANT ##
**Adrenaline Bubbles Manager (ABM) creates bubbles and the necessary links to boot selected PSP ISO/CSO/PBP files through AdrBubbleBooter. ABM does not change PSP CPU speed.**

![header](Bubbles.png)

### Supported Adrenaline Versions: TheOfficialFloW v7.0 / isage v8.0.2 ###
### Included Adrenaline Bubble Booter Versions: v1.3-MENU-LABEL-FIX / v1.3-ISAGECOMPAT ###
### Adrenaline Bubbles Manager Current Version: 6.22 ###


### Instructions ###
1. **Install TheOfficialFloW Adrenaline v7.0 or Isage Adrenaline 8.0.2**
Make sure Adrenaline works correctly, to be able to boot Adrenaline opening it just once, it is highly recommended to add the following line below the kernel line in ur0:tai/config.txt.<br>
*KERNEL<br>
ux0:app/PSPEMUCFW/sce_module/adrenaline_kernel.skprx

2. After taking care of step 1, then you can start using Adrenaline Bubbles Manager to create bubbles for your PSP/PSX content.

### NOTE (NoPspEmudrm) ###
For support with downloaded games (NoPspEmudrm) you must have installed the following plugins in adrenaline:
- *([Npdrm free mod](https://github.com/lusid1/npdrm_free_mod)).*<br>
- *([Np Loader mod](https://github.com/lusid1/nploader_mod)).*<br>

### Changelog 6.22 ###
- Added support for isage/Adrenaline 8.0.2 and the ISAGECOMPAT AdrBubbleBooter stack.<br>
- Added exact module detection for TheOfficialFloW/Adrenaline v7, isage/Adrenaline 8.0.2, original LMAN AdrBubbleBooter, MENU-LABEL-FIX AdrBubbleBooter, and ISAGECOMPAT AdrBubbleBooter.<br>
- Added family-specific installation and restoration. Known partial updates can be completed safely; unknown, mixed, or cross-family core module sets are left untouched instead of receiving incompatible files.<br>
- Existing bubbles continue to be repaired in place to use the real INFERNO driver.<br>

### Changelog 6.21 ###
- Removed the automatic ABM update check at startup and its Extra Settings option.<br>
- Fixed blank LiveArea labels caused by long UTF-8 titles. Bubble short titles are now truncated only at a complete UTF-8 character, while the full title is preserved separately.<br>
- Improved bubble creation speed by removing unnecessary waits and redundant cleanup, and by using 444 MHz CPU/222 MHz bus clocks during preprocessing. The original clocks are restored before Sony promotion.<br>

### Included Adrenaline Modules 6.20.2 (no ABM version bump) ###
- Replaced the included Adrenaline modules with builds that render Sharp Bilinear Simple (No Scanlines) through Sony's direct IFTU point-sampled 2× path, preserving integer-scaled PSP pixels without the Vita2D graphics-filtering delay.<br>

### Included AdrBubbleBooter Modules 6.20.1 (no ABM version bump) ###
- Corrected the INFERNO, MARCH33, and NP9660 menu labels in the included AdrBubbleBooter modules through binary editing.<br>

### Fork INFERNO Fix (upstream 6.20 base; no ABM version bump) ###
- Corrected ABM's serialized UMD-driver mapping so INFERNO, MARCH33, and NP9660 select the driver shown in the interface.<br>
- Added in-place repair of existing ABM bubbles, including conversion of the legacy boot.bin layout while preserving its settings and content path.<br>

### Upstream Changelog 6.20 ###
- Correct support for adrenaline bubbles with boot.bin.

### Changelog 6.19 ###
- Added option to download availabe languages.<br>
- Lastest ABM version is needed to be able to download newset resources for the repo Vita bubbles<br>

### Changelog 6.18 ###
- Added support for the new json format for downloading custom bubbles (preview.png)<br>
- Now the previews are downloaded one by one. (The first time will be a bit slow)<br>

### Changelog 6.17 ###
- Fixed bug that prevented the OSK from opening caused by CR (carriage return) on name input<br>
- Option to create bubbles using gameid of installed legit content has been disabled<br>

### Changelog 6.16 ###
- HotFix No games found<br>

### Changelog 6.15 ###
- Fixed glitch on boot.png images<br>
- When creating new bubbles the template style can be changed: PSPEMU, PS1EMU, PSMOBILE, A5<br>
- Option Restore Adrenaline v7 added to Extra settings<br>
- Added the ability to change the bubble's title for ABM previously created bubbles<br>

### NOTE: ###
Because a lot of PSP Homebrews have the same TitleID, the shotcuts of homebrew will be created like PSPEMUXXX.<br>

### Controls ###

**Adrenaline Bubbles Manager does recognize the accept/cancel buttons According to console region.**

## iso/cso/pbp content selection screen ##

*Creating Bubbles*

- **Triangle:** Batch Installation for non installed content.<br>
- **L:** To switch the way the bubble will look like in Livearea (original icon look/stretched icon look)<br>
- **R:** Select one of the available SetPacks: PSP/PSX or Default:<br>
		Select PSP or PSX to create the bubble using official PSP or PSX BG0 used for Ps Vita.<br>
		Select Default to create the bubble using the iso/cso/eboot resources.<br>
- **SELECT:** Sort List: Device, Install, GameId, Category.<br>
- **Left/Right:** To change the bubble background color for the selected content (when using original size not stretched icons, 17 available colors ).<br>
- **Square:** Multiple Selection.<br>
- **Start:** Open Extra Settings menu (set default bubble color, sort list, and Adrenaline version check).<br>
- **HOLD Analog Right UP + Up:** Press and hold Right Analog 'up' and press button 'up' to switch between template styles for selected bubble: PSPEMU, PS1EMU, PSMOBILE, A5<br>
- **X:** Create Bubbles.<br>
- **O:** Configurate/Edit Bubbles.<br>

![header](Style.png)

*Extra Settings*

This option allows you to set some preferences as default for ABM such as:
- **BubbleID:** PSPEMUXXX or GAMEID.<br>
- **Convert 8bits:** Now you can disable the 8bit image conversion when creating or editing ABM bubbles.<br>
	You must be sure the images you are using are in compatible format, otherwise the bubble will fail. Default is YES.<br>

- **Default Sort:** Installed, Title, Date of modification, Category, GameID or Device.<br>
- **Default Color:** Select the default color for your bubbles (19 colores disponibles).<br>
- **Default BubbleName:** By Title, By File Name or Input the desired Name.<br>
- **Set Template:** Select the template style: PSPEMU, PS1EMU, PSMOBILE, A5.<br>
- **Set Language:** Allows to load selected language at start in ABM: English or Custom.<br>
- **Restore Adrenaline**: Reinstall the original module set for the detected TheOfficialFloW v7 or isage 8.0.2 installation.<br>

![header](ExtraSettings.png)

### NOTE: ###
**ABM only replaces modules when exact fingerprints identify a supported Adrenaline family. Unknown or mixed core module sets are not modified.**

## Bubble edit screen ##

*Editing Bubbles*

**Triangle:** Allows to edit the configuration file boot.inf<br>
-	Change driver: "INFERNO", "MARCH33", "NP9660"<br>
-	Changes the .bin booting mode: "EBOOT.BIN", "BOOT.BIN", "EBOOT.OLD"<br>
-	Customized: To let each bubble have its own settings keep it in YES
-	PS button Mode: Menu, Livearea, Standard
-	Suspend game: Stop the game running on the psp when PS button is pressed.<br>
-	Disable/Enable plugins: "ENABLE", "DISABLE"<br>
-	NonpDRM Engine: Load content using Quickrazor's plugin.<br>
-	High Memory: Force high memory layout. (Disabled for GTA Native Resolution Patch)<br>
-	Change game cpu clock speed: Improves loading speed and game response depending of chosen speed.<br>

![header](BubbleEdit1.png)

In case you move your games to a diferent partition from where the bubble was created, the game path can be edited (will be highlighted in yellow).<br>
The bubble's title can be edited too.<br>

![header](BubbleEdit.png)

*Uninstall Bubbles*
- Press SELECT (single) or START (all) to select bubbles you wish to uninstall.
- Square: To uninstall the selected bubbles.

## Inject images and manual to ABM bubbles ##

This option allows you to Insert your desired images to the selected bubble, this will improve the looks of your bubbles in Livearea.

To use this feature you have to follow the instructions below:<br>
1. Create a folder with the same name of your game (highly recommended but not a must), once you have created/downloaded the images and/or game manual to inject, place them into that folder, then, copy/paste said folder to ux0:ABM. 

2. Download or create the images to insert, those images to use have to be renamed and resized to:<br>
- icon0.png			 128x128<br>
- startup.png		 280x158 (max)<br>   
- pic0.png			 960x544<br>   
- bg0.png			   840x500<br>
- boot.png			 480x272 (32bits or 24 bits) <Optional><br>
- template.xml	 <Optional><br>
- Manual			   images inside (001.png, 002.png 960x544) <Optional><br>
3. Now is possible inject the Manual folder with your manual's images inside (001.png, 002.png 960x544). The folder of the Manual must be place in the following path ux0:ABM/(Gameid)/<br>
4. Copy/paste your newly created folder with the images inside to the path ux0:ABM/<br>

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
- **O:** To go back.<br>
- **START:** Insert the previewed images to chosen bubble.<br>

## Resources Online ##
Press SELECT in the Inyector of Images option to install incredibles Online Resources created by the community for all of us.

![header](ResourcesOnline.png)

![header](ResourcesOnline2.png)

### Credits ###
- eCFW Adrenaline By TheFloW.
- Adrenaline Bubble Booter By LMAN 'leecherman'
- startup.png By Freakler.
- Testers @_Falaschi_, @baltazarregala4.
- Translator @Z3R0N3__.
- Some graphics By WZ-JK.

## Donation ##
In case you want to support the work of the team on the vita, you can always donate for some coffee. Any amount is highly appreciated:

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=YHZ5XBWEXP8ZY&lc=MX&item_name=ONElua%20Team%20Projects&item_number=AdrenalineBubbleManager&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
