function Get-NetworkCards {
  <#
    .NOTES
        Author: greg zakharov
  #>
  
  begin {
    function ConvertTo-Date([UInt32]$i) {
      if ($i -ne $null) {
        [TimeZone]::CurrentTimeZone.ToLocalTime(
          [DateTime]'1.1.1970'
        ).AddSeconds($i)
      }
    }
    
    $keys = @(
      'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards\*',
      'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
    )
  }
  process {
    Get-ItemProperty $keys[0] | % {
      $desc = $_.Description
      Get-ItemProperty (Join-Path $keys[1] $_.ServiceName) | Select-Object  @{N='CardName'; E={$desc}}, 
                                                                            @{N='IPAddress'; E={$_.DhcpIPAddress}}, 
                                                                            @{N='SubnetMask'; E={$_.DhcpSubnetMask}}, 
                                                                            @{N='DHCPServer'; E={$_.DhcpNameServer}}, 
                                                                            @{N='LeaseObtained'; E={ConvertTo-Date $_.LeaseObtainedTime}}, 
                                                                            @{N='LeaseExpires'; E={ConvertTo-Date $_.LeaseTerminatesTime}}
    }
  }
  end {}
}