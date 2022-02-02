<#
	My Function
#>

function Archive-Logfiles
    [CmdletBinding(SupportShouldProcesss=$True)]
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


{

    # Check that the given logepath is a valid and existing directory
if (-not ((Test-Path $logPath) -and  (Get-Item $logPath).psiscontainer)) {
    $errMessage = "{0} is not a valid directory!" -f $logPath;
    throw $errMessage;
}



# Define date format added as a postfix to each log file
$datestamp = (get-date).ToString($dateFormat);


# Check that the given archivepath is a valid and existing directory
if (-not ((Test-Path $archivePath) -and  (Get-Item $archivePath).psiscontainer)) {
    $errMessage = "{0} is not a valid directory!" -f $archivePath;
    throw $errMessage;
}


# Find all logfiles
$filter = ("*{0}" -f $logExtension);
$filesToCopy = Get-ChildItem -Path $logPath -filter $filter

# Check if there is anything to move
if ($null -eq $filesToCopy) {
    $errMessage = "No logfiles found!";
    throw $errMessage;
}

foreach ($file in $filesToCopy) {
    $newname = "{0}_{1}{2}" -f $file.BaseName, $datestamp, $file.Extension
    $newpath = Join-Path -Path $archivePath -ChildPath $newname
    Move-Item $file $newpath
}

# Print info

write-host  ("Moved {0} files to {1} using the datestamp {2}" -f $filesToCopy.count, $archivePath, $datestamp);
}