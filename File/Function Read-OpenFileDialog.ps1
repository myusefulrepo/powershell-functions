function Read-OpenFileDialog()
{
    <#
        .DESCRIPTION
        Permet d'ouvrir une zone de dialogue afin de choisir un fichier et retourne le fichier sélectionné par l'utilisateur
        .PARAMETRE
        aucun
        .EXAMPLE
        $MaVariable = Read-OpenFileDialog
        résultat : PS C:\Users\Moi> $MaVariable
                   IntelGFXa
        .NOTES
        Fonction à appeler dans un script pour sélectionner un dossier
        #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InitialDirectory,
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