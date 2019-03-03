function Measure-MyScript {
<#
.SYNOPSIS
    Measure speed execution of a scriptblock

.DESCRIPTION
    Measure speed execution of a scriptblock, use it to optimze your code

.PARAMETER Name
    Specifies the name of the test

.PARAMETER ScriptBlock
    Specifies the name of your script block or put your code here

.PARAMETER Repeat
    Specifies the numbers of time you want the test run

.PARAMETER Unit
    Specifies the unit for the result.
    Accepted : d,h,m,s,ms 
    for Days,hours,minutes,seconds,milliseconds

.EXAMPLE
    Measure-MyScript -Name 'Montest' -ScriptBlock { Start-Sleep 2 }

    Will execute Sleep for 2 secondes and give you the result in milliseconds associed to 'Montest' name

.EXAMPLE
    Measure-MyScript -Name 'Montest' -ScriptBlock { Start-Sleep 2 } -name 'mon test' -Unit 's'

    Will execute Sleep for 2 secondes, and give you the result in seconds associed to 'Montest' name

.EXAMPLE
    Measure-MyScript -Name 'Montest' -ScriptBlock { Start-Sleep 2 } -Repeat 5 -Unit 's'

    Will execute Sleep for 2 secondes, 5 times, and give you the miniminal,maximun and average time in seconds

.NOTES
    Christophe Kumor
    https://christophekumor.github.io
#>

    [CmdletBinding()]
    param (
        [string]$Name = "Test",

        [Parameter(Mandatory = $true)]
        [ScriptBlock]$ScriptBlock, 

        [ValidateScript( { if (@('d', 'h', 'm', 's', 'ms') -contains $_) {
                    $true
                }
                else {
                    throw "$_ is not supported. Autorised : d,h,m,s,ms ->Days,hours,minutes,seconds,milliseconds"
                } })]
        [String]$Unit = 'ms',
        
        [int]$Repeat = 1
    )


    if (-not $PSBoundParameters['Name']) 
        {
        $Name = ('{0}{1}' -f $Name, $Repeat)
        }
    Write-Verbose $name

    # Initialisation
    $timings = @()
    do {
        $sw = New-Object Diagnostics.Stopwatch
        if ($PSBoundParameters['Verbose']) 
            {
            $sw.Start()
            try 
                {
                &$ScriptBlock
                } # end try
            catch 
                {
                return $_.Exception.Message
                }  # end Catch
            $sw.Stop()
            } # End if

        else 
            {
            $sw.Start()
            try 
                {
                $null = &$ScriptBlock
                } # end try
            catch 
                {
                return $_.Exception.Message
                } # end Catch
            $sw.Stop()
            Write-Verbose "o."
            } # end else
        $timings += $sw.Elapsed
        $Repeat--
        } # end Do

    while ($Repeat -gt 0)
    $stats = $timings | Measure-Object -Average -Minimum -Maximum -Property Ticks
    switch ($Unit) {
        d { 
            $u = 'TotalDays'; $msg = 'Days'; break
           }
        h  {
            $u = 'TotalHours'; $msg = 'Hours'; break
           }
        m  {
            $u = 'TotalMinutes'; $msg = 'Minutes'; break
           }
        s  {
            $u = 'TotalSeconds'; $msg = 'Seconds'; break
           }
        ms {
            $u = 'TotalMilliseconds'; $msg = 'Milliseconds'; break
           }
        default {
            $u = 'TotalMilliseconds'; $msg = 'Milliseconds'
           }
    } # End switch

    if ($PSBoundParameters['Repeat'] -gt 1) 
        {
        [ordered]@{
            name = $Name
            Avg  = "{0} {1}" -f (New-Object System.TimeSpan $stats.Average).$u, $msg
            Min  = "{0} {1}" -f (New-Object System.TimeSpan $stats.Minimum).$u, $msg
            Max  = "{0} {1}" -f (New-Object System.TimeSpan $stats.Maximum).$u, $msg
        }
        } # End if
    else {
        [ordered]@{
            name = $Name
            Tps  = "{0} {1}" -f (New-Object System.TimeSpan $stats.Average).$u, $msg
        }
        } # end Else
} # End function
