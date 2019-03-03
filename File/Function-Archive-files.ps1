#requires -version 5
<#
.SYNOPSIS
  Archivage par compression .zip des fichiers qui répondent à un critère d'ancienneté

.DESCRIPTION
  Archivage par compression .zip des fichiers qui répondent à un critère d'ancienneté
  L'archive sera créée dans le répertoire ou se situent les fichiers à archiver
  
.PARAMETER PathToZipFiles 
 Full Path du répertoire qui contient les fichiers à zipper

.PARAMETER  DayBeforArchive
  Nombre de jours depuis la dernière modification du ficher (lastwriteTime) avant archivage
    Le nombre saisi doit être positif, il sera transformé par la fonction en nombre négatif

.PARAMETER PrefixArchive
  Début du nom d el'archive .zip qui va être créée. 
  Elle sera suivie du mois et de l'année des fichiers contenus dans l'archive
  ex. Logs-08-2018

.PARAMETER Communs
    Les paramètres communs comme -Whatif, -Verbose -debug sont supportés

.INPUTS
  Aucun

.OUTPUTS 
  Aucun

.NOTES
  Version               : 1.0
  Auteur                : O. FERRIERE
  Date de création      :  12/08/2018
  Objet du changement   : 12/08/2018 - Développement initial du script

.EXAMPLE
  Archivefiles -pathToZipFiles c:\Logs -DayBeforArchive 30 -PrefixArchive ArchiveLogs
  Trouve tous les fichiers de plus de 30 jour dans le path fourni et les archives dans un fichier .zip portant pour début de nom PrefixArchive, suivi par le mois et l'année du fichier. 
  Une même archive contient tous les fichers d'un même mois.
  
.EXAMPLE
  ArchiveFiles -PathToZipFiles c:\temp -DayBeforArchive -3 -PrefixArchive Archives -WhatIf -Verbose
        Le fichier before.txt date du 08/05/2018 11:44:48. C'est plus vieux que le max de -3 jours. Il doit être archivé
        le fichier d'archive sera c:\temp\Archives-08-2018 pour before.txt
        WhatIf : Opération « Supprimer le fichier » en cours sur la cible « C:\temp\before.txt ».
        le fichier before.txt a été archivé puis supprimé
        Le fichier Password.log date du 08/05/2018 11:32:16. C'est plus vieux que le max de -3 jours. Il doit être archivé
        le fichier d'archive sera c:\temp\Archives-08-2018 pour Password.log
        WhatIf : Opération « Supprimer le fichier » en cours sur la cible « C:\temp\Password.log ».
        le fichier Password.log a été archivé puis supprimé
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
# Aucun
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
# Aucun

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function ArchiveFiles
{
    [CmdletBinding(SupportsShouldProcess = $true)]  # Permet d'ajouter Whatif et Confirm au script 
    Param (
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Full Path du répertoire qui contient les fichiers à zipper",
            ValueFromPipeline = $true)
        ]
        [string]$PathToZipFiles,

        [Parameter(
            Mandatory = $True,
            HelpMessage = "Nombre de jours depuis la dernière modification du ficher (lastwriteTime) avant archivage",
            ValueFromPipeline = $true)
        ]
        [string]$DayBeforArchive,  
    
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Préfixe du nom de l'archize .zip à créer",
            ValueFromPipeline = $true)
        ]
        [string]$PrefixArchive 
    )  
    
    # conversion du nombre de jours avant archivage qui est positif en nombre négatif
        $DayBeforArchiveNegative = 0- $DayForarchive

    # Détermination des fichiers éligibles à Zipper
    $Files = Get-childitem -Path $PathToZipFiles -File | 
        Where-Object -filterscript {($_.FullName -notlike "*.zip") -and ((get-date).AddDays($DayBeforArchiveNegative) -gt $_.LastWriteTime) }

    foreach ($file in $Files)
    {
        $FileName = $File.Name
        $FileLastwriteAccess = $file.LastWriteTime
        Write-host "Le fichier $fileName date du $FileLastwriteAccess.  C'est plus vieux que le max de : $DayForArchive jours. il doit être archivé" -ForegroundColor Green
        Write-Information "Le fichier $fileName date du $FileLastwriteAccess c'est plus vieux que que le maxe : $DayBeforArchive jours/ il doit être archivé" -Verbose
        
        # Initialisation de la variable  $Archive poaur éviter des pbs à chaque boucle
        $ArchiveCible = ""
        
        # Détermination du mois et de l'année du fichier pour la création de l'archive
        $Month = $file.LastWriteTime.ToString("MM")
        $Year = $file.LastWriteTime.ToString("yyyy") 
        
        # détermination du nom de l'archive (.zip) avec le mois et l'année
        $ArchiveCible = "$PathToZipFiles\$PrefixArchive-$Month-$Year"
        Write-host "le fichier d'archive sera $ArchiveCible pour $file" -ForegroundColor Green
        Write-Information "le fichier d'archive sera $ArchiveCible pour $file" -Verbose   
        # Création de archive .zip, ou ajout dedans si existante
        Compress-Archive -Path $file.FullName -DestinationPath $ArchiveCible -Update
        
        # Suppression du fichier archivé après archivage 
        Remove-Item -Path $file.FullName 
        Write-host "le fichier $File a été archivé puis supprimé" -ForegroundColor Green
        Write-Information "le fichier $File a été archivé puis supprimé" -Verbose       
    }   # FIn du foreach
} # Fin de la fonction
