<#
.SYNOPSIS
    The goal of this function is to add a user/group to the access control list of a specify printer/AllPrinters installed on a defined PrintServer/All PrintServers

.DESCRIPTION
    The goal of this function is to add a user/group to the access control list of a specify printer/AllPrinters installed on a defined PrintServer/All PrintServers
    There are 2 cases (parameter set) :
        - A PrinterName AND a Server/Array of servers are defined : ACE are set to this printer only on the server/Array of servers
        - No PrinterName are defined : ACE are set to All Printers on the Server/Array of servers

.PARAMETER Server
    Defines the PrintServer. Please use the full qualified domain name here.

.PARAMETER UserName
    Defines the user/group that will be added to the acl.

.PARAMETER PrinterName
    Optional : If defined, the treament will be set only on this PrinterName on the Server/Array of servers
    If not defined, the treatment will be set on all Printers on the server.Array of servers

.PARAMETER Permission
    Defines the permission that the User/group will get. You can commit the following permissions
    'Takeownership', 'ReadPermissions', 'ChangePermissions', 'ManageDocuments', 'ManagePrinters', 'Print + ReadPermissions'

.PARAMETER AccesType
    Defines the AccessType the User/group will get. You can commit the following AccessType
    'Allow', 'Deny', 'System Audit'

.INPUTS
    None

.OUTPUTS
    [System.object]

.NOTES
    Version : 1.0
    Date : 07 August 2021
    Author : O. FERRIERE
    Change : v1.0 - 07/08/2021 - Initial Version - Tested with PSVersion 5.1.19041.1
    Based on https://docs.microsoft.com/En-US/windows/win32/cimwin32prov/setsecuritydescriptor-method-in-class-win32-printer?redirectedfrom=MSDN

    # TODO : possibility to add or remove permissions¨-Possibility to add a list of accounts / groups

.EXAMPLE
    Set-PrinterPermission -UserName "Group-ManagePrinterDoc" -Permission "ManageDocuments" -Server "Server1.dev.lan"
    Set permissions  "ManageDocuments" to Group-ManagePrinterDoc (group) on the server Server1 only

.EXAMPLE
    Set-PrinterPermission -UserName "Group-ManagePrinterDoc" -Permission "ManageDocuments" -Server "Server1.dev.Lan","Server2.dev.lan"
    Set permissions  "ManageDocuments" to the Group-ManagePrinterDoc (group) on the servers Server1 and server2

.EXAMPLE
    Get-Help Set-PrinterPermission -Full
    Complete help about the script

.EXAMPLE
    Get-Help Set-PrinterPermission -ShowWindows
    Complete help about the script in a separate windows
