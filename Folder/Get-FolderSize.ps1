Function Get-FolderSize {
    <#
.SYNOPSIS
Get-FolderSize  recherche de mani?re récursive tous les fichiers et répertoire dans un path donné , calcule et retourne la taille totale

.DESCRIPTION
Get-FolderSize  recherche de manière récursive tous les fichiers et répertoire dans un path donné , calcule et retourne la taille totale
La taille est affichée en GB, MB, ou KB selon l'unité choisie. Par défaut, c'est en GB.
Accepte les paths multiples

.INPUTS
   Accepte les Paths en provenance du pipeline

.OUTPUTS
   sortie en console

.EXAMPLE
Get-FolderSize -Path c:\temp

FolderSize FolderName
---------- ----------
0.04 GB    c:\temp

Retourne la taille du répertoire c:\temp en GB (Go en français)

.EXAMPLE
Get-FolderSize -Path c:\temp, c:\temp2 -Unit MB

FolderSize FolderName
---------- ----------
39.68 MB   c:\temp
0.02 MB    c:\temp2
Retourne la taille des répertoires c:\temp et c:\temp2 en MB (Mo en français)

.NOTES
  Version         :  1.0
  Author          : O. FERRIERE
  Creation Date   : 17/01/2018
  Purpose/Change  : Développement initial du script
#>

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        # Aide sur Param?tre $Path
        [Parameter(
            ValueFromPipeline = $True,                              # Accepte les entrées depuis le pipeline
            ValueFromPipelineByPropertyName = $True,                # Accepte les entrées depuis le pipeline par nom
            Mandatory = $true,                                      # obligatoire
            HelpMessage = "Entrer le path du répertoire cible"      # message d'aide
        )]
        [ValidateScript( {Test-Path $_})]                           # Validation du path. Si n'existe pas, stop.
        [String[]]$Path,

        # Aide sur le param?tre $Unit
        [Parameter(
            HelpMessage = "Paramétrer l'unité de mesure de la fonction. Le Défaut est en GB (Go en fran?ais), Les valeurs acceptables sont KB, MB, GB")]
        [ValidateSet('KB', 'MB', 'GB')]                             # Jeu de validation des unités. Si pas dans le jeu ==> arr?t
        [String]$Unit = 'GB'

    ) # End param

    Begin {
        # Transformation de l'unité saisie en param?tre pour le calcul de la taille
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
    }
    Process {
        # On entre dans une boucle foreach, pour le cas ou plusieurs paths on été saisies.
        Foreach ($FilePath in $Path) {
            Try {
                Write-Verbose "Récupération de la taille des répertoires"
                # On essaie de calculer la taille de l'arborescence en cours de traitement, et si pb on arr?te
                $Size = Get-ChildItem $FilePath -Force -Recurse -ErrorAction Stop |
                    Measure-Object -Property length -Sum
            }
            Catch {
                # En cas d'erreur , on trappe l'erreur et on passe la variable $Probleme à $True
                Write-Warning $_.Exception.Message
                $Probleme = $True
            }

            If (-not ($Probleme)) {
                # On est dans le cas ou $Probleme n'est pas égal à $True
                Try {
                    # Essai de Création d'un PSObject dans lequel on met le nom de l'arborescence et la taille calculée
                    Write-Verbose "Création d'un PSObject qui contiendra le résultat"
                    New-Object -TypeName PSObject -Property @{
                        FolderName = $FilePath
                        FolderSize = "$([math]::Round(($size.sum / $value), 2)) $($Unit.toupper())"

                    }
                }

                Catch {
                    # En cas d'erreur du Try, on attrape l'erreur
                    Write-Warning $_.Exception.Message
                    $Probleme = $True
                }

            } # end du If

            if ($Probleme) {
                # Réinitialisation de $Problem pour l'arborescence suivante à traiter dans la boucle foreach
                $Probleme = $false
            }
        }  # end du foreach
    } # End du Process

    End {
        Write-Verbose "Fin du traitement de l'arborescence en cours"
    } # End du End
} # End de la fonction
