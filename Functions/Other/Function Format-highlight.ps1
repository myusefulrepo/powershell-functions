# Source : https://systemswin.blogspot.com/2016/03/formatting-powershell-output-with.html
<#
Permet de mettre en évidence ($color) les paramètres ($param) retournées par la commande qui ont une valeur particulière ($value)
Marche avec powershell, mais pas avec ISE
#>
function Format-highlight {
    param ($param,$value,$color)

    begin {

        $ConsoleBack = [System.Console]::BackgroundColor
        $ConsoleFore = [System.Console]::ForegroundColor
        $RowColors = @(
            @{
                Back = $ConsoleBack
                Fore = $color
            },
            @{
                Back = $ConsoleBack
                Fore = $ConsoleFore
            }
        )
    }
    process {

        # $Index will be either 0 or 1 and used to pick colors from $RowColors
        if ($_.$param -eq $value){$index=0}else{$index=1}
        [System.Console]::BackgroundColor = $RowColors[$Index].Back
        [System.Console]::ForegroundColor = $RowColors[$Index].Fore
        $_
    }
    end {
        [System.Console]::BackgroundColor = $ConsoleBack
        [System.Console]::ForegroundColor = $ConsoleFore
    }

} #function Format-highlight