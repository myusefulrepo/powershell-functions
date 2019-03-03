Function Global:Reload-Scripts {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, Mandatory = $False)] [string]$ScriptFile
    )
    $strAutoLoadPath = "C:\Users\Olivier\Desktop\Useful-InPowershell\Functions"
    $ScriptFiles = Get-ChildItem $strAutoLoadPath -Name -Filter "*.ps1"
    If ($ScriptFile -eq "") {
        ForEach ($Script in $ScriptFiles) {
            $strScript = (Join-Path $strAutoLoadPath $Script)
            Write-host "Loading script : $($strScript)" -ForegroundColor Green
            . $strScript
        }
    }
    Else {
        ForEach ($Script in $ScriptFiles) {
            If ($Script -like "*$($ScriptFile)*") {
                $strScript = (Join-Path $strAutoLoadPath $Script)
                Write-Host "Loading script: $($strScript)" -ForegroundColor Green
                . $strScript
            }
        }
    }
}