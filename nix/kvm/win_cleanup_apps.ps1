### Remove extra apps from Windows 10

# In a terminal with administrator permissions, run:
# $ powershell -NoProfile -ExecutionPolicy Bypass -File win_cleanup_apps.ps1

# Sources:
# <https://cryptoyeti.com/?p=3019>
# <https://cryptoyeti.com/?p=3019>
# <https://www.digitalcitizen.life/how-remove-default-windows-10-apps-powershell-3-steps>
# <https://www.tweakhound.com/2020/12/07/win10-uninstall-apps-via-powershell>

Get-AppxPackage -AllUsers *3dbuilder* | Remove-AppxPackage
Get-AppxPackage -AllUsers *3dviewer* | Remove-AppxPackage
Get-AppxPackage -AllUsers *acg* | Remove-AppxPackage
Get-AppxPackage -AllUsers *alarms* | Remove-AppxPackage
Get-AppxPackage -AllUsers *ActiproSoftwareLLC* | Remove-AppxPackage
Get-AppxPackage -AllUsers *AdobeSystemsIncorporated.AdobePhotoshopExpress* | Remove-AppxPackage
Get-AppxPackage -AllUsers *CandyCrush* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Duolingo* | Remove-AppxPackage
Get-AppxPackage -AllUsers *EclipseManager* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Facebook* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Flipboard* | Remove-AppxPackage
Get-AppxPackage -AllUsers *HiddenCityMysteryofShadows* | Remove-AppxPackage
Get-AppxPackage -AllUsers *HuluLLC.HuluPlus* | Remove-AppxPackage
Get-AppxPackage -AllUsers *king.com.FarmHeroesSaga* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10* | Remove-AppxPackage  # Cortana offline
Get-AppxPackage -AllUsers Microsoft.BingNews* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.BingWeather* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.DesktopAppInstaller* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Getstarted* | Remove-AppxPackage
# Get-AppxPackage -AllUsers Microsoft.HEIFImageExtension* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Microsoft3DViewer* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MicrosoftSolitaireCollection* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MicrosoftStickyNotes* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.MixedReality.Portal* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Office.OneNote* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.People* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Print3D* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.ScreenSketch* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Microsoft.SkypeApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.SkypeApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.VCLibs.140.00* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.VP9VideoExtensions* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Wallet* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WebMediaExtensions* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WebpImageExtension* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsAlarms* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsCalculator* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsCamera* | Remove-AppxPackage
Get-AppxPackage -AllUsers microsoft.windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsFeedbackHub* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsMaps* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Windows.Photos* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsSoundRecorder* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.WindowsStore* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.XboxApp* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.XboxGameOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.XboxIdentityProvider* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.XboxSpeechToTextOverlay* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.Xbox.TCUI* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.YourPhone* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.ZuneMusic* | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.ZuneVideo* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Netflix* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Pandora* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Plex* | Remove-AppxPackage
Get-AppxPackage -AllUsers *ROBLOXCORPORATION.ROBLOX* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Spotify* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Twitter* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Wunderlist* | Remove-AppxPackage
Get-AppxPackage -AllUsers *bingfinance* | Remove-AppxPackage
Get-AppxPackage -AllUsers *bingnews* | Remove-AppxPackage
Get-AppxPackage -AllUsers *bingsports* | Remove-AppxPackage
Get-AppxPackage -AllUsers *bingweather* | Remove-AppxPackage
Get-AppxPackage -AllUsers *camera* | Remove-AppxPackage
Get-AppxPackage -AllUsers *communications* | Remove-AppxPackage
Get-AppxPackage -AllUsers *dolbyaccess* | Remove-AppxPackage
Get-AppxPackage -AllUsers *fitbitcoach* | Remove-AppxPackage
Get-AppxPackage -AllUsers *getstarted* | Remove-AppxPackage
Get-AppxPackage -AllUsers *maps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *messaging* | Remove-AppxPackage
Get-AppxPackage -AllUsers *officehub* | Remove-AppxPackage
Get-AppxPackage -AllUsers *onenote* | Remove-AppxPackage
Get-AppxPackage -AllUsers *people* | Remove-AppxPackage
Get-AppxPackage -AllUsers *photos* | Remove-AppxPackage
Get-AppxPackage -AllUsers *phototastic* | Remove-AppxPackage
Get-AppxPackage -AllUsers *picsart* | Remove-AppxPackage
Get-AppxPackage -AllUsers *plex* | Remove-AppxPackage
Get-AppxPackage -AllUsers *skypeapp* | Remove-AppxPackage
Get-AppxPackage -AllUsers *solitairecollection* | Remove-AppxPackage
Get-AppxPackage -AllUsers *soundrecorder* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowsalarms* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowscalculator* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowscamera* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowsmaps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *windowsphone* | Remove-AppxPackage
Get-AppxPackage -AllUsers *xboxapp* | Remove-AppxPackage
Get-AppxPackage -AllUsers *xbox* | Remove-AppxPackage
Get-AppxPackage -AllUsers *zunemusic* | Remove-AppxPackage
Get-AppxPackage -AllUsers *zunevideo* | Remove-AppxPackage
