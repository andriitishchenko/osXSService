# osXSService
Invoke applescript on shortcuts

# !!! NEED ADD APP PERMISSIONS !!!

read more https://developer.apple.com/reference/coregraphics/1454426-cgeventtapcreate

App uses system API "CGEventTapCreate" which require user to provide app permissions:

SYSTEM PREFERENCES => Sequre & Privacy => Accessibility => Allow the apps below to control your computer.  

Otherwise it will not works.
