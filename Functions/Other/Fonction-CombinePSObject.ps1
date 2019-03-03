Function Combine-Object
{

    [CmdletBinding()]
    Param (
        # Aide sur paramètre $InputObjet
        [Parameter(Mandatory = $true,
            HelpMessage = "Objets à passer en entrée. 2 minimum")]
        [ValidateCount(2, 2147483646)]
        [PSObject[]]$InputObject,

        # Aide sur paramètre $Property
        [Parameter(HelpMessage = "Propriétés sur lesquels filter")]
        [String[]]$Property = @()
    )

    <#
    Vérification si l'utilisateur a donné des noms de propriété à sélectionner dans les objets
    pour des raisons de performances, celle-ci est faite en dehors de la boucle ForEach
    #>
    $FilterProperties = $false
    If ($Property.count -gt 0)
    {
        $FilterProperties = $True
    }

    <#
    Afin d' éviter l'utilisation de l'opérateur += (opérateur à vitesse lente) ou de la cmdlet Add-Member
    nous utilisons un hashlabel. Création d'une table de hachage vide pour contenir les propriétés de l'objet résultant
    #>
    $ResultHash = @{}

    # Traitement de chaque objet du tableau InputObject
    ForEach ($InObject in $InputObject)
    {
        # traitement de chaque propriété de l'objet traité en cours
        ForEach ( $InObjProperty in $InObject.psobject.Properties)
        {
            # Si l'utilisateur ne doit sélectionner que des propriétés données
            If ($FilterProperties)
            {
                # Ajouter uniquement la propriété sélectionnée à la table de hachage
                If ($Property -contains $InObjProperty.Name)
                {
                    $ResultHash.($InObjProperty.Name) = $InObjProperty.value
                }
            }
            Else
            {
                <#
                L'utilisateur ne veut pas filtrer les propriétés de l'objet
                Ajout de toutes les propriétés des objets à la table de hachage
                ATENTION ! Si une propriété d'un objet a le même nom qu'une autre propriété
                cela entraînera une erreur non-terminante !
                #>
                $ResultHash.($InObjProperty.Name) = $InObjProperty.value
            }
        }
    }
    <#
    Création (et retour) de l'objet résultant à partir de la table de hachage
    C'est le moyen le plus rapide - et compatible de PS v2.0 -  de créer un objet personnalisé !
    #>
    New-Object -TypeName PSObject -Property $ResultHash
}
