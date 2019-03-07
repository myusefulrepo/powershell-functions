Function Get-FolderSize
{
    <#
.SYNOPSIS
Get-FolderSize recursively search all files and directory in a given path, calculate and return the total size

.DESCRIPTION
Get-FolderSize recursively search all files and directory in a given path, calculate and return the total size?

The size is displayed in GB, MB, or KB depending on the unit chosen. By default, it is in GB.
Accepts multiple paths

.INPUTS
   Accepts Paths from the pipeline

.OUTPUTS
  console output

.EXAMPLE
Get-FolderSize -Path c:\temp

FolderSize FolderName
---------- ----------
0.04 GB    c:\temp

Return folder size c:\temp in GB

.EXAMPLE
Get-FolderSize -Path c:\temp, c:\temp2 -Unit MB

FolderSize FolderName
---------- ----------
39.68 MB   c:\temp
0.02 MB    c:\temp2
Retunr folder size c:\temp and c:\temp2 in MB)

.NOTES
  Version         :  1.1
  Author          : O. FERRIERE
  Creation Date   : 17/01/2018
  Purpose/Change  : Script initial development
  Change           : 07/03/2019 - some minor improvment to pass PScriptAnalyzer PSCodeHealth tests.
#>

    [CmdletBinding()]
    Param
    (
        # Parameter help description : Path
        [Parameter(
            ValueFromPipeline = $True, # Accepts entries from the pipeline
            ValueFromPipelineByPropertyName = $True, # accept entries from the pipeline by name
            Mandatory = $true, # Mandatory
            HelpMessage = "Path of the target directory"      # Help Message
        )]
        [ValidateScript( {Test-Path $_})]                     # Path Validation. If does not exist, stop.
        [String[]]$Path,

        # Parameter help description : $Unit
        [Parameter(
            HelpMessage = "Set the unit of measure for the function. The default is in GB. Acceptable values are KB, MB, GB")]
        [ValidateSet('KB', 'MB', 'GB')]                       # Unit validation set. If not in the set ==> stop
        [String]$Unit = 'GB'

    ) # End param

    Begin
    {
        # Setting the unit of measurement
        Write-Verbose "Setting the unit of measurement"
        $value = Switch ($Unit)
        {
            'KB'
            {
                1KB
            }
            'MB'
            {
                1MB
            }
            'GB'
            {
                1GB
            }
        }
    }
    Process
    {
        # we enter a foreach loop, for the case where several paths have been entered.
        Foreach ($FilePath in $Path)
        {
            Try
            {
                Write-Verbose -Message "Retrieving the size of the directories"
                # Try to calculate the size of the tree being processed, and if pb we stop
                $Size = Get-ChildItem $FilePath -Force -Recurse -ErrorAction Stop |
                    Measure-Object -Property length -Sum
            }
            Catch
            {
                # In case of error, we trap the error and pass the variable $Problem to $True
                Write-Error -Message  $_.Exception.Message
                $Problem = $True
            }

            If (-not ($Problem)) # We are in the case where $Problem is not equal to $True
            {
                Try
                {
                    # Try to create a PSObject Essai de Création d'un PSObject feeds with the Name of the tree and the calculated size
                    Write-Verbose "Creating a PSObject that will contain the result"
                    New-Object -TypeName PSObject -Property @{
                        FolderName = $FilePath
                        FolderSize = "$([math]::Round(($size.sum / $value), 2)) $($Unit.toupper())"
                    }
                } # End Try

                Catch
                {
                    # In case of error, we catch the error
                    Write-Error -Message $_.Exception.Message
                    $Problem = $True
                } # End Catch

            } # End If

            if ($Problem)
            {
                # Resetting $Problem for the next tree to process in the foreach loop
                $Problem = $false
            }
        }  # End foreach
    } # End Process

    End
    {
        Write-Verbose "End of processing of the current tree"
    } # End End

} # End function
