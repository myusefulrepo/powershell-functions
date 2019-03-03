function Test-Server () {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ServerName
    )
 
    foreach ($name in $ServerName) {
        $monitors = @{
            PingAvailable          = { Test-Connection -ComputerName $name -Quiet -Count 1 }
            WuauServServiceRunning = { (Get-Service -Name 'wuauserv'  -ComputerName $name).Status -eq 'Running' }
            HTTPOpen               = { (Test-NetConnection -ComputerName $name -CommonTCPPort HTTP).TcpTestSucceeded }
        }
        $monitors.GetEnumerator().foreach( {
                if (-not (& $_.Value)) {
                    write-host "[$($_.Key)] is down on server [$($name)]!" -ForegroundColor Yellow
                    <# $emailParams = @{
                From = "YourEmail@email.com"
                To = 'someemail@email.com'
                Subject = 'Monitor Down'
                Body = "The monitor [$($_.Key)] is down on server [$($name)]!"
                SMTPServer = 'mailserver.lab.local'
                }#>
                    # Send-MailMessage @emailParams
                }
            })
    }
}