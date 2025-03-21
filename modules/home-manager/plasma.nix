{ theme, ... }:

let
  wallpaper = ./background.jpg;
in

{
  config = {
    programs.plasma.enable = true;
    programs.plasma.overrideConfig = true;
    programs.plasma.workspace.lookAndFeel = if theme == "light" then "org.kde.breeze.desktop" else "org.kde.breezedark.desktop";
    programs.plasma.workspace.wallpaper = wallpaper;
    programs.plasma.kscreenlocker.appearance.wallpaper = wallpaper;
    programs.plasma.shortcuts = {
      "ActivityManager"."switch-to-activity-bad12a74-aaab-4185-ba10-ad68fedc3f10" = [ ];
      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = [ "Touchpad Toggle" ",Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku" ];
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."decrease_volume_small" = "Shift+Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."increase_volume_small" = "Shift+Volume Up";
      "kmix"."mic_mute" = [ "Microphone Mute" "" "Meta+Volume Mute\\, ,Microphone Mute" "Meta+Volume Mute,Mute Microphone" ];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Halt Without Confirmation" = "\\, ,,Shut Down Without Confirmation";
      "ksmserver"."Lock Session" = [ "Meta+L" "" "Screensaver\\, ,Meta+L" "Screensaver,Lock Session" ];
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "ksmserver"."Log Out Without Confirmation" = [ ];
      "ksmserver"."Reboot" = [ ];
      "ksmserver"."Reboot Without Confirmation" = [ ];
      "ksmserver"."Shut Down" = [ ];
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."ClearLastMouseMark" = "Meta+Shift+F12";
      "kwin"."ClearMouseMarks" = "Meta+Shift+F11";
      "kwin"."Cube" = "Meta+C";
      "kwin"."Cycle Overview" = [ ];
      "kwin"."Cycle Overview Opposite" = [ ];
      "kwin"."Decrease Opacity" = [ ];
      "kwin"."Edit Tiles" = "Meta+T";
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = [ "Ctrl+F10" "" "Launch (C)\\, ,Ctrl+F10" "Launch (C),Toggle Present Windows (All desktops)" ];
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."ExposeClassCurrentDesktop" = [ ];
      "kwin"."Grid View" = "Meta+G";
      "kwin"."Increase Opacity" = [ ];
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."Move Tablet to Next Output" = [ ];
      "kwin"."MoveMouseToCenter" = "Meta+F6,none";
      "kwin"."MoveMouseToFocus" = "Meta+F5,none";
      "kwin"."MoveZoomDown" = [ ];
      "kwin"."MoveZoomLeft" = [ ];
      "kwin"."MoveZoomRight" = [ ];
      "kwin"."MoveZoomUp" = [ ];
      "kwin"."Overview" = "Meta+W";
      "kwin"."Setup Window Shortcut" = [ ];
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
      "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Ctrl+F1";
      "kwin"."Switch to Desktop 10" = [ ];
      "kwin"."Switch to Desktop 11" = [ ];
      "kwin"."Switch to Desktop 12" = [ ];
      "kwin"."Switch to Desktop 13" = [ ];
      "kwin"."Switch to Desktop 14" = [ ];
      "kwin"."Switch to Desktop 15" = [ ];
      "kwin"."Switch to Desktop 16" = [ ];
      "kwin"."Switch to Desktop 17" = [ ];
      "kwin"."Switch to Desktop 18" = [ ];
      "kwin"."Switch to Desktop 19" = [ ];
      "kwin"."Switch to Desktop 2" = "Ctrl+F2";
      "kwin"."Switch to Desktop 20" = [ ];
      "kwin"."Switch to Desktop 3" = "Ctrl+F3";
      "kwin"."Switch to Desktop 4" = "Ctrl+F4";
      "kwin"."Switch to Desktop 5" = [ ];
      "kwin"."Switch to Desktop 6" = [ ];
      "kwin"."Switch to Desktop 7" = [ ];
      "kwin"."Switch to Desktop 8" = [ ];
      "kwin"."Switch to Desktop 9" = [ ];
      "kwin"."Switch to Next Desktop" = [ ];
      "kwin"."Switch to Next Screen" = [ ];
      "kwin"."Switch to Previous Desktop" = [ ];
      "kwin"."Switch to Previous Screen" = [ ];
      "kwin"."Switch to Screen 0" = [ ];
      "kwin"."Switch to Screen 1" = [ ];
      "kwin"."Switch to Screen 2" = [ ];
      "kwin"."Switch to Screen 3" = [ ];
      "kwin"."Switch to Screen 4" = [ ];
      "kwin"."Switch to Screen 5" = [ ];
      "kwin"."Switch to Screen 6" = [ ];
      "kwin"."Switch to Screen 7" = [ ];
      "kwin"."Switch to Screen Above" = [ ];
      "kwin"."Switch to Screen Below" = [ ];
      "kwin"."Switch to Screen to the Left" = [ ];
      "kwin"."Switch to Screen to the Right" = [ ];
      "kwin"."Toggle" = [ ];
      "kwin"."Toggle Night Color" = [ ];
      "kwin"."Toggle Window Raise/Lower" = [ ];
      "kwin"."ToggleCurrentThumbnail" = "Meta+Ctrl+T";
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
      "kwin"."Walk Through Windows Alternative" = "none,,Walk Through Windows Alternative";
      "kwin"."Walk Through Windows Alternative (Reverse)" = "none,,Walk Through Windows Alternative (Reverse)";
      "kwin"."Walk Through Windows of Current Application" = "Alt+`";
      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      "kwin"."Walk Through Windows of Current Application Alternative" = "none,,Walk Through Windows of Current Application Alternative";
      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = "none,,Walk Through Windows of Current Application Alternative (Reverse)";
      "kwin"."Window Above Other Windows" = [ ];
      "kwin"."Window Below Other Windows" = [ ];
      "kwin"."Window Close" = "Alt+F4";
      "kwin"."Window Fullscreen" = [ ];
      "kwin"."Window Grow Horizontal" = [ ];
      "kwin"."Window Grow Vertical" = [ ];
      "kwin"."Window Lower" = [ ];
      "kwin"."Window Maximize" = "Meta+PgUp";
      "kwin"."Window Maximize Horizontal" = [ ];
      "kwin"."Window Maximize Vertical" = [ ];
      "kwin"."Window Minimize" = "Meta+PgDown";
      "kwin"."Window Move" = [ ];
      "kwin"."Window Move Center" = [ ];
      "kwin"."Window No Border" = [ ];
      "kwin"."Window On All Desktops" = [ ];
      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window One Screen Down" = [ ];
      "kwin"."Window One Screen Up" = [ ];
      "kwin"."Window One Screen to the Left" = [ ];
      "kwin"."Window One Screen to the Right" = [ ];
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Pack Down" = [ ];
      "kwin"."Window Pack Left" = [ ];
      "kwin"."Window Pack Right" = [ ];
      "kwin"."Window Pack Up" = [ ];
      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
      "kwin"."Window Quick Tile Bottom Left" = [ ];
      "kwin"."Window Quick Tile Bottom Right" = [ ];
      "kwin"."Window Quick Tile Left" = "Meta+Left";
      "kwin"."Window Quick Tile Right" = "Meta+Right";
      "kwin"."Window Quick Tile Top" = "Meta+Up";
      "kwin"."Window Quick Tile Top Left" = [ ];
      "kwin"."Window Quick Tile Top Right" = [ ];
      "kwin"."Window Raise" = [ ];
      "kwin"."Window Resize" = [ ];
      "kwin"."Window Shade" = [ ];
      "kwin"."Window Shrink Horizontal" = [ ];
      "kwin"."Window Shrink Vertical" = [ ];
      "kwin"."Window to Desktop 1" = [ ];
      "kwin"."Window to Desktop 10" = [ ];
      "kwin"."Window to Desktop 11" = [ ];
      "kwin"."Window to Desktop 12" = [ ];
      "kwin"."Window to Desktop 13" = [ ];
      "kwin"."Window to Desktop 14" = [ ];
      "kwin"."Window to Desktop 15" = [ ];
      "kwin"."Window to Desktop 16" = [ ];
      "kwin"."Window to Desktop 17" = [ ];
      "kwin"."Window to Desktop 18" = [ ];
      "kwin"."Window to Desktop 19" = [ ];
      "kwin"."Window to Desktop 2" = [ ];
      "kwin"."Window to Desktop 20" = [ ];
      "kwin"."Window to Desktop 3" = [ ];
      "kwin"."Window to Desktop 4" = [ ];
      "kwin"."Window to Desktop 5" = [ ];
      "kwin"."Window to Desktop 6" = [ ];
      "kwin"."Window to Desktop 7" = [ ];
      "kwin"."Window to Desktop 8" = [ ];
      "kwin"."Window to Desktop 9" = [ ];
      "kwin"."Window to Next Desktop" = [ ];
      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
      "kwin"."Window to Previous Desktop" = [ ];
      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
      "kwin"."Window to Screen 0" = [ ];
      "kwin"."Window to Screen 1" = [ ];
      "kwin"."Window to Screen 2" = [ ];
      "kwin"."Window to Screen 3" = [ ];
      "kwin"."Window to Screen 4" = [ ];
      "kwin"."Window to Screen 5" = [ ];
      "kwin"."Window to Screen 6" = [ ];
      "kwin"."Window to Screen 7" = [ ];
      "kwin"."view_actual_size" = ",none";
      "kwin"."view_zoom_out" = "Meta+-,none";
      "mediacontrol"."mediavolumedown" = "none,,Media volume down";
      "mediacontrol"."mediavolumeup" = [ ];
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playmedia" = [ ];
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "org_kde_powerdevil"."Turn Off Screen" = [ ];
      "org_kde_powerdevil"."powerProfile" = [ "Battery" "" "Meta+B\\, ,Battery" "Meta+B,Switch Power Profile" ];
      "plasmashell"."activate task manager entry 1" = "Meta+1";
      "plasmashell"."activate task manager entry 10" = "\\, Meta+0\\, ,Meta+0,Activate Task Manager Entry 10";
      "plasmashell"."activate task manager entry 2" = "Meta+2";
      "plasmashell"."activate task manager entry 3" = "Meta+3";
      "plasmashell"."activate task manager entry 4" = "Meta+4";
      "plasmashell"."activate task manager entry 5" = "Meta+5";
      "plasmashell"."activate task manager entry 6" = "Meta+6";
      "plasmashell"."activate task manager entry 7" = "Meta+7";
      "plasmashell"."activate task manager entry 8" = "Meta+8";
      "plasmashell"."activate task manager entry 9" = "Meta+9";
      "plasmashell"."clear-history" = [ ];
      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
      "plasmashell"."cycle-panels" = "Meta+Alt+P";
      "plasmashell"."cycleNextAction" = [ ];
      "plasmashell"."cyclePrevAction" = [ ];
      "plasmashell"."manage activities" = "Meta+Q";
      "plasmashell"."next activity" = [ ];
      "plasmashell"."previous activity" = [ ];
      "plasmashell"."repeat_action" = "Meta+Ctrl+R";
      "plasmashell"."show dashboard" = "Ctrl+F12";
      "plasmashell"."show-barcode" = [ ];
      "plasmashell"."show-on-mouse-pos" = "Meta+V";
      "plasmashell"."stop current activity" = "Meta+S";
      "plasmashell"."switch to next activity" = [ ];
      "plasmashell"."switch to previous activity" = [ ];
      "plasmashell"."toggle do not disturb" = [ ];
      "services/org.kde.krunner.desktop"."RunClipboard" = [ ];
      "services/org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Search" "Meta+Space" "Alt+F2" ];
      "services/org.kde.spectacle.desktop"."OpenWithoutScreenshot" = "Meta+$";
      "services/org.kde.spectacle.desktop"."RecordWindow" = [ ];
    };
    programs.plasma.configFile = {
      "baloofilerc"."General"."dbVersion" = 2;
      "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
      "baloofilerc"."General"."exclude filters version" = 9;
      "baloofilerc"."General"."only basic indexing" = true;
      "dolphinrc"."CompactMode"."PreviewSize" = 16;
      "dolphinrc"."ContentDisplay"."UsePermissionsFormat" = "CombinedFormat";
      "dolphinrc"."DetailsMode"."PreviewSize" = 16;
      "dolphinrc"."General"."BrowseThroughArchives" = true;
      "dolphinrc"."General"."EditableUrl" = true;
      "dolphinrc"."General"."RememberOpenedTabs" = false;
      "dolphinrc"."General"."ShowFullPath" = true;
      "dolphinrc"."General"."ShowFullPathInTitlebar" = true;
      "dolphinrc"."General"."ViewPropsTimestamp" = "2024,8,4,12,48,40.991";
      "dolphinrc"."IconsMode"."IconSize" = 16;
      "dolphinrc"."IconsMode"."MaximumTextLines" = 1;
      "dolphinrc"."IconsMode"."PreviewSize" = 16;
      "dolphinrc"."IconsMode"."TextWidthIndex" = 0;
      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
      "dolphinrc"."PreviewSettings"."Plugins" = "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
      "kactivitymanagerdrc"."Plugins"."org.kde.ActivityManager.ResourceScoringEnabled" = false;
      "kactivitymanagerdrc"."activities"."bad12a74-aaab-4185-ba10-ad68fedc3f10" = "Default";
      "kactivitymanagerdrc"."main"."currentActivity" = "bad12a74-aaab-4185-ba10-ad68fedc3f10";
      "kded5rc"."Module-appmenu"."autoload" = true;
      "kded5rc"."Module-baloosearchmodule"."autoload" = true;
      "kded5rc"."Module-bluedevil"."autoload" = true;
      "kded5rc"."Module-browserintegrationreminder"."autoload" = true;
      "kded5rc"."Module-colorcorrectlocationupdater"."autoload" = true;
      "kded5rc"."Module-device_automounter"."autoload" = false;
      "kded5rc"."Module-devicenotifications"."autoload" = true;
      "kded5rc"."Module-freespacenotifier"."autoload" = true;
      "kded5rc"."Module-gtkconfig"."autoload" = true;
      "kded5rc"."Module-inotify"."autoload" = true;
      "kded5rc"."Module-kded_touchpad"."autoload" = true;
      "kded5rc"."Module-keyboard"."autoload" = true;
      "kded5rc"."Module-kscreen"."autoload" = true;
      "kded5rc"."Module-ktimezoned"."autoload" = true;
      "kded5rc"."Module-mprisservice"."autoload" = true;
      "kded5rc"."Module-plasma-session-shortcuts"."autoload" = true;
      "kded5rc"."Module-plasma_accentcolor_service"."autoload" = true;
      "kded5rc"."Module-printmanager"."autoload" = true;
      "kded5rc"."Module-remotenotifier"."autoload" = true;
      "kded5rc"."Module-smbwatcher"."autoload" = true;
      "kded5rc"."Module-statusnotifierwatcher"."autoload" = true;
      "kdeglobals"."General"."AccentColor" = "161,111,66";
      "kdeglobals"."General"."LastUsedCustomAccentColor" = "61,174,233";
      "kdeglobals"."General"."TerminalApplication" = "alacritty";
      "kdeglobals"."General"."TerminalService" = "Alacritty.desktop";
      "kdeglobals"."General"."accentColorFromWallpaper" = true;
      "kdeglobals"."KDE"."AnimationDurationFactor" = 0.125;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 140;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 0;
      "kdeglobals"."WM"."activeBackground" = "49,54,59";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeForeground" = "252,252,252";
      "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      "kiorc"."Confirmations"."ConfirmDelete" = true;
      "kiorc"."Confirmations"."ConfirmEmptyTrash" = true;
      "kiorc"."Confirmations"."ConfirmTrash" = true;
      "kiorc"."Executable scripts"."behaviourOnLaunch" = "alwaysAsk";
      "klipperrc"."General"."IgnoreImages" = false;
      "klipperrc"."General"."MaxClipItems" = 50;
      "krunnerrc"."General"."FreeFloating" = true;
      "krunnerrc"."Plugins"."baloosearchEnabled" = true;
      "kscreenlockerrc"."Daemon"."LockGrace" = 0;
      "kscreenlockerrc"."Greeter/Wallpaper/org.kde.plasma.gameoflife/General"."color" = "#009cff";
      "kscreenlockerrc"."Greeter/Wallpaper/org.kde.potd/General"."Color" = "23,199,142";
      "kscreenlockerrc"."Greeter/Wallpaper/org.kde.potd/General"."Provider" = "bing";
      "ksmserverrc"."General"."confirmLogout" = false;
      "ksmserverrc"."General"."loginMode" = "emptySession";
      "kwalletrc"."Auto Allow"."kdewallet" = "KDE System,discord,Chromium";
      "kwalletrc"."Auto Deny"."kdewallet" = "";
      "kwalletrc"."Wallet"."Close When Idle" = false;
      "kwalletrc"."Wallet"."Close on Screensaver" = false;
      "kwalletrc"."Wallet"."Default Wallet" = "kdewallet";
      "kwalletrc"."Wallet"."Enabled" = true;
      "kwalletrc"."Wallet"."First Use" = false;
      "kwalletrc"."Wallet"."Idle Timeout" = 10;
      "kwalletrc"."Wallet"."Launch Manager" = false;
      "kwalletrc"."Wallet"."Leave Manager Open" = false;
      "kwalletrc"."Wallet"."Leave Open" = true;
      "kwalletrc"."Wallet"."Prompt on Open" = true;
      "kwalletrc"."Wallet"."Use One Wallet" = true;
      "kwalletrc"."org.freedesktop.secrets"."apiEnabled" = true;
      "kwinrc"."Desktops"."Id_1" = "d574fc7b-cc5a-4428-a47b-515dceb3bb12";
      "kwinrc"."Desktops"."Id_2" = "42d13a19-2697-45f9-afe6-7ea1df914fc8";
      "kwinrc"."Desktops"."Number" = 2;
      "kwinrc"."Desktops"."Rows" = 1;
      "kwinrc"."Effect-diminactive"."DimDesktop" = true;
      "kwinrc"."Effect-diminactive"."DimPanels" = true;
      "kwinrc"."Effect-diminactive"."Strength" = 10;
      "kwinrc"."Effect-overview"."BorderActivate" = 9;
      "kwinrc"."Input"."TabletMode" = "off";
      "kwinrc"."NightColor"."Mode" = "Constant";
      "kwinrc"."Plugins"."blurEnabled" = false;
      "kwinrc"."Plugins"."contrastEnabled" = true;
      "kwinrc"."Plugins"."desktopchangeosdEnabled" = true;
      "kwinrc"."Plugins"."fadeEnabled" = true;
      "kwinrc"."Plugins"."fadingpopupsEnabled" = false;
      "kwinrc"."Plugins"."fullscreenEnabled" = false;
      "kwinrc"."Plugins"."loginEnabled" = false;
      "kwinrc"."Plugins"."logoutEnabled" = false;
      "kwinrc"."Plugins"."maximizeEnabled" = false;
      "kwinrc"."Plugins"."morphingpopupsEnabled" = false;
      "kwinrc"."Plugins"."mousemarkEnabled" = true;
      "kwinrc"."Plugins"."scaleEnabled" = false;
      "kwinrc"."Plugins"."sheetEnabled" = true;
      "kwinrc"."Plugins"."slidingpopupsEnabled" = false;
      "kwinrc"."Plugins"."squashEnabled" = false;
      "kwinrc"."Plugins"."videowallEnabled" = false;
      "kwinrc"."Plugins"."zoomEnabled" = false;
      "kwinrc"."Script-desktopchangeosd"."TextOnly" = true;
      "kwinrc"."TabBox"."LayoutName" = "compact";
      "kwinrc"."TabBox"."OrderMinimizedMode" = 1;
      "kwinrc"."TabBoxAlternative"."LayoutName" = "compact";
      "kwinrc"."Tiling"."padding" = 4;
      "kwinrc"."Tiling/0951b904-e2fe-5198-84bd-28136a2cb026"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/1b0a0e99-8b1f-56ec-8335-d71654479209"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/29e63987-17f4-5581-9473-ff060f77ca6d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/35723cc4-abaf-5b3e-be17-58dd53a366e7"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/3dfb7ac2-2e48-526c-9c30-b182f8536587"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/401e466e-478c-520c-b68c-97110699631b"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/4eae2782-af96-550e-b799-205f3f3bd083"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/513cdccf-b569-5167-8525-b68e6dc3621c"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/56045b8f-f5e1-5da2-83ba-7d195f208035"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/5e1db788-a003-5b74-af3e-f03ec3faf9a4"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/7f91c15c-2797-5e90-bb7c-5f5117ecbde5"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/92a34333-8fd8-58d0-b644-c0d9624d9a3b"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/d57bda1d-13b9-5c5f-8352-4330803037d7"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/d6672efc-6676-5b1e-ac49-e7ec56f6247d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/e18c833d-fa66-5919-9c0d-4dcd37b1a98d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/e648f5a5-0736-5504-84bf-635cc3af7868"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling/fe4b79ab-fcfd-545a-a05f-d32302fccd2f"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Wayland"."EnablePrimarySelection" = false;
      "kwinrc"."Windows"."SeparateScreenFocus" = true;
      "kwinrc"."Windows"."TitlebarDoubleClickCommand" = "Nothing";
      "kwinrc"."Xwayland"."Scale" = 1;
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft" = "MSLFN";
      "kwinrc"."org.kde.kdecoration2"."ShowToolTips" = false;
      "plasma-localerc"."Formats"."LANG" = "en_GB.UTF-8";
    };
  };
}
