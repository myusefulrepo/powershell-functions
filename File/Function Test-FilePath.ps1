function Test-FilePath () {
    <#
        .DESCRIPTION
        Teste l'existence d'un fichier sélectionné par l'utilisateur et le créé au besoin
        
        .PARAMETRE
        $filepath
        
        .EXAMPLE
        Test-FilePath -filePath "C:\temp\DoesNotExist.txt"
            Le fichier n'exite pas et va être créé
            Répertoire : C:\temp
            Mode                LastWriteTime         Length Name                                                                                                                                         
            ----                -------------         ------ ----                                                                                                                                         
            -a----       24/06/2018     16:30              0 DoesNotExist.txt 
        .NOTES
        Fonction à appeler dans un script pour sélectionner valider l'existence d'un fichier
        #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$FilePath
    )  
        
         
    if (-not (Test-Path -Path $filePath)) {
        Write-Host "Le fichier n'existe pas et va être créé" -ForegroundColor Yellow
        New-Item -ItemType file -Path $filePath
    }
    else {
        Write-Host "Le fichier existe, aucune action requise" -ForegroundColor Green
    }    
}



