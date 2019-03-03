Function Create-BulkDNSRecords
{
    <#
	.SYNOPSIS
		Creates DNS reccords in a bulk based on CSV input.

	.DESCRIPTION
		Creates DNS reccords in a bulk based on CSV input.

	.PARAMETER CsvFilePath
	    input here the path to the CSV file.

	.EXAMPLE
		Create-BulkDNSRecords -CsvFilePath "C:\Temp\DNS_Records.csv"

	.NOTES
		-Author: Stephane van Gulick
		-Email :
		-CreationDate:
		-LastModifiedDate: 11/11/2014
		-Version: 0.5
		-History:
		11/11/2014 --> Creation --> 0.5

	.LINK
	#>

    [CmdletBinding()]
    Param(
        [Parameter(mandatory = $true)]
        [ValidateScript( {test-path $_})]
        $CsvFilePath
    )

    Write-Verbose "Importing CSV file"
    $Infos = Import-csv $CsvFilePath
    Write-Host "There are $($infos.count) lines found in $($CsvFilePath)"

    foreach ($line in $Infos)
    {
        If (-not($line.IPAddress -eq "" -or $null -and (-not($line.DNSName -eq "" -or $null)) -and $line.zonename -eq "" -or $null ))
        {
            Write-Verbose "Creating dns reccord $($line.DNSName) with ip $($line.IPAddress)"
            Try
            {
                Add-DnsServerResourceRecordA -Name $line.DNSName -ZoneName $line.zonename -IPv4Address $line.IPAddress -ErrorAction stop
                Write-Host "Successfully created $($line.DNSName) with ip $($line.IPAddress) in zone $($line.zonename)"
            }
            Catch
            {
                write-warning "Message: $_"
            }
        }
        Else
        {
            Write-Warning "line is empty. Skipping."
            continue
        }

    } # End Foreach

    Write-Host "End of script."
} # End function
