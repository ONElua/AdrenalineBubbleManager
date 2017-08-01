# AdrenalineBubbleManager

![header](preview.jpg)

Create and organize your direct adrenaline bubbles.

### Description ###
This useful application allows you to make personalized bubbles with 'icon' and 'title' of your PSP content (HBS/PSX/ISO/CSO) quick and easy, using the 'LMAN' plugin, and adding the lines Of the plugin to the GAMEID in the config.txt of taihen, also creates the GAMEID.TXT for the plugin, forgetting completely of the tedious and long manual method.

### Instructions ###
The initial interface is composed by the list of available PSP content to launch (HBS/PSX/ISO/CSO), get positioned over the desired content using the D-pad and press X on the desired game to proceed to select the bubble that will launch it, a popup window will show you all the bubbles available to use (PSP GAME), you only have to position yourself on the desired one and press X, to begin the linking process, this app will tell you if there is an installed pboot and if you want to change it and continue, then the app will ask you if the STARTDAT should be disabled, you will also be asked if you want to change the Name the bubble or use that of the content to link, and finally you will be asked to restart the console to update the database.
Note: This app will allow you to personalize more than one bubble at a time.

### MARCH33 driver ###
- Usage of M33 driver + EBOOT.OLD (prometheus) is recommended on following situations:

  For PSP content which go pass the startdat but stay in black screen. I'll mention PE 3rd birthday as an example.

  For all PSP minis.
- For PSP content which still won't go beyond the black screen you should contact Leecherman or wait for his next update. 

### Controls ###
- Up/Down: Browse the list of PSP content(HB/ISO/CSO) or Browse the list of bubbles to boot.
- Cross: Select content and go to bubble selection or select bubble and create your access.
- Square: Select content to install M33 driver from start screen (for iso/cso files only).
- Circle: Go to previous section.
- Triangle: enable/disable view of 'PIC1'.
- Start: Go to livearea.

### Extras ###
- Cross: Make PBOOT.PBP
- Circle: Make ICON0.DDS

### Changelog 2.1 ###
- Now you can press [] to **install M33 driver** from start screen (for iso/cso files only).
- NEW OPTION ICON0.DDS: Added the option to use **pic1.png** to show as **bg0.png**, and to set icon.dds to be shown in full bubble (but, to use this feature, te game must have been booted once and changes will revert after a db rebuild).
- More Code got cleaned up a bit.

### Changelog 2.0 ###
- Adrbblbooter plugin files updated to newest version (v0.4).
- Added the option to use selected content's pic1 as STARTDAT.PNG if found, otherwise Lman's plugin default STARTDAT.PNG will be used.
- Now the function Disable Adrbblbooter Bubbles allows to:

1. Eliminate the GAMEID.TXT and corresponding STARTDAT.png files from path "ux0:adrbblbooter/bubblesdb/".

2. Eliminate corresponding lines from ux0:tai/config.txt and reload config

3. Eliminate the PBOOT.PBP from chosen bubble.

- Code got cleaned up a bit.
- Some stetic changes.

Extras.
- Cross: Add M33 line to GAMEID.txt on screen message.
On small popup window (to add corresponding lines to GAMEID.TXT).
- Cross: BOOT.BIN for M33 driver only.
- Triangle: EBOOT.OLD FOR M33 DRIVER + Prometheus ISO loader.
- Circle: Cancel.

### Changelog 1.0 ###
- Initial release 'POC'.
- Added automatic network update. app will now notify you when there's a new update.
- Support get and view complete list of content of PSPemu.
- Added option enable/disable view of 'PIC1'.

### Credits ###
- Adrenaline Bubble Booter By LMAN 'leecherman'
- eCFW Adrenaline By TheFloW.
- PBOOT icon and livearea icon By Freakler.
- Testers @_Falaschi_, @baltazarregala4.
- Some graphics By WZ-JK.

## Donation ##
In case you want to support the work of the team on the vita, you can always donate for some coffee. Any amount is highly appreciated:

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=YHZ5XBWEXP8ZY&lc=MX&item_name=ONElua%20Team%20Projects&item_number=AdrenalineBubbleManager&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
