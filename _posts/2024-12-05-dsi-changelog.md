---
title: Drive Space Indicator Changelog
description: Changelog for Drive Space Indicator 
date: 2024-12-05 08:39:00 -0600
categories: [DSI]
tags: [DSI]
---

> All changelog notes before v5.2.0.0 have been lost, quite possibly permanently....
{: .prompt-info }

<div class="card categories">
	<div id="h_2" class="card-header d-flex justify-content-between hide-border-bottom">
		<span class="ms-2">
			<span class="text-muted font-weight-light">Project Changelog</span>
		</span>
	</div>
	<div id="l_2" class="collapse show" aria-expanded="true">
		<ul class="list-group">
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.0.0:</b><span class="right">Nov 23, 2008</span>
					<ul>
						<li>GUI has been reorganized.</li>
						<li>Most non-drive options moved to menu bar.</li>
						<li>Language file format completely reorganized with MANY NEW strings!</li>
						<li>Ability to browse to both RyanVM and WinCert forum threads.</li>
						<li>Ability to open browser to contact language translators.</li>
						<li>Multiple-plural language situations now able to be dealt with.</li>
						<li>About and Special Thanks now have their own dialog box and are localizable.</li>
						<li>New "60 minutes" update interval available.</li>
						<li>New "Never" update interval available (1,000,000 minutes = approx. every 2 years)</li>
						<li>Update code changed so that new language releases won't interfere with older versions.</li>
						<li>Serbian language translation was removed, as conversion script screwed it up BAD!</li>
						<li>New Inno-like installer written from the ground up.</li>
						<li>New uninstaller written from the ground up.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.1.0:</b><span class="right">Nov 23, 2008</span>
					<ul>
						<li>Fixed out-of-bounds error issue when script is paused.</li>
						<li>Fixed undefined variable error issue when user switches languages.</li>
						<li>Added COM error handler to script to try to get exception thingy to go away...</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.2.0:</b><span class="right">Nov 27, 2008</span>
 					<ul>
						<li>Reverted back to previous version of AutoIt - Should take care of Exception problem.</li>
						<li>Icons don't have box around them anymore.</li>
						<li>Czech language file has been updated, courtsey of khagaroth.</li>
						<li>Polish language file has been updated, courtsey of RedWine.</li>
						<li>French language file has been updated, courtsey of Bober101.</li>
						<li>New strings INST_4B and INST_4C resolve the issue RedWine found.</li>
						<li>New Silent installer (basically SFX installer with /SILENT instead of /INSTALL switcH)</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.2.1:</b><span class="right">Nov 28, 2008</span>
					<ul>
						<li>Fixed language string issue found by RedWine.</li>
						<li>All language updates available in v5.2.2.0 are available by way of the update functionality in the program.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.3.1:</b><span class="right">Nov 28, 2008</span>
					<ul>
						<li>- SFX "GUIMode" issue has been corrected.</li>
						<li>Fixed update issue where language file wasn't listed for updating like it should of.</li>
						<li>Serbian language has been removed from the addon INF.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.4.0:</b><span class="right">Nov 29, 2008</span>
					<ul>
						<li>Fixed situation where opened window can't be closed by program if another subwindow is opened.</li>
						<li>Made sure Serbian language file v5.1.x.x and older is deleted at install.</li>
						<li>Fixed program's formatting string function so that "%s2" actually works to swap the two parameters passed.</li>
						<li>Timer interval between updates changed to 1.5 seconds instead of immediately upon device insert/removal.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.5.0:</b><span class="right">Nov 29, 2008</span>
					<ul>
						<li>Fixed blank "Uninstall Complete" message.</li>
						<li>Fixed issue where selecting "Delete Icons on Program Exit" unchecks/checks "Start with Windows" in menu.</li>
						<li>Fixed minor issue where complete link was stored in array for update function.</li>
						<li>Fixed minor issue with edit controls on Install page 3 (Install Path) and 5 (Shortcut Path).</li>
						<li>Added code to try to make icons appear on Icon Theme tab on x64 systems.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.5.1:</b><span class="right">Nov 29, 2008</span>
					<ul>
						<li>Fixed edit fields in Installer Page 3 and 5.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.5.2:</b><span class="right">Nov 30, 2008</span>
					<ul>
						<li>"Install Complete" page modified so that all text is seen correctly.</li>
						<li>Code for "Visit Support" & "On The Web" features rewritten to support different default browsers.</li>
						<li>Added "Main_10" to language file for "No Internet Browser" message.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.5.3:</b><span class="right">Nov 30, 2008</span>
					<ul>
						<li>Reversion of code modification for Preview tab.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.6.0:</b><span class="right">Dec 1, 2008</span>
					<ul>
						<li>Installer checks language file versions to ensure latest version isn't overwritten with earlier version.</li>
						<li>Updated Italian language file, courtsey of SoftInformatica.</li>
						<li>Uncommented line responsible for opening GUI if another process is present.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.6.1:</b><span class="right"> Dec 2, 2008</span>
					<ul>
						<li>Fixed code that apparently reloaded Icon Theme list before GUI is shown.</li>
						<li>Modified installer so that files that don't exist get copied to their respective folders.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.7.0:</b><span class="right">Dec 6, 2008</span>
					<ul>
						<li>Added VistaBlack Icon Theme, courtsey of bjfrog!</li>
						<li>Modified update code so that other updates aren't available when SFX update is available.</li>
						<li>Modified GUI so that Icon Text is smaller if "Small_Text" in Language's Info section is set to Y.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.7.1:</b><span class="right">Dec 6, 2008</span>
					<ul>
						<li>Updated VistaBlack Icon Theme, courtsey of bjfrog @ WinCert.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.7.2:</b><span class="right">Dec 6, 2008</span>
					<ul>
						<li>Fixed a "Variable not declared" bug in the code.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.7.4:</b><span class="right">Dec 11, 2008</span>
					<ul>
						<li>Updated Italian language file, courtsey of softinformatica!</li>
						<li>Code fixed so that daily update checking doesn't trigger empty update box.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.7.5:</b><span class="right">Dec 12, 2008</span>
					<ul>
						<li>Fixed a problem where the drive icons weren't being assigned correctly</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.8.0:</b><span class="right">Dec 15, 2008</span>
					<ul>
						<li>Code slightly modified for custom GMail icon.</li>
						<li>MacRed and MacBlack Icon Themes added, courtsey of bjfrog!</li>
						<li>All other themes updated with GMail icon, courtsey of Bober101!</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.8.1:</b><span class="right">Dec 17, 2008</span>
					<ul>
						<li>Credit was given in the Special Thanks for the themes bjfrog created.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.2.8.2:</b><span class="right">Dec 17, 2008</span>
					<ul>
						<li>MacRed and MacBlack themes were added to INF for installation.</li>
						<li>Chinese language file updated, courtsey of yumeyao.</li>
						<li>Japanese language file updated, courtsey of yumeyao.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.0.0:</b><span class="right">Dec 22, 2008</span>
					<ul>
						<li>Update code changed to check MD5's on Icon Theme files instead of time stamps.</li>
						<li>Added code to wait routine to make sure program icon is shown when requested.</li>
						<li>Modified code to get 60 minutes and "Never" setting working properly.</li>

					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.0.1:</b><span class="right"> Dec 22, 2008</span>
					<ul>
						<li>Added code to copy missing MD5Deep.exe to program folder.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.0.2:</b><span class="right">Dec 28, 2008</span>
					<ul>
						<li>Added XPtsp Icon Theme, which is based heavily on VistaBlack theme.</li>
						<li>Modified VistaBlue Icon Theme, based heavily on VistaBlack theme.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.0.3:</b><span class="right">Dec 28, 2008</span>
					<ul>
						<li>Variables changed so that hopefully network <-> ramdisk problem is solved.</li>
						<li>Modified VistaBlack Icon Theme to eliminate 24x24 icons.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.1.0:</b><span class="right">Jan 1, 2009</span>
					<ul>
						<li>Downgraded back to previous version of AutoIt (v3.2.10.0).</li>
						<li>Replaced MD5Deep program with CabLite.DLL, which can do more and occupy less space.</li>
						<li>Internalized MD5 hashing and uncabbing functions using CabLite.DLL.</li>
						<li>Fixed installer so that all other versions of DSI are terminated before attempting to copy.</li>
						<li>Fixed update code so that Icon Theme files will download properly.</li>
						<li>Fixed the update-cycle code so that Network drives aren't shown as RamDisk drives.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.1.1:</b><span class="right">Jan 2, 2009</span>
					<ul>
						<li>Missing Icon in Blue Icon Theme has been included.</li>
						<li>Missing Icon in MacBlack and MacRed themes have been included.</li>
						<li>New MacGray theme has been included.</li>
						<li>Add-Ons fixed so that MD5Deep program was replaced by cablite.dll.</li>
						<li>New Icon Themes included in Add-Ons.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.1.2:</b><span class="right">Jan 3, 2009</span>
					<ul>
						<li>Icon Theme tab modified so that icons are pulled with negative numbers instead of positive for x64 users only.</li>
						<li>"/NOISO" cmd-line option has been removed</li>
						<li>Virtual drive detection has been removed</li>
						<li>A new line in language file was added to clarify if beta or public release is available.</li> 
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.1.3:</b><span class="right">Jan 5, 2009</span>
					<ul>
						<li>Minor change to SFX installer so that /SVCPACK doesn't launch DSI during setup, but will place registry entry. v5.3.1.2 had it backwards.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.1.4:</b><span class="right">Jan 6, 2009</span>
					<ul>
						<li>Fixed "/THEME" switch so that it works.</li>
						<li>Fixed help message/error message regarding cmd-line switches so that it's readable.</li>
						<li>Fixed Drives tab so that drive icon shows up on that tab.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.2.0:</b><span class="right">Jan 8, 2009</span>
					<ul>
						<li>Wait for CPU Idle percentage > 90% before running 1st loop.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.0:</b><span class="right">Jan 8, 2009</span>
					<ul>
						<li>Installer writes settings to registry before exiting.</li>
						<li>Shortcuts gets created in Start Menu.</li>
						<li>Added "/NOIDLE" to disable CPU Idle loop.</li>
						<li>Added "/IDLE:[n]" to adjust CPU Idle percentage.</li>
						<li>Added "/NOSC" to disable shortcut creation.</li>
						<li>Added "/SC" to default shortcuts to "Drive Space Indicator" folder.</li>
						<li>Added "/SC:[n]" to put shortcuts in specific folder.</li>
						<li>CPU Idle parameter stored in registry for future use - not changable in GUI yet.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.1:</b><span class="right">Jan 8, 2009</span>
					<ul>
						<li>Credit for MacGray Icon Theme by BjFrog added to Special Thanks box.</li>
						<li>Credit for CabLite.DLL by Code65536 added to Special Thanks box.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.2:</b><span class="right">Jan 9, 2009</span>
					<ul>
						<li>/LIBICON and /PROGTRAY switches should work as expected.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.3:</b><span class="right">Jan 10, 2009</span>
					<ul>
						<li>When update time is set to Never, Program tray only shows program name.</li>
						<li>Added "/DELAY:[n]" parameter, where [n] is the number of minutes to wait before starting cycles.</li>
						<li>"/IDLE:[n]" and "/NOIDLE" parameters removed because they were ineffective at solving the Explorer crash.</li>
						<li>Added line "MENU_2I" for "Delay At Startup" menu group.</li>
						<li>Added "Delay At Startup" menu group under "Options" menu.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.4:</b><span class="right">Jan 10, 2009</span>
					<ul>
						<li>Rebuilt program icon so that lower resolutions are pretty like the 48x48 icon.</li>
						<li>Modified interval checking code so that updates get checked when update interval is set to "Never".</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.5:</b><span class="right">Jan 12, 2009</span>
					<ul>
						<li>Wrote shortcut folder to registry so program doesn't forget when updating.</li>
						<li>Fixed interval loop so Update checking code doesn't get called repeatedly.</li>
						<li>Added Update checking code to Interval Paused loop.</li>
						<li>Updated Italian language file, courtsey of softinformatica! Thanks!</li>
						<li>Fixed an issue with Update checking code to keep program from crashing.</li>

					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.3.7:</b><span class="right">Jan 13, 2009</span>
					<ul>
						<li>Fixed the launch command throughout the code.</li>
						<li>Fixed the code creating the uninstall shortcut to use "/REMOVE" instead of "/UNINSTALL".</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.4.0:</b><span class="right">Jan 15, 2009</span>
					<ul>
						<li>Last update setting removed before running installer via Updates code.</li>
						<li>Updated VistaBlack Icon Theme, courtesy of bjfrog @ WinCert.</li>
						<li>Updated Blue Icon Theme, courtesy of bjfrog @ WinCert.</li>
						<li>Moved next update calculation to Update GUI builder function for speed-up.</li>
						<li>Modified interval loop so that next update date isn't constantly checked if auto updates isn't checked.</li>
						<li>Fixed uninstall shortcut creation by using shortcut creation function correctly.</li>
						<li>Fixed shortcut creation code so that "/NOSC" doesn't create shortcuts.</li>
						<li>Fixed uninstall hanging issue during closing other process.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.4.1:</b><span class="right">Jan 15, 2009</span>
					<ul>
						<li>Removed all 24x24 icons from Vista theme.</li>
						<li>Updated Blue theme with network icon with X indicating no access (icon #15)</li>
						<li>Updated VistaBlack theme with network icon with X indicating no access (icon #15)</li>
						<li>Replaced black icons in VistaBlue theme with VistaBlack icons because they look better.</li>
						<li>Rearranged menu so that all checkable options are in one menu and all commands are in another.</li>
						<li>Added "Menu_2I1" to replace "Delay At Startup" setting "Never" with "None".</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.5.0:</b><span class="right">Feb 28, 2009</span>
					<ul>
						<li>Web site has been changed to http://xptsp.filetap.com/</li>
						<li>Updating code has been changed to reflect new web site address.</li>
						<li>Visit Site code has been changed to reflect new web site address.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.5.1:</b><span class="right">Feb 28, 2009</span>
					<ul>
						<li>Re-included language files.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.5.2:</b><span class="right">Mar 7, 2009</span>
					<ul>
						<li>Made sure install folder is explicitly created.</li>
						<li>Modified install function to copy CABLITE.DLL to install folder.</li>
						<li>Modified code so that proper variable is used for checking minute parameter.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.5.3:</b><span class="right">Mar 15, 2009</span>
					<ul>
						<li>Updated French translation, courtsey of mooms</li>
						<li>Updated Czech translation, courtsey of khagaroth</li>
						<li>Updated Dutch translation, courtsey of Acheron</li>
						<li>Edited Dutch license translation, courtsey of FixIt on WinCert forum.</li>
						<li>Updated German translation, courtsey of kHaN</li>
						<li>Modified command switches to write settings to registry for future use.</li>
						<li>Added "/NOTRAY" to perform same task as "/PROGTRAY:0"</li>
						<li>Added "/NOLIBICON" to perform same task as "/LIBICON:0"</li>
						<li>Moved storage of "Delay At Startup" parameter to registry.</li>
						<li>Default setting for "Delay At Startup" is now 2 minutes.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.5.4:</b><span class="right">April 16, 2009</span>
					<ul>
						<li>Added new command-line parameter "/STARTUP" to deal with delay at system startup.</li>
						<li>Removed general delay at program startup.</li>
						<li>Altered installer and GUI to add new parameter when writing value to registry.</li>
						<li>Fixed how the code generates it's Run entry in the registry.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.6.0:</b><span class="right">Aug 23, 2009</span>
					<ul>
						<li>Updated AutoIt to latest stable release (again... urgh!)</li>
						<li>Updated Russian language file, courtsey of courtesy of Ruslan A. Kuzmenkov.</li>
						<li>Rewrote PNP detection for mass-storage drives.</li>
						<li>Removed code dealing with virtual drive detection.</li>
						<li>Modified code to help 32-bit Explorer running on 64-bit OS show icons properly.</li>
						<li>Updated links in About menu to point to proper URLs.</li>
						<li>Modified code so that message boxes are linked to GUI.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.6.1:</b><span class="right">Aug 23, 2009</span>
					<ul>
						<li>Sorted Drive list on the Drives tab in GUI.</li>
						<li>Restored PNP detection code with minor modification.</li>
						<li>Added check to make sure drive is ready before creating tray icon.</li>
						<li>Removed ability to create tray icon for floppy drives.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.6.2:</b><span class="right">Aug 23, 2009</span>
					<ul>
						<li>Code for ComSel modified so that Component array is populated.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.6.3:</b><span class="right">Aug 23, 2009</span>
					<ul>
						<li>Finally eliminated floppy drive grind.</li>
						<li>Fixed a problem with the PNP array when inserting new hardware.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.6.4:</b><span class="right">Aug 24, 2009</span>
					<ul>
						<li>Reverted PNP detection code back to pre-v5.3.6.0.</li>
						<li>Modified code to search for icon theme if one hasn't been selected.</li>
						<li>Redetect Drive Types code modified to relaunch GUI after redetection.</li>
						<li>All floppy grinds seem to be gone.</li>
						<li>Removable devices are detected as removable instead of floppy drives.</li>
						<li>Component Selection page has been removed from install process.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.7.2:</b><span class="right">Oct 9, 2009</span>
					<ul>
						<li>Both SFX and Silent Installer now require Admin priviledges to install.</li>
						<li>Updated code to work with latest version of AutoIt (v3.3.6.0).</li>
						<li>Updated ModernMenu code to work better with Vista and Windows 7 x64 editions.</li>
						<li>Added code so that tray icons will reappear if Windows shell (Explorer) crashes.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.7.3:</b><span class="right">Oct 12, 2009</span>
					<ul>
						<li>Updated uninstaller to remove registry settings for drive icons.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.7.4:</b><span class="right">Oct 23, 2009</span>
					<ul>
						<li>Renamed SVCPACK filename from DriveSpace.exe to DriveSpc.exe.</li>
						<li>Delete Start Menu shortcuts upon Uninstall.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.7.5:</b><span class="right"> Oct 24, 2009</span>
					<ul>
						<li>Corrected bug that causes installer to start up when DSI launches normally.</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted font-weight-light">
					<b>v5.3.7.6:</b><span class="right">Sept 7, 2009</span>
					<ul>
						<li>Updated Explorer refresh code so that it works with Windows 7.</li>
						<li>Fixed shortcut creation issue that was found in 5.3.7.5.</li>
						<li>Removed Uninstall shortcut for Vista and later operating systems.</li>
					</ul>
				</span>
			</li>
		</ul>
	</div>
</div>
