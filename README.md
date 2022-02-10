# LogUtils
Powershell Module to work with log files

## Installation
LogUtils may be installed from [PSGallery](https://www.powershellgallery.com/packages/LogUtils/)

```powershell
Install-Module -Name LogUtils
```

## Usage

```powershell

# Move .log files from C:\Logs to C:\Archive, adding a default timestamp to the file name
Backup-Logfile -logPath "C:\Logs" -archivePath "C:\Archive\"

# Remove .log files that haven't been modified in the last 10 days from C:\Archive
Remove-Logfile -logPath -archivePath "C:\Archive\" -numberofDaystoKeepFiles 10

```
