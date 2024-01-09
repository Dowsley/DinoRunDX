# DinoRunDX

Original message from the Dino Run devs:

> This is the flash source code for Dino Run DX.  Have fun with it.  If you make something cool or add something to the game, contact pixeljamgames@gmail.com and tell us about it! We might just put it in the official version.
> Please don't sell anything you make with this code, unless it's totally unrecognizable from Dino Run.  
If you can go through the trouble of swapping all the art assets and make something new, sure, go ahead and sell it.  
Tell us about it though and we might just help spread the word :)
> Any questions about the code?  Email Miles at pixeljamgames@gmail.com.

## 
I managed to extract most assets from the .fla files, they are under `assets/exported`. The only assets lacking are some spritesheets from the Interface folders. To extract, you need Adobe Animate to open the .fla files. The automation scripts I used are under `scripts/`.

## Setup & Compilation

**The following guide is a slightly modified version of the one written by discord user "Minxrod". All credit goes to their amazing work of figuring out how to easily compile all this old code. All I've done was merely follow the steps to make this work as much out of the box as possible.**

This is a text tutorial on how to set up a Dino Run DX project within FlashDevelop and get it to compile correctly.
Note that this does not build with the Steam support, as far as I can tell.

I built all of this within a fully-updated Windows XP virtual machine. This should work on future versions of Windows as well - the versions used here are to guarantee that builds done through FlashDevelop still support Windows XP as the original Dino Run DX does.

Source for most of the initial setup (You shouldn't need to follow this, most of the relevant information is included here)
https://www.flashdevelop.org/community/viewtopic.php?t=13078

=== Prerequisities ===

Make sure you have a version of Java greater than 1.6 installed (pretty much any version should work, I used Java 1.8 .0_152 because I'm using an old OS.)

Having git installed is nice but not necessary.

=== FlashDevelop Setup ===
Note: that I used some older versions due to using a Windows XP VM, which struggled with newer versions. Given that the normal version of Dino Run DX works on Windows XP, I made sure to use versions that all support Windows XP for compilation.

Download FlashDevelop 5.2 from https://www.flashdevelop.org/community/viewtopic.php?f=11&t=12683&sid=f3eb0f125dac581b12e2f41660bd86b4
(direct link: http://www.flashdevelop.org/downloads/releases/FlashDevelop-5.2.0.zip)

Extract FlashDevelop to somewhere on your PC. The location doesn't matter, but you will need to visit here often during the setup.

Download the AIR SDK 29 from
https://web.archive.org/web/20180319114907/https://www.adobe.com/devnet/air/air-sdk-download.html
(direct link: https://web.archive.org/web/20180319114907/https://www.adobe.com/devnet/air/air-sdk-download-win.html)

Create the Apps/ folder within FlashDevelop/
Create the ascsdk/ folder within FlashDevelop/Apps/
Create the 29.0.0/ folder within FlashDevelop/Apps/ascsdk/

Extract the AIR SDK 29 to the folder you've created: FlashDevelop/Apps/ascsdk/29.0.0/

Copy everything in FlashDevelop/Apps/ascsdk/29.0.0/frameworks/libs/player/
to FlashDevelop/Tools/flexlibs/frameworks/libs/player/

Open FlashDevelop/Settings/Platforms/AS3/
Edit the files air.xml, airmobile.xml, and flashplayer.xml to add the line
```
    <version value="29.0" swf-version="40" />
```

Launch FlashDevelop.exe. If the main page breaks, just click "No" and disable it by going to Tools > Settings > StartPage and check "Disable". Then close and reopen FlashDevelop.

Check that Tools > Settings > AS3Context contains the AIR SDK version 29 under "Installed Flex SDKs". If it doesn't manually add the entry following the instructions under step 8 here: https://www.flashdevelop.org/community/viewtopic.php?t=13078

=== Project Setup ===

Within FlashDevelop, choose Project > New Project > AIR AS3 Projector. Set the name to Dino Run DX, set the path to be wherever you download the Dino Run DX source to. Uncheck the "Create directory for project" box, then click OK twice.

Then, go to Project > Properties and ensure that the target platform is AIR 29. If it is a different version, change it to 29.0 using the dropdown.

Next, go to assets/swcs/ and right-click on each .swc file, then select "Add to Library". Do this for all .swcs in the folder. Also do this for starling.swc if you placed it somewhere else.

Finally, go to src/base/Brain.as, right-click, and choose "Set document class". This essentially defines the entrypoint of the game.

Finally, go to 

=== Compilation ===

Open the bat/ folder and right-click on CreateCertificate.bat, then click Execute. This will take a few seconds to generate a certificate. If you care, you can change the password by editing the file SetupApp.bat first, but I don't think this really matters here.

Open SetupApp.bat and change line 16 to:
```
set SIGNING_OPTIONS=-storetype pkcs12 -keystore %CERT_FILE% -storepass %CERT_PASS% -target bundle
```
This will cause adt to build an .exe instead of a .air file.

Open application.xml and change 21.0 to 29.0, then open Brain-app.xml and change 32.0 to 29.0
```
<application xmlns="http://ns.adobe.com/air/application/29.0">
```
I honestly don't know if this was necessaary, but I did it in both successful uses of this process, so it doesn't hurt to include it.

You are now ready to build the project. Select "Build" (the gear icon) and make sure there are no errors. If there are, try again. On some of my eariler attempts at setting this up, it would take a couple tries for some reason. If it says "Build succeeded" check the bin/ folder for DinoRunDX.swf. If you see it, then the build worked, but we're not done yet.

Right-click on the PackageApp.bat script and click "Execute". This is what the certificate generated is used for. If it worked, you should see "Press any key to continue" and there should be an air/ folder containing DinoRunDX.exe.

**Note from Dowsley: After your first successful compilation, you can use the Makefile I've made. Just make the necessary modifications in its paths first.**