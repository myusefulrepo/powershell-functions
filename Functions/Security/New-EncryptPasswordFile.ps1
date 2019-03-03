<#
.SYNOPSYS

   Génère un fichier de mot de passe encrypté

.DESCRIPTION

    Génère un fichier de mot de passe encrypté

.PARAMETER Password

    Le mot de passe à encrypter

.PARAMETER CredFile

    Path et nom du fichier contenant le mot de passe encrypté

.INPUTS

    Aucun

.OUTPUTS

  Fichier .txt contenant le mot de passe crypté

.EXAMPLE  

    New-EncryptPasswordFile -Password "MonMotdePassequ'ilestbeau" -CredFile "c:\temp\PC1Cred.txt"
    Cette commande génère un fichier PC1Cred.txt contenant le mot de passe chiffré

.NOTES

  Version         : 1.1
  Author          : O. FERRIERE
  Creation Date   : 29/11/2018
  Purpose/Change  : Développement intial du script

.RELATED LINKS  

http://nicolaslang.blogspot.com/2014/06/stocker-un-mot-de-passe-dans-un-script.html
#>

function New-EncryptPasswordFile {
    [CmdletBinding(
        SupportsShouldProcess = $true) # l'argument SupportsShouldProcess ajoute les paramètres Confirm et WhatIf à la fonction.
    ]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory = $true,
            HelpMessage = "Mot de passe à encrypter",
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $Password,

        # Param2 help description
        [Parameter(Mandatory = $true,
            HelpMessage = "Path et nom du fichier qui contiendra le mot de passe encrypté",
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        $CredFile
    )

    $Password | Convertto-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-file $CredFile
    Write-host "Le fichier " -ForegroundColor Green -NoNewline
    Write-Host $CredFile -ForegroundColor Yellow -NoNewline
    Write-Host " a été créé." -ForegroundColor Green
} # Fin de la fonction



<#
Version hors fonction

$Cred = "C:\Scripts\CredsPC.txt"
Read-Host "Quel est le mot de passe à encrypter" | Convertto-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-file $Cred
Write-host "Le fichier " -ForegroundColor Green -NoNewline
Write-Host $Cred -ForegroundColor Yellow -NoNewline
Write-Host " a été créé." -ForegroundColor Green
Write-Host "Fin du script" -ForegroundColor Cyan
####### Ceci n'est à exécuter qu'une seule fois ######

#>