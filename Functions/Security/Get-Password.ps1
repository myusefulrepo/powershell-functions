Function Get-Password {
    <#
.SYNOPSIS
  Génère en Mot de passe complexe de x caractères
.DESCRIPTION
  Génère en Mot de passe complexe de x caractères
.PARAMETER 
    Longueur : nombre de caractères du mot de passe
    Special : nombre de caracères non-alphanumériques
.INPUTS
  Aucun
.OUTPUTS
  C:\Temp\Password.log (défini dans les paramètres $LogPath et $LogName
.NOTES
  Version:        1.0
  Author:         O. FERRIERE
  Creation Date:  05/08/2018
  Purpose/Change: Dévellopement initial du script
  
.EXAMPLE
  Get-Password -Longueur 10 -Special 2 -NombredePassword 5
    ]0COBGi!y.
    g(f)QrRqK3
    T{>1*XWdf|
    mgqGU7q@P}
    :m3yBp6y%q

#>

    # ---------------------------------------------------------[Initialisations]--------------------------------------------------------
    
    [CmdletBinding(
        SupportsShouldProcess = $true) # l'argument SupportsShouldProcess ajoute les paramètres Confirm et WhatIf à la fonction.
    ]
    param(
        [Parameter(Position = 0, 
            Mandatory = $true, 
            HelpMessage = "Longueur de mot de passe à générer")]
        [ValidateScript( {
                if ($_ -eq 0) {
                    throw " La longueur spécifiée pour le mot de passe doit être comprise entre 1 et 128 caractères."
                }
                else {
                    return $true	
                }
            })]
        [ValidateRange(1, 128)]
        [Int]$Longueur,

        [Parameter(Position = 1, 
            Mandatory = $true, 
            HelpMessage = "Nombre de caractères non-alphanumériques dans le mot de passe")]
        [ValidateRange(1, 5)]
        [Int]$Special,

        [Parameter(Position = 2, 
            Mandatory = $true, 
            HelpMessage = "Nombre de mots de passe à générer")]
        [ValidateScript( {
                if ($_ -eq 0) {
                    throw "Le nombre de mots de passe à générer ne peut pas être 0"
                }
                else {
                    return $true
                }
            })]
        [ValidateRange(1, 100)]
        [Int]$NombrePasswords

    ) , # End param
    
    #Set Error Action to Silently Continue
    $ErrorActionPreference = "SilentlyContinue"
   
    #----------------------------------------------------------[Declarations]----------------------------------------------------------
    
    Add-Type -AssemblyName System.Web
    #Log File Info
    $LogPath = "C:\Temp"
    $LogName = "Password.log"
    $LogFile = Join-Path -Path $LogPath -ChildPath $LogName
    # validation de l'existence du répertoire $logpath
    if (Test-Path -Path $LogPath -PathType Container) { 
        Out-Null
    } 
    else {
        New-Item $LogPath -Type Directory | out-null 
    }

    #-----------------------------------------------------------[Execution]------------------------------------------------------------

    
    for ($i = 0; $i -lt $NombrePasswords; $i++) { 
        [System.Web.Security.Membership]::GeneratePassword($Longueur, $Special) | Out-File $LogFile -Encoding utf8 -Append   
    }
    Write-host "Les mots de passe générés sont disponibles ici : $logfile" -ForegroundColor Yellow
    Notepad.exe $logfile
}
