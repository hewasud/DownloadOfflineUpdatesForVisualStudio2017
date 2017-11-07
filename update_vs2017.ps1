$scriptRoot = "c:\vs2017_offline_install"
$url = "https://aka.ms/vs/15/release/vs_enterprise.exe"

$installer = "vs_enterprise.exe"
$installerPath = $scriptRoot + "\" + $installer

# Find language options from:
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio#list-of-language-locales
$includeLang = "en-US fr-FR"

# Offline installer download directory....
# This have to be in the C: Drive since apparently the VS installer will 
# not download offline install to any mapped drives....
$oliDir = $scriptRoot + "\vs2017"

cd $scriptRoot

# Remove old installer
if (Test-Path $installerPath) {
	Remove-Item $installerPath
}

wget -Uri $url -OutFile $installerPath

if (! (Test-Path $oliDir)) {
	New-Item -ItemType directory -Path $oliDir
}

# Setup download updates command for VS2017
# Offline installer options can be found here:
# https://docs.microsoft.com/en-us/visualstudio/install/create-a-network-installation-of-visual-studio
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
$composedCmd = "cmd /c " + $installerPath + " --passive --quiet --layout '" + $oliDir + "' --wait " + " --lang " + $includeLang
Write-Output $composedCmd
Invoke-Expression $composedCmd

# Cleanup offline install download directory by removing old packages
# Ensure the .Net Core 2.0 runtime environment or higher is installed.
$composedCmd = "dotnet.exe " + $scriptRoot + "\CleanupVSOfflineInstallDirectory\CleanVSOfflineInstallDirectory.dll " + $oliDir
Write-Output $composedCmd
Invoke-Expression $composedCmd

$deltaPath=$scriptRoot + "\delta_" + (Get-Date).ToString("yyyyMMdd") + ".7z"
Write-Output $deltaPath
if (Test-Path $deltaPath) {
    Remove-Item $deltaPath
}

#Assume 7z.exe is installed an in the path.
$zip = where.exe 7z.exe
$zipArgs = " a -r -t7z -y -- " + $deltaPath  + " "

$updateFiles=Get-ChildItem $oliDir | Where {$_.LastWriteTime -ge (Get-Date).AddDays(-1)}
foreach ($f in $updateFiles) {
    $composedCmd = $zip + $zipArgs + $f.FullName
    #Write-Output $composedCmd
    Invoke-Expression $composedCmd

}

Write-Output "\n\n\n\ ====>  " + $deltaPath + " <==== \n\n\n"
