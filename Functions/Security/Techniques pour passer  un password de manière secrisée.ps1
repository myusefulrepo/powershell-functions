     <#For credentials that need to be saved to disk, 
    serialize the credential object using Export-CliXml to protect the password value. 
    The password will be protected as a secure string 
    and will only be accessible to the user who generated the file on the same computer where it was generated.
    #>
    # Save a credential to disk
    Get-Credential | Export-CliXml -Path c:\temp\credential.xml
  
    # Import the previously saved credential
    $Credential = Import-CliXml -Path c:\temp\credential.xml


    
    <#
    For strings that may be sensitive and need to be saved to disk, 
    use ConvertFrom-SecureString to encrypt it into a standard string that can be saved to disk. 
    You can then use ConvertTo-SecureString to convert the encrypted standard string back into a SecureString. 
    NOTE: These commands use the Windows Data Protection API (DPAPI) to encrypt the data, 
    so the encrypted strings can only be decrypted by the same user on the same machine, 
    but there is an option to use AES with a shared key.
    #>
    # Prompt for a Secure String (in automation, just accept it as a parameter)
    $Secure = Read-Host -Prompt "Enter the Secure String" -AsSecureString

    # Encrypt to Standard String and store on disk
    ConvertFrom-SecureString -SecureString $Secure | Out-File -Path "${Env:AppData}\Sec.bin"

    # Read the Standard String from disk and convert to a SecureString
    $Secure = Get-Content -Path "${Env:AppData}\Sec.bin" | ConvertTo-SecureString