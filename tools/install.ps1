[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$pkgDefContent = @"

; Visual Basic
[`$RootKey`$\Projects\{F184B08F-C81C-45f6-A57F-5ABD9991F28F}\FileExtensions\.xnb]
"DefaultBuildAction"="Content"

; C#
[`$RootKey`$\Projects\{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}\FileExtensions\.xnb]
"DefaultBuildAction"="Content"

"@

$extensionBat = @'
@echo off
echo Installing..
cd "%~1"
copy "%TEMP%\MonoGame.pkgdef" "." /Y
copy /b "extensions.configurationchanged" +,, /Y
'@

$64Bit = ([System.IntPtr]::Size -eq 8)
if ($64Bit -eq $True) {
    $PFiles = ${env:ProgramFiles(x86)}
} else {
    $PFiles = $env:PROGRAMFILES
}

$Vs2010Exists = Test-Path "$PFiles\Microsoft Visual Studio 10.0"
$Vs2012Exists = Test-Path "$PFiles\Microsoft Visual Studio 11.0"

$RequiresInstall = $False

if ($Vs2010Exists -eq $True) {
  $PkgDefExists = Test-Path "$PFiles\Microsoft Visual Studio 10.0\Common7\IDE\Extensions\MonoGame.pkgdef" 
  If ($PkgDefExists -eq $False) {
    $RequiresInstall = $True
  }
}

if ($Vs2012Exists -eq $True) {
  $PkgDefExists = Test-Path "$PFiles\Microsoft Visual Studio 11.0\Common7\IDE\Extensions\MonoGame.pkgdef" 
  If ($PkgDefExists -eq $False) {
    $RequiresInstall = $True
  }
}

If ($RequiresInstall -eq $True) {
    $dialogResult = [System.Windows.Forms.MessageBox]::Show(
        "Install MonoGame file definitions for automatically marking XNB files as Content? You will need to restart Visual Studio for this change to take effect.", 
        "MonoGame", 
        [Windows.Forms.MessageBoxButtons]::YesNo,
        [Windows.Forms.MessageBoxIcon]::Question)
        
    If ($dialogResult -eq [Windows.Forms.DialogResult]::Yes) {
        $pkgDefContent | out-file "$env:TEMP\MonoGame.pkgdef"
        [System.IO.File]::WriteAllLines("$env:TEMP\MonoGame.bat", $extensionBat)
        
        if ($Vs2010Exists -eq $True) {
            $psi = new-object System.Diagnostics.ProcessStartInfo "cmd"
            $psi.Verb = "runas"
            $psi.Arguments = '/C copy "%TEMP%\MonoGame.pkgdef" "' + $PFiles + '\Microsoft Visual Studio 10.0\Common7\IDE\Extensions\MonoGame.pkgdef" & copy /b "' + $PFiles + '\Microsoft Visual Studio 10.0\Common7\IDE\Extensions\extensions.configurationchanged" +,, /Y'
            [System.Diagnostics.Process]::Start($psi)
        }

        if ($Vs2012Exists -eq $True) {
            $psi = new-object System.Diagnostics.ProcessStartInfo "cmd"
            $psi.Verb = "runas"
            $psi.Arguments = "/C $env:TEMP\MonoGame.bat ""$PFiles\Microsoft Visual Studio 11.0\Common7\IDE\Extensions"""
#            $psi.Arguments = '/C copy "%TEMP%\MonoGame.pkgdef" "' + $PFiles + '\Microsoft Visual Studio 11.0\Common7\IDE\Extensions\MonoGame.pkgdef" & copy /b "' + $PFiles + '\Microsoft Visual Studio 11.0\Common7\IDE\Extensions\extensions.configurationchanged" +,, /Y'
            [System.Diagnostics.Process]::Start($psi)
        }
    }
}