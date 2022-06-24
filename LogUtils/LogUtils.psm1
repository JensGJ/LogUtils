<#

.SYNOPSIS

Moves one or more logfiles to an archive destination
(adding a datetime stamp to the archived file name)
The function supports -WhatIf and -Confirm
.DESCRIPTION

The function may be used to create rolling log files where the
application generating the log is not able to do this automatically.
Creation of new logfiles are left to the logging application

.PARAMETER logPath
Specifies the path to search for log files.

.PARAMETER archivePath
    Specifies the path used to save archived log files in.

.PARAMETER logExtension
    Specifies the extension of log files to search for. ".log" is the default.

.PARAMETER dateFormat
    Specifies the date format that will be postfixed to the archived log files. Default is "yyyy-MM-dd_HHmm".



.EXAMPLE

PS> Backup-Logfile -logPath logs -archivePath archive

Move logfiles from subdirectory logs to subdirectory
(adding the default timestamp to the filename)

.EXAMPLE

PS> Backup-Logfile -logPath .\logtest\ -archivePath .\archive -WhatIf

Show what would happen if we would move log files from .\logtest til .\archive


.EXAMPLE

PS> Backup-Logfile .\log2\myfile.log -archivePath .\archive\

Move a single log file to an archive directory (adding the default timestamp to the filename)


.EXAMPLE

Backup-Logfile C:\Logs\ -archivePath C:\Backup\ -dateFormat "yyyy-MM-dd_HHmmss"

Move log files from C:\Logs to C:\Backup using a custom dateformat (adding seconds to the file name)

#>
function Backup-Logfile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeLine=$True)]
        [string] $logPath,

        [Parameter(Mandatory=$True)]
        [string] $archivePath,

        [Parameter(Mandatory=$False)]
        [string] $logExtension = ".log",

        [Parameter(Mandatory=$False)]
        [string] $dateFormat= "yyyy-MM-dd_HHmm"


    )

begin{
    # Validate all but the logpath (since this might be provided in the pipeline)
# Check that the given archivepath is a valid and existing directory
if (-not ((Test-Path $archivePath) -and  (Get-Item $archivePath).psiscontainer)) {
    $errMessage = "{0} is not a valid directory!" -f $archivePath;
    throw $errMessage;
}

$totalFileCount = 0;
$numberOfLogPaths = 0;


# Store resolved paths for later display
$archivePathResolved = (Resolve-Path $archivePath).Path

# Define date format added as a postfix to each log file
$datestamp = (get-date).ToString($dateFormat);


}
process{
$numberOfLogPaths+=1;


    # Validate logPath:
    # Check that the given logpath is valid
if (-not (Test-Path $logPath))  {
    $errMessage = "{0} not found (invalid logPath)!" -f $logPath;
    throw $errMessage;
}
# Check that archivepath is not the same as logpath

if ((Resolve-Path $logPath -Relative) -eq (Resolve-Path $archivePath -Relative)){
    $errMessage = "logPath and archivePath must be different directories"
    throw $errMessage;
}
# If logPath is a file and the extension does not match logExtension, require user confirm
$logObject = Get-Item $logPath

if ((-not $logObject.psiscontainer) -and ($logObject.extension -ne $logExtension)){
    Write-Warning "LogPath/logextension mismatch"
    $ConfirmPreference = "Medium";
}

# Store resolved paths for later display
$logPathResolved = (Resolve-Path $logPath).Path

# Find all logfiles
$filter = ("*{0}" -f $logExtension);
$filesToCopy = Get-ChildItem -Path $logPath -filter $filter

# Check if there is anything to move
if ($null -eq $filesToCopy) {
    $errMessage = "No logfiles found! ($logpath / $logExtension)";
    Write-Warning $errMessage | Out-Default;
}

foreach ($file in $filesToCopy) {
    $newname = "{0}_{1}{2}" -f $file.BaseName, $datestamp, $file.Extension
    $newpath = Join-Path -Path $archivePath -ChildPath $newname
    try{
       	Move-Item $file.fullname $newpath -WhatIf:$WhatIfPreference -Verbose -ErrorAction Stop
    }
    catch{
        $newname = "{0}_{1}({3}){2}" -f $file.BaseName, $datestamp, $file.Extension, $numberOfLogPaths
        $newpath = Join-Path -Path $archivePath -ChildPath $newname
       	Move-Item $file.fullname $newpath -WhatIf:$WhatIfPreference -Verbose
    }

}

# Print info
# TODO: Write text to powershell log
Write-Output  ("Moved {0} {3} file(s) from {4} to {1} using the datestamp {2}" -f $filesToCopy.count, $archivePathResolved, $datestamp, $logExtension, $logPathResolved) | Out-Default;

$totalFileCount+=$filesToCopy.count;
}
end{
    Write-Output ("In total: Moved {0} files from {1} logpaths" -f $totalFileCount, $numberOfLogPaths)
}











}



