function Read-FolderBrowserDialog() {
    <#
        .DESCRIPTION
        Permet d'ouvrir une zone de dialogue afin de choisir un dossier et retourne le dossier sélectionné par l'utilisateur
        .PARAMETRE
        aucun
        .EXAMPLE
        $MaVariable = Read-FolderBrowserDialog
        résultat : PS C:\Users\Moi> $MaVariable
                   C:\Intel\Logs
        .NOTES
        Fonction à appeler dans un script pour sélectionner un dossier
        #>  
        
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InitialDirectory 
    )  

    $InitialDirectory = [Environment]::GetFolderPath('Windows')
    Add-Type -AssemblyName System.Windows.Forms
    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.ShowNewFolderButton = $true
    $openFolderDialog.RootFolder
    $openFolderDialog.ShowDialog()
    return $openFolderDialog.SelectedPath
}