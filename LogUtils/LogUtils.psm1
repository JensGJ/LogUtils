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


.EXAMPLE<

PS> Backup-Logfile -logPath .\logtest\ -archivePath .\arkiv\ -WhatIf

#>
function Backup-Logfile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$True)]
        [string] $logPath,
        
        [Parameter(Mandatory=$True)]
        [string] $archivePath,
        
        [Parameter(Mandatory=$False)]
        [string] $logExtension = ".log",

        [Parameter(Mandatory=$False)]
        [string] $dateFormat= "yyyy-MM-dd_HHmm"

                        
    )

# Check that the given logpath is a valid and existing directory
if (-not (Test-Path $logPath))  {
    $errMessage = "{0} not found (invalid logPath)!" -f $logPath;
    throw $errMessage;
}

# Check that the given archivepath is a valid and existing directory
if (-not ((Test-Path $archivePath) -and  (Get-Item $archivePath).psiscontainer)) {
    $errMessage = "{0} is not a valid directory!" -f $archivePath;
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
$archivePathResolved = (Resolve-Path $archivePath).Path


# Define date format added as a postfix to each log file
$datestamp = (get-date).ToString($dateFormat);


# Find all logfiles
$filter = ("*{0}" -f $logExtension);
$filesToCopy = Get-ChildItem -Path $logPath -filter $filter

# Check if there is anything to move
if ($null -eq $filesToCopy) {
    $errMessage = "No logfiles found! ($logpath / $logExtension)";
    throw $errMessage;
}

foreach ($file in $filesToCopy) {
    $newname = "{0}_{1}{2}" -f $file.BaseName, $datestamp, $file.Extension
    $newpath = Join-Path -Path $archivePath -ChildPath $newname
   	Move-Item $file.fullname $newpath -WhatIf:$WhatIfPreference
}

# Print info
# TODO: Write text to powershell log
Write-Output  ("Moved {0} {3} file(s) from {4} to {1} using the datestamp {2}" -f $filesToCopy.count, $archivePathResolved, $datestamp, $logExtension, $logPathResolved);
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


.PARAMETER path
Specifies the path to search for log files.

.PARAMETER numberofDaystoKeepFiles
Specifies how many days to keep logfiles. Default is 30 days.

.PARAMETER logExtension
Specifies the extension of log files to search for. ".log" is the default.

.PARAMETER recurse
Deletes log files recursively


.EXAMPLE

PS> Remove-Logfile -path logs


.EXAMPLE

PS> Remove-Logfile -path logs -numberofDaystoKeepFiles 10  -WhatIf

#>

Function Remove-Logfile {
	[CmdletBinding(SupportsShouldProcess)]
	param (
		[Parameter(Mandatory=$True)]
		[string]
		$path,

		[Parameter(Mandatory=$False)]
		[int]
		$numberofDaystoKeepFiles = 30,
		
        [Parameter(Mandatory=$False)]
        [string] $logExtension = ".log",

		[Parameter(Mandatory=$False)]
		[switch]
		$recurse	 
	)
	

# Purge Logfiles in $path
# Delete all files older than the defined threshold value

$thresholdDate = (get-date).AddDays(-1 * $numberofDaystoKeepFiles)
$minThreshold = 2

# Validate input: 

# Path has to be valid
if (-not (Test-Path $path))
{
	throw "$path not found"
}

# Do not allow deleting files y
if ($numberofDaystoKeepFiles -lt $minThreshold) 
{
	$errMessage = ("Invalid threshold. Parameter numberofDaystoKeepFiles ({0}) is less than the allowed mininum threshold ({1})" -f $numberofDaystoKeepFiles, $minThreshold);
	throw $errMessage;
}



# Find files to delete
$filter = ("*{0}" -f $logExtension);
$filesToDelete = Get-ChildItem -Path $logPath -filter $filter -Recurse:$recurse |  Where LastWriteTime -lt $thresholdDate;

$pathInfo = (Resolve-Path $path).Path

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
	
}