#>
function Set-PrinterPermission
{
    [CmdletBinding(SupportsShouldProcess)]

    Param (
        [Parameter(
            HelpMessage = "Server or array of servers",
            ParameterSetName = 'OnePrinter'
        )]
        [Parameter(
            HelpMessage = "Server or array of servers",
            ParameterSetName = 'AllPrinters'
        )]
        [string[]]$Server,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "User/group to grant permissions",
            ParameterSetName = 'OnePrinter'
        )]
        [Parameter(
            Mandatory = $true,
            HelpMessage = "User/group to grant permissions",
            ParameterSetName = 'AllPrinters'
        )]
        [String]$UserName,

        [Parameter(
            HelpMessage = "Name of the Printer",
            ParameterSetName = 'OnePrinter'
        )]
        [String]$PrinterName,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Permissions to apply",
            ParameterSetName = 'OnePrinter'
        )]
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Permissions to apply",
            ParameterSetName = 'AllPrinters'
        )]
        [ValidateSet('Takeownership', 'ReadPermissions', 'ChangePermissions', 'ManageDocuments', 'ManagePrinters', 'Print + ReadPermissions')]
        [String]$Permission,

        [Parameter(
            Mandatory = $true,
            HelpMessage = "Permissions to apply",
            ParameterSetName = 'OnePrinter'
        )]
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Permissions to apply",
            ParameterSetName = 'AllPrinters'
        )]
        [ValidateSet('Allow', 'Deny', 'System Audit')]
        [String]$AccessType
    )



    Begin
    {
        Write-Output "Beginning Treatment ..."

        Write-Verbose "creating instances of necessary classes ..."
        $SD = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
        $Ace = ([WMIClass] "Win32_Ace").CreateInstance()
        $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()

        Write-Verbose "Translating UserName (user or group) to SID"
        $SID = (New-Object security.principal.ntaccount $UserName).translate([security.principal.securityidentifier])

        Write-Verbose "Get binary form from SID and byte Array"
        [byte[]]$SIDArray = , 0 * $SID.BinaryLength
        $SID.GetBinaryForm($SIDArray, 0)

        Write-Verbose "Fill Trustee object parameters"
        $Trustee.Name = $UserName
        $Trustee.SID = $SIDArray


        Write-Verbose "Translating $Permission to the corresponding Access Mask"
        Write-Verbose "Based on https://docs.microsoft.com/en-US/windows/win32/cimwin32prov/setsecuritydescriptor-method-in-class-win32-printer?redirectedfrom=MSDN"
        switch ($Permission)
        {
            'Takeownership'
            {
                $Ace.AccessMask = "524288"
            }
            'ReadPermissions'
            {
                $Ace.AccessMask = "131072"
            }
            'ChangePermissions'
            {
                $Ace.AccessMask = "262144"
            }
            'ManageDocuments'
            {
                $Ace.AccessMask = "983088"
            }
            'ManagePrinters'
            {
                $Ace.AccessMask = "983052"
            }
            'Print + ReadPermissions'
            {
                $Ace.AccessMask = "131080"
            }
        }

        Write-Verbose "Translating $AccessType to the corresponding numeric value"
        Write-Verbose "Based on https://docs.microsoft.com/en-US/windows/win32/cimwin32prov/setsecuritydescriptor-method-in-class-win32-printer?redirectedfrom=MSDN"
        switch ($AccessType)
        {

            "Allow"
            {
                $Ace.AceType = 0
                $Ace.AceFlags = 0
            }
            "Deny"
            {
                $Ace.AceType = 1
                $Ace.AceFlags = 1
            }
            "System Audit"
            {
                $Ace.AceType = 2
                $Ace.AceFlags = 2
            }
        }

        Write-Verbose "Write Win32_Trustee object to Win32_Ace Trustee property"
        $Ace.Trustee = $Trustee

        Write-Verbose "Write Win32_Ace and Win32_Trustee objects to SecurityDescriptor object"
        $SD.DACL = $Ace

        Write-Verbose "Set SE_DACL_PRESENT control flag"
        $SD.ControlFlags = 0x0004

    }

    process
    {
        try
        {

            If ($PSCmdlet.ParameterSetName -eq "OnePrinter")
            {

                $Printer = Get-Printer -ComputerName $Server -Name $PrinterName -ErrorAction Stop
                $PrinterName = $Printer.name
                Write-Output "Beginning treatment of : $PrinterName"
                Write-Verbose "Get printer object"
                <#
                It seems that i can't use the Filter parameter using a var
                $PrinterWMI = Get-WMIObject -Class WIN32_Printer -Filter "name = $PrinterName"
                I've also noticed that I've haven't the same result using Get-CimInstance in particular with
                $PrinterCIM.psbase.scope
                However I'm sure that using Get-CiMInstance will be better, but i don't know how to proceed
                then I'm using the following "Legacy" approach
                #>
                $PrinterWMI = Get-WmiObject -Class WIN32_Printer | Where-Object -FilterScript { $_.Name -like $PrinterName }

                Write-Verbose "Enable SeSecurityPrivilege privilegies"
                $PrinterWMI.psbase.Scope.Options.EnablePrivileges = $true

                Write-Verbose "Invoke SetSecurityDescriptor method and write new ACE to specified"
                $PrinterWMI.SetSecurityDescriptor($SD)

                Write-Verbose "Treatment of $PrinterName : Completed"
            } # end if OnePrinter Parameter Set

            If ($PSCmdlet.ParameterSetName -eq "AllPrinters")
            {
                ForEach ($Server in $Servers)
                {
                    $Printers = Get-Printer -ComputerName $Server | Where-Object { $_.Shared -eq $true } -ErrorAction Stop
                    ForEach ($Printer in $Printers)
                    {
                        $PrinterName = $Printer.name
                        Write-Output "Beginning treatment of : $PrinterName"

                        Write-Verbose "Get printer object"
                        <#
                It seems that i can't use the Filter parameter using a var
                $PrinterWMI = Get-WMIObject -Class WIN32_Printer -Filter "name = $PrinterName"
                I've also noticed that I've haven't the same result using Get-CimInstance in particular with
                $Printer.psbase.scope
                then I'm using the following approach

                However I'm sure that using Get-CiMInstance will be better
                #>
                        $PrinterWMI = Get-WmiObject -Class WIN32_Printer | Where-Object -FilterScript { $_.Name -like $PrinterName }

                        Write-Verbose "Enable SeSecurityPrivilege privilegies"
                        $PrinterWMI.psbase.Scope.Options.EnablePrivileges = $true

                        Write-Verbose "Invoke SetSecurityDescriptor method and write new ACE to specified"
                        $PrinterWMI.SetSecurityDescriptor($SD)

                        Write-Output "Treatment of $PrinterName : Completed"
                    }
                }
            } # end if All Printers Parameter Set
        } # End Try

        catch
        {
            Write-Error "Hoops an error occured"
            Write-Error $_.Exception.Message
        }
    }

    end
    {
        Write-Output "All treatments : completed"

    }
} # end function