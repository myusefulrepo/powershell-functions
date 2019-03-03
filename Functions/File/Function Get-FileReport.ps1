Function Get-FileReport {
    <#
.SYNOPSIS
This function creates detailed file report and exports it in CSV format.
 
.DESCRIPTION
Use this function to export properties for files of certain type (doc,txt,jpg,etc.), and files older than certain days.
The report includes the following file properties:
 -File Name
 -Full File Path
 -File Extension
 -File Size in KB
 -File Owner
 -Last Change Date
 -Computer Name
    
.PARAMETER Path
Specifies the target folder path. Scans the files recursively.
   
.PARAMETER Days
Defines the file age.
    
.PARAMETER Ext
Specifies the file extension.
   
.PARAMETER Export
Exports the results in CSV file. Specifies the folder path for the export file.
   
.EXAMPLE
Get-FileReport -path c:\backups
Returns the properties of all files under c:\backups.
 
File_Name        : filer_backup.txt
Full_File_Path   : C:\backups\filer_backup.txt
File_Extension   : .txt
File_Size_(KB)   : 0.06
File_Owner       : DOMAIN\user
Last_Change_Date : 03/12/2013
Computer_Name    : COMPUTER03
 
 
.EXAMPLE
Get-FileReport -path c:\backups -days 1500
 
Description
-----------
Returns all files under c:\backups older than 1500 days.
The maximum value is 15000.
 
File_Name        : Rmtshare.exe
Full_File_Path   : C:\backups\Rmtshare.exe
File_Extension   : .exe
File_Size_(KB)   : 12.77
File_Owner       : DOMAIN\user
Last_Change_Date : 02/19/1999
Computer_Name    : COMPUTER03
 
.EXAMPLE
Get-FileReport -path c:\backups -days 150 -ext txt
 
Description
-----------
Returns all .txt files under c:\backups older than 150 days.
 
File_Name        : temp.txt
Full_File_Path   : C:\backups\temp_files\temp.txt
File_Extension   : .txt
File_Size_(KB)   : 0.01
File_Owner       : DOMAIN\user
Last_Change_Date : 02/19/2013
Computer_Name    : COMPUTER03
 
.EXAMPLE
Get-FileReport -path c:\docs -days 150 -ext txt -export c:\temp
 
Description
-----------
Exports to CSV all .txt files under c:\backups older than 150 days.
 
File_Name        : temp.txt
Full_File_Path   : C:\backups\temp_files\temp.txt
File_Extension   : .txt
File_Size_(KB)   : 0.01
File_Owner       : DOMAIN\user
Last_Change_Date : 02/19/2013
Computer_Name    : COMPUTER03
 
c:\temp\CZBRN3059-File-Report-7_20_2014.csv created successfully.
 
.NOTES 
File Name: Get-FileReport.ps1
Author: Nikolay Petkov
Blog: http://77.104.138.174/~powershe/power-shell.com
Last Edit: 12/17/2014
 
.LINK
http://77.104.138.174/~powershe/power-shell.com
 #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, HelpMessage = 'Please enter folder path')]
        [string]$Path,
        [Parameter(Mandatory = $False)]
        [string]$Ext,
        [Parameter(Mandatory = $False)]
        [ValidateRange(1, 15000)]
        [Int32]$Days,
        [Parameter(Mandatory = $False)]
        [string]$Export
    )
    try {
        $hostname = gc env:computername
        If ($days) {$olderthan = (Get-Date).AddDays(-$days)}
        else {$olderthan = Get-Date}
        $fileColl = @()
        # Get the files
        If ($Ext) {$files = Get-ChildItem -path $path -recurse -filter *.$ext -ErrorAction stop | Where-Object {$_.CreationTime -lt $olderthan}}
        else {$files = Get-ChildItem -Path $path -Recurse -ErrorAction stop | Where-Object {!$_.PSIsContainer -and $_.CreationTime -lt $olderthan}}
        # Retreive properties for each file
        foreach ($file in $files) {
            $fileObject = New-Object PSObject #An object,created and destroyed for each file
            $networkpath = "\\" + $HostName + $path.substring($path.LastIndexOf('\')) + '\' + (($file.FullName).trim($path))
            #The following add data to the fileObjects
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "File_Name" -value $file
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "Full_File_Path" -value $file.FullName
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "File_Extension" -value $file.Extension
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "File_Size_(KB)" -value ($file.Length / 1KB).tostring("0.00")
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "File_Owner" -value (get-acl $file.Fullname).Owner
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "Last_Change_Date" -value $file.LastWriteTime.ToString("MM/dd/yyy")
            Add-Member -inputObject $fileObject -memberType NoteProperty -name "Computer_Name" -value $hostname
            $fileObject |sort Last_Change_Date #Output to the screen for a visual feedback
            $fileColl += $fileObject #Copy the contents of the object into the Array
            $fileObject = $null #Delete the fileObject
        } #end foreach
        If ($fileColl) {Write-Host "File properties successfully retrieved." -ForegroundColor Green}
        If ($export) {
            $csvname = (($olderthan.tostring()).split('')[0]).replace('/', '_')
            $fileColl | Export-Csv -path "$export\$HostName-Files-Older-Than-$csvname.csv" -NoTypeInformation
        }
    }
    catch {
        If (!(Test-Path $Path)) {Write-Host "Cannot find ""$path"" because it does not exist." -ForegroundColor Red}
        If (!($files)) {Write-Host "No $Ext files found older than $olderthan." -ForegroundColor Green}
        If (($Export) -and (!(Test-Path $Export))) {Write-Host "Cannot export data to ""$Export"" because it does not exist." -ForegroundColor Red}
    }
    If (Test-Path $export\$HostName-Files-Older-Than-$csvname.csv) {Write-Host "$export\$HostName-Files-Older-Than-$csvname.csv created successfully." -ForegroundColor Green}
} #end function Get-FileReport