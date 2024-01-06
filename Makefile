all: compile run

run:
	.\air\DinoRunDX.air\DinoRunDX.exe

compile:
	"C:\Program Files\FlashDevelop-5.2.0\Tools\fdbuild\fdbuild.exe" "C:\Users\joaod\Desktop\Code\DinoRunDX\Dino Run DX.as3proj" -ipc 59a23fb3-cf36-4d14-a768-471990df8bb6 -version "29.0.0" -compiler "C:\Program Files\FlashDevelop-5.2.0\Apps\ascsdk\29.0.0" -library "C:\Program Files\FlashDevelop-5.2.0\Library"
	bat\PackageApp.bat