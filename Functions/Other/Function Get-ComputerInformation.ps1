Function Get-ComputerInformation {
    [CmdletBinding()]
    PARAM (
        [Parameter(ValueFromPipeline)]
        $ComputerName = $env:COMPUTERNAME
    )
    PROCESS {
        Write-Verbose -Message "Traitement de $ComputerName"
        
        # Computer System
        $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName
        # Operating System
        $OperatingSystem = Get-WmiObject -class win32_OperatingSystem -ComputerName $ComputerName
        # BIOS
        $Bios = Get-WmiObject -class win32_BIOS -ComputerName $ComputerName
        
        # Préparation de l'Output
        Write-Verbose -Message "$ComputerName - Préparation de l'Output"
        $Properties = @{
            ComputerName           = $ComputerName
            Manufacturer           = $ComputerSystem.Manufacturer
            Model                  = $ComputerSystem.Model
            OperatingSystem        = $OperatingSystem.Caption
            OperatingSystemVersion = $OperatingSystem.Version
            SerialNumber           = $Bios.SerialNumber
        } # fin de Properties
        
        # Information en Output
        Write-Verbose -Message "$ComputerName - Output Information"
        New-Object -TypeName PSobject -Property $Properties
    } # fin de PROCESS
} # fin de Function