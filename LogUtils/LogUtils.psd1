#
# Module manifest for module 'LogUtils'
#
# Generated by: jgj.it / jensgc / jensgj
#
# Generated on: 2022-01-13 23:08:00
# Last updated (v.2.2.1): 2022-02-10 11:41:00
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'LogUtils.psm1'

# Version number of this module.
ModuleVersion = '2.2.1'

# ID used to uniquely identify this module
GUID = '29e7e36b-6115-4508-9c7c-e289efef9d56'

# Author of this module
Author = 'Jens Gyldenkærne Jensen'

# Company or vendor of this module
CompanyName = 'Copenhagen Business School'

# Copyright statement for this module
Copyright = '(c) 2022 jgj.it. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Utilities to archive and purge log files'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'Backup-Logfile', 'Remove-Logfile'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
	PrivateData = @{
		PSData = @{
			#Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('log', 'logging', 'windows')

			#A URL to the main website for this project.
			ProjectUri = 'https://github.com/JensGJ/LogUtils'

		} 
		#End of PSData hashtable
	} 
	#End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

