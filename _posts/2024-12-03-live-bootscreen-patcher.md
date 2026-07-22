---
title: Live Bootscreen Patcher
description: Customize your Windows XP Boot Screen 
date: 2024-12-03 08:39:00 -0600
categories: [LBS]
tags: [LBS]
image:
  path: /assets/img/lbs/Logo_LBS.webp
  lqip: data:image/webp;base64,UklGRjwAAABXRUJQVlA4IDAAAADQAgCdASoYAA4AP3Ggxli/q6ejsAgD8C4JQBWABaSAAP7qkByJsKEIetW27MmAAAA=
force_url: /tags/lbs/
pin: true
---

Live Boot Screen Patcher will make a backup of your existing kernel files and modify them according to the color pallet from the (4bit, 16 color) boot screen used.

Each time you change your boot screen the backup will be used to be sure a clean kernel will be modified.  In case of a restore, the backup will be restored to make sure the kernels are as the were before using the program. 

<table>
  <tr>
    <td><a href="/assets/img/lbs/lbs_1.png" class="popup img-link"><img alt="lbs_1" data-src="/assets/img/lbs/lbs_1.png" height="332" width="256" data-lqip="true" src="data:image/webp;base64,UklGRoAAAABXRUJQVlA4WAoAAAAQAAAAFwAAEQAAQUxQSBgAAAABD9D/iAgQSNpsvPijPd8TRPQ/w6QcpWFWUDggQgAAALADAJ0BKhgAEgA/aZzCWLO/pyO39VgD8C0JZwAAHCN6+AlENSiAAP0blXPhaJ8qwJYeIJDhwCU3/Go17F8WIBAAAA=="></a></td>
    <td><a href="/assets/img/lbs/lbs_2.png" class="popup img-link"><img alt="lbs_2" data-src="/assets/img/lbs/lbs_2.png" height="332" width="256" data-lqip="true" src="data:image/webp;base64,UklGRpYAAABXRUJQVlA4WAoAAAAQAAAAFwAAEQAAQUxQSC8AAAABL6AgbQPGv+p2R0REJAcFkW1aRwQiEEEF+rfyvgEi+h+drgIA7NfCpvg+Zx/6CgBWUDggQAAAALADAJ0BKhgAEgA/XZLAWL+qJyO3+qgD8CuJZwAAK5EUBth5eVAAAP0blXPhnr91qSsItvPLs/ejePYeQMBAAAA="></a></td>
    <td><a href="/assets/img/lbs/lbs_3.png" class="popup img-link"><img alt="lbs_3" data-src="/assets/img/lbs/lbs_3.png" height="332" width="256" data-lqip="true" src="data:image/webp;base64,UklGRkYAAABXRUJQVlA4IDoAAAAQAwCdASoYABMAP3GmyFi/rSijsAgD8C4JYwDKtCswCAAA/uJ5fkZp8Wdq6nE1oWVgpX9U+sLz2AAA"></a></td>
  </tr>
</table>

Requirements:
- Windows XP (x86) only (All Bootscreens are tested on an XP Professional Service Pack 3)
- Languages: all

Containing:
- Green, Blue, Red, and Purple Vista-like bootscreens.
- The ability to patch your kernel with a custom bootscreen
- The ability to patch your kernel in a XP-CD Source with a custom bootscreen

----

## Downloads

<table width="100%">
	<tr>
		<td width="130">
			<a href="https://github.com/xptsp/LBS-by-Fixit/raw/refs/heads/main/LBS-Patcher.v2.4.exe"><img alt="Download" data-src="/assets/img/lbs/Logo_LBS.webp" width="100" height="100" data-lqip="true" src="data:image/webp;base64,UklGRgYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSK4AAAAFuQpE9D8skiLJtm3lgR/8mwEnf85+HnJUe3RaQ8QETMC3P3zlC/z2y/X8wwfyfpdkzi0zK7Xs9GwP7zR2KMZEbAyR2BbWxkQ5x4wtKzoN5jLxSuwys+bZkrh4rKH1WH5pH1ibZ0TrYplPWwt3NFrTWmvaT3JsWXNct5F8PoO7mugw5tCEnIdhaxJhw1psjjkPsWFyXCO8bBjBMpU213NZiKptrrWmtfQ6zcw5pQJWUDggMgAAABADAJ0BKhgAGAA/cbLQYDSuKaWoCAKQLgljAMwcFtsNAAD+7HDcpty9UxJWmX9sIAAA"></a>
		</td>
		<td>
			<strong>Link:</strong> <a href="https://github.com/xptsp/LBS-by-Fixit/raw/refs/heads/main/LBS-Patcher.v2.4.exe">LBS-Patcher.v2.4.exe</a><br />
			<strong>MD5:</strong> eddfebfbdc18ece1e0061b2285cfc079<br />
			<strong>SHA256:</strong> 6a86a324315b3dab9371033a405d344b34f21547648c9ac45a422f5ac67b136b
		</td>
	</tr>
</table>

----

## How to make your own bootscreen

To make a custom bootscreen, you'll need an imaging program which can index .bmp's to 4bit (16 colors).

For example you can use "Gimp" (Freeware). Since we used this software, the rest of this tutorial and the steps described below are based on Gimp.</p>

- First, you'll need two sample bitmaps (background & progress bar) which you can later modify. These .bmp files can be obtained by clicking on the "Get BMP's" button in the LBS Patcher or through an sample .lbs file (extract with eg. 7-Zip). You can save them anywhere you like.
- Now, open the .bmp files in Gimp and open the color map (Windows > Dockable dialogs). If you like, you can change the colors in the pallet a bit, but you can not add colors. 16 is the maximum! Also the first color has to be black (value: 000000).
- After modifying, you'll have to save the two files. Save the background image as 'BG.bmp' and the progress bar image as 'PB.bmp'. If you have multiple layers, please merge them when saving to keep the correct color pallet. The BG.bmp should have a resolution of 640x480.
- Go to the location where you saved the images and zip the BG.bmp and PB.bmp files together. You can name this file whatever you like, as long as it has this composition: "anyname_boot.zip". (You can zip, rar or 7z the 2 bitmap's and even rename it to"anyname_boot.lbs" if you like, but all will work "anyname_boot.zip, rar,7z")

Now you can select "Custom Bootscreen" in the patcher and locate your "anyname_boot.zip" file!!

----

## Changelog

<div class="card categories">
	<div id="h_1" class="card-header d-flex justify-content-between hide-border-bottom">
        <span class="ms-2">
			<i class="far fa-folder-open fa-fw"></i>
			<span class="text-muted small font-weight-light">Changelog:</span>
		</span>
		<a href="#l_1" data-bs-toggle="collapse" aria-expanded="true" aria-label="h_2-trigger" class="category-trigger hide-border-bottom">
			<i class="fas fa-fw fa-angle-down"></i>
		</a>
	</div>
	<div id="l_1" class="collapse show" aria-expanded="true">
		<ul class="list-group">
			<li class="list-group-item">
				<span class="text-muted small font-weight-light">
					v2.4
					<ul>
						<li>updated the uninstaller</li>
						<li>new setup installer (inno setup)</li>
						<li>added checks for kernel Update's or Downgrades (to make a new backup)</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted small font-weight-light">
					v2.3
					<ul>
						<li>Fixed bootscreen fade-in at XP start</li>
						<li>Major patching speedup</li>
						<li>added a button to check for update/bootscreens (navigates to the default browser)</li>
						<li>repairs a bug from v2.2</li>
						<li>minor script fixes and updates</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted small font-weight-light">
					v2.2
					<ul>
						<li>The ability to patch your kernel in a XP-CD Source with a custom bootscreen</li>
						<li>Added some skins</li>
						<li>Some minor error fixes</li>
					</ul>
				</span>
			</li>
			<li class="list-group-item">
				<span class="text-muted small font-weight-light">
					v2.1
					<ul>
						<li>auto-change the colors from the 4bit pallet in the kernel to the 4bit color pallet used in the bitmap.</li>
						<li>redone all bootscreen bitmaps and hex edited them to make them visible.</li>
						<li>added red and purple XPtsp bootscreens</li>
						<li>added preview popup window (tnx Dougiefresh)</li>
						<li>new way to use custom bootscreens via zipped bitmaps from any provided location.</li>
						<li>added checks to make sure correct bitmaps are being used.</li>
						<li>added a get sample button.</li>
						<li>multi lang support.</li>
					</ul>
				</span>
			</li>
		</ul>
	</div>
</div>
