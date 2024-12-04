---
# the default layout is 'page'
icon: fas fa-info-circle
order: 4
---
I decided it is time to share my personal Linux experience regarding Ubuntu ISO customization.  I'm doing so, hoping that it will be helpful to people looking to set up Ubuntu on their machines, especially rookies...  So this blog seeks to detail ways to customize Ubuntu (and maybe Debian) installs easily, as well as describe how my home networking is set up....  

### The Story so far....
Sometime around 2019, I needed to replace Windows 7 on my desktop machine, since updates would not be forthcoming after January 2020.  I had tried Windows 8 as well as Windows 10, and (well, quite frankly) I hate them all.  Windows 8 wouldn't install properly on my machine, something about unsupported drivers.  I primarily hate Windows 10 mostly because I have no control over the updating process.  I need things to remain "stable", not change simply because Microsoft decides features that I need and rely on are no longer part of the OS.  Media Center was the best example of this (not that I have cable TV anymore...), however, if I look longer, I'm sure I can find more examples to give...

I have some experience using a [Raspberry Pi 3](https://www.raspberrypi.com/products/raspberry-pi-3-model-b/), trying to use it for various household projects.  It never seemed to be enough of a machine to do the tasks I was giving it, but I mastered the Linux command-line on it.  I felt like I was ready to dive fully into the world of Linux on my personal PC....  (The Raspberry Pi 3 isn't PC-enough to try using to as a main computer, IMHO)

So I first tried [Ubuntu 18.04](https://ubuntu.com), and found that I didn't like it.  Too foreign for my tastes at the time....  I tried [XUbuntu 18.04](https://xubuntu.org), and found that with a few modifications, I could make it get it pretty close to looking like Windows 7.  This particular point was important to me, because my wife is not technologically inclined and she hates change...  But, little detail, some software I wanted on my system wasn't compatible yet with 18.04 (grumps)....  So XUbuntu 16.04 it was...
  
Now, I like to try things out.  Experiment, if you will.  Yep, I sometimes **break** my software install, so I needed a way to reinstall everything as fast as possible **OR** restore things to a working state, mostly because who in their right mind wants to spend time reinstalling and/or fixing their OS?  I find I do this on a regular basis, so finding some way to do this quickly was critical to me.  

I found several articles of interest:
- [How to Customize an Ubuntu Installation Disc – The Right Way](https://nathanpfry.com/how-to-customize-an-ubuntu-installation-disc/)
- [LiveCDCustomization - Ubuntu Documentation: Community Wiki](https://help.ubuntu.com/community/LiveCDCustomization)
- [How to create a custom Ubuntu live from scratch](https://mvallim.github.io/live-custom-ubuntu-from-scratch/)

The first two articles inspired the development of my [Modify Ubuntu Kit](https://github.com/xptsp/modify_ubuntu_kit) (MUK for short).  This toolkit allows me to customize the Ubuntu-flavored ISO that I could download any which way I pretty much wanted.

The last article revolves around bootstrapping a complete OS from scratch.  This actually helped me create a Ubuntu 24.04 ISO that will install on my machines, since the official Ubuntu 24.04 ISO crashes upon attempting to install it....  Not helpful, doncha say?  Plus, it seems [Canonical](https://canonical.com) altered the way the ISO format stores the squashfs files, so MUK no longer works easily on it.... 