# Remove-Logfile

<#

.SYNOPSIS

Purge (delete) logfiles older than a specified threshold value
(a number of days).
The function supports -WhatIf and -Confirm

.DESCRIPTION

The function may be used to delete old logfiles based on the
last modified date (lastwritetime)


.PARAMETER logPath
Specifies the path to search for log files.

.PARAMETER numberofDaystoKeepFiles
Specifies how many days to keep logfiles. Default is 30 days.

.PARAMETER logExtension
Specifies the extension of log files to search for. ".log" is the default.

.PARAMETER recurse
Deletes log files recursively


.EXAMPLE

PS> Remove-Logfile -logPath logs

Delete logfiles from the subdirectory logs using the default values for
file type (.log) and retention (30 days).

.EXAMPLE

PS> Remove-Logfile -logPath C:\Logs -numberofDaystoKeepFiles 10

Delete logfiles last modified more than 10 days ago from the directory C:\Logs


.EXAMPLE

PS> Remove-Logfile -logPath logs -numberofDaystoKeepFiles 10  -WhatIf

Do a test run of the previous example.


.EXAMPLE

PS> Remove-Logfile -logPath C:\Logs\ -logExtension .txt -numberofDaystoKeepFiles 7

Delete .txt files older than 7 days from the directory C:\Logs\.


#>

Function Remove-Logfile {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory=$True, ValueFromPipeLine=$True)]
		[string]
		$logPath,

		[Parameter(Mandatory=$False)]
		[int]
		$numberofDaystoKeepFiles = 30,

        [Parameter(Mandatory=$False)]
        [string] $logExtension = ".log",

		[Parameter(Mandatory=$False)]
		[switch]
		$recurse
	)

begin{
$thresholdDate = (get-date).AddDays(-1 * $numberofDaystoKeepFiles)
$minThreshold = 2

# Do not allow deleting files modified less than the minimum threshold number of days ago
if ($numberofDaystoKeepFiles -lt $minThreshold)
{
	$errMessage = ("Invalid threshold. Parameter numberofDaystoKeepFiles ({0}) is less than the allowed mininum threshold ({1})" -f $numberofDaystoKeepFiles, $minThreshold);
	throw $errMessage;
}

$numberOfLogPaths = 0;
$totalFileCount = 0;

}
process{

$numberOfLogPaths+=1;
# Validate input:

# Path has to be valid
if (-not (Test-Path $logPath))
{
	throw "$logPath not found"
}


# Find files to delete
$filter = ("*{0}" -f $logExtension);
$filesToDelete = Get-ChildItem -Path $logPath -filter $filter -Recurse:$recurse |  Where-Object LastWriteTime -lt $thresholdDate;

$pathInfo = (Resolve-Path $logPath).Path

if ($recurse){
	$pathInfo += " (with recurse)";
}

$infoMessage = "Search for {0} files in {1} with lastwritetime older than {2} ({3} days) found {4} file(s)" -f $logExtension, $pathInfo, $thresholdDate, $numberofDaystoKeepFiles, $filesToDelete.count

if ($WhatIfPreference){
	$infoMessage = "What if: " + $infoMessage;
}

Write-Output $infoMessage;


# Delete files:
$filesToDelete | Remove-Item -WhatIf:$WhatIfPreference -Verbose

$totalFileCount+=$filesToDelete.count;
}
end {
    Write-Output ("Deleted {0} file(s) from {1} destination(s)" -f $totalFileCount, $numberOfLogPaths)
}

}

