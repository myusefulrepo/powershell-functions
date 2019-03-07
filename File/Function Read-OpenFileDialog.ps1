function Read-OpenFileDialog()
{
    <#
 .DESCRIPTION
        Opens a dialog box to choose a file and returns the user selected file

.PARAMETER InitalDirectory
    Initial Directory path to browse
    [String] :  Optional
    Default : $PSscriptRoot

.PARAMETER MultiSelect
    Allow multi-files seleciton
    [switch] : Optional

.EXAMPLE
    $MaVar = Read-OpenFileDialog
    Result : PS C:\Users\Me> $MaVar
                   IntelGFXa
.INPUT
    <None>

.OUTPUT
    OpenFileDialog.Filename

 .NOTES
    Function useful in a script to call and select one or more files in a browser dialog box
    File Name: Function Read-OpenFileDialog.ps1
    Author: O.livier FERRIERE
    Last Edit : 06/03/2019
    Change : some minor adjustement to pass PSCodeHealth tests.

        #>

    [CmdletBinding()]
    param(
        # Parameter help description : InitialDirectory
        [Parameter(
            HelpMessage = "Initial Directory Path to browse")]
        [string]$InitialDirectory = $PSScriptRoot

        # Parameter help description : AllowMultiSelect
        [parameter(HelpMessage = "Allow multi-files selection ")]
        [switch]$AllowMultiSelect
    )

    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.initialDirectory = $InitialDirectory
    $openFileDialog.filter = "All files (*.*)| *.*"
    if ($AllowMultiSelect)
    {
        $openFileDialog.MultiSelect = $true
    }
    $openFileDialog.ShowDialog() > $null
    if ($allowMultiSelect)
    {
        return $openFileDialog.Filenames
    }
    else
    {
        return $openFileDialog.Filename
    }
}