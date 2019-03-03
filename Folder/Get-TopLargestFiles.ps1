Function Get-TopLargestFiles {
    <#
.SYNOPSIS
    Get-TopLargestFiles recherche de manière récursive dans un path donné, et retourne les X plus gros fichiers

.DESCRIPTION
    Get-TopLargestFiles recherche de manière récursive dans un path donné, et retourne les X plus gros fichiers

    Accepte les paths multiples

.INPUTS
   Accepte les Paths en prvenance du pipeline

.OUTPUTS
   Sortie de cette applet de commande (le cas Ć©chĆ©ant)

.EXAMPLE
    Get-TopLargestFiles -Path c:\temp

    Retourne les 10 plus gros fichiers du répertoire c:\temp

.EXAMPLE
    Get-TopLargestFiles -Path c:\temp, c:\temp2 -top 5
    Retourne les 5 plus gros fichiers du répertoire de c:\temp et c:\temp2


.NOTES
  Version         :  1.0
  Author          : O. FERRIERE
  Creation Date   : 17/01/2018
  Purpose/Change  : DĆ©veloppement initial du script
#>

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        # Aide sur Paramètre $Path
        [Parameter(
            ValueFromPipeline = $True,                                  # Accepte les entrées depuis le pipeline
            ValueFromPipelineByPropertyName = $True,                    # Accepte les entrées depuis le pipeline par nom
            Mandatory = $True,                                          # obligatoire
            HelpMessage = "Entrer le path du répertoire cible"          # message d'aide
        )]
        [ValidateScript( {Test-Path $_})]                               # Validation du path. Si n'existe pas, stop.
        [String[]]$Path,

        # Aide sur le paramètre $Unit
        [Parameter(
            HelpMessage = "Paramétrer l'unité de mesure de la fonction. Le Défaut est en GB (Go en français), Les valeurs acceptables sont KB, MB, GB")]
        [ValidateSet('KB', 'MB', 'GB')]                             # Jeu de validation des unitĆ©s. Si pas dans le jeu ==> arrĆŖt
        [String]$Unit = 'GB',


        # Aide sur le paramètre $Top
        [Parameter(
            HelpMessage = "Nombre de plus gros fichiers à retourner. le Défaut est 10")]
        [Int]$Top = "10"


    ) # End param

    Begin {
        # Transformation de l'unité saisie en paramètre pour l'affichage de la taille
        Write-Verbose "Paramétrage de l'unité de mesure"
        $value = Switch ($Unit) {
            'KB' {
                1KB
            }
            'MB' {
                1MB
            }
            'GB' {
                1GB
            }
        }
    } # End Begin

    Process {
        # On entre dans une boucle foreach, pour le cas ou plusieurs paths on été saisies.
        Foreach ($FilePath in $Path) {
            Try {
                Write-Verbose "Récupération de la taille des répertoires"
                # On essaie de calculer la taille de l'arborescence en cours de traitement, et si pb on arrête
                $Files = Get-ChildItem $FilePath -Recurse -Force -ErrorAction Stop |
                    Sort-Object -Descending -Property Length
            }
            Catch {
                # En cas d'erreur , on trappe l'erreur et on passe la variable $Probleme à $True
                Write-Warning $_.Exception.Message
                $Probleme = $True
            }

            If (-not ($Probleme)) {
                # On est dans le cas ou $Probleme n'est pas égal à $True
                Try
                {
                    # Essai de sortie en console du TOP des fichiers
                    Write-Verbose "Sortie en console du TOP des fichiers"
                    Write-Output $FilePath
                    $TopFilesName = $Files | Select-First $Top -ErrorAction Stop |
                        Select-Object -Property `
                    @{Label = "Nom Complet"   ; Expression = {$_.FullName }},
                    @{Label = "$Unit"         ; Expression = {"{0:N2}" -f ($_.Length / $value) }}
                    Write-Output $TopFilesName
                }

                Catch
                {
                    # En cas d'erreur du Try, on attrape l'erreur
                    Write-Warning $_.Exception.Message
                    $Probleme = $True
                }

            } # end du if

            if ($Probleme) {
                # Réinitialisation de $Probleme pour l'arborescence suivante à traiter dans la boucle foreach
                $Probleme = $false
            }

        }  # end du foreach
    } # End du Process

    End {
        Write-Verbose "Fin du traitement de l'arborescence en cours"
    } # End du End
} # End de la fonction
