function Transfer-FileRemotely {
<#

.SYNOPSIS
PowerShell cmdlet to trasfer a file to a remote machine

.DESCRIPTION
PowerShell cmdlet to trasfer a file to a remote machine

.PARAMETER File
The local file to transfer remotely.

.PARAMETER Computer
Computer name or IP address to the remote machine.

.PARAMETER DestinationPath
The remote path on which the file will be copied.

.PARAMETER User
The user to use for remoting.

.EXAMPLE
PS C:\> . .\Transfer-FileRemotely.ps1
PS C:\> Transfer-FileRemotely -File "C:\t.txt" -DestinationPath c:\t.txt -Computer 192.168.111.129 -User TestDomain.com\Khaled

.LINK
https://stackoverflow.com/questions/10741609/copy-file-remotely-with-powershell

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222


#>
    


    [CmdletBinding()]
    param (
        
		[Parameter(Mandatory = $true)]
		[String]
		$File,
		
		[Parameter(Mandatory = $true)]
		[String]
		$DestinationPath,
		
		[Parameter(Mandatory = $true)]
		[String]
		$Computer,
		
		[Parameter(Mandatory = $true)]
		[String]
		$User,
		
		[Parameter(Mandatory = $true)]
		[SecureString]
		$password
    )

    try 
    {
        $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$password
        Write-Host "Connecting to remote host with the credentials..." -ForegroundColor Yellow
        $session = New-PSSession -ComputerName $Computer -Credential $Credentials
        Write-Host "Transfering the file..." -ForegroundColor Yellow
        Copy-Item -ToSession $session $File -Destination $DestinationPath
        Write-Host "File to transfered sucessfully!" -ForegroundColor Green
    }
    catch 
    {
        Write-Host "Error Coudln't Transfer the file, Check your credentials or make sure the remote machine is up" -ForegroundColor Red
    }

	

}