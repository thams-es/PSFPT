function Enumerate-Shares 
{
<#
.SYNOPSIS
PowerShell cmdlet to enumerate shares in the netowrk with with deffrent permisions.

.DESCRIPTION
This is script will enumerate all the shares on specified computer or range of IPs, by default it will enumerate share of the localhost.

.PARAMETER IPsList
Text file containing IPs in each line.

.PARAMETER ComputerName
Specify the host to enumerate shares for.

.EXAMPLE
PS C:\> . .\Enumerate-Shares.ps1
PS C:\> Enumerate-Shares
PS C:\> Enumerate-Shares -ComputerName 192.168.111.1
PS C:\> Enumerate-Shares -IPsList listOfIPs.txt

.LINK
https://winception.wordpress.com/2011/02/14/windows-share-permissions-and-using-powershell-to-manipulate-them/ 
https://gallery.technet.microsoft.com/scriptcenter/List-Share-Permissions-83f8c419
https://gallery.technet.microsoft.com/scriptcenter/Powershell-script-to-get-39c73c74

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222
#>
    [CmdletBinding()]
    param (
        # The Computer Name to list it's shares
        [Parameter(Mandatory=$false)]
        [String]
        $ComputerName = "127.0.0.1", 

        # List of computer IPs to list it's shares
        [Parameter(Mandatory=$false)]
        [String]
        $IPsList
    )
    
    function Enumerate-SharePermisions 
    {
        try
        {
            # Store shares name of the Computer Specified
            Write-Verbose "Listing shares on $ComputerName"
            $shares = Get-WmiObject -Class win32_share -ComputerName $ComputerName  | select -ExpandProperty Name
        }

        catch
        {
            # Computer unreachable
            Write-Host "Can't connect to $ComputerName" -ForegroundColor Red  
       
        }


        foreach ($share in $shares) 
        {
            $shareSecObj = Get-WmiObject -Class win32_LogicalShareSecuritySetting -Filter "Name='$Share'" -ComputerName $ComputerName
            
            try
            {
                # Saving the security descriptor
                $Return = $shareSecObj.invokeMethod('GetSecurityDescriptor',$null,$null)
                $SecDes = $Return.Descriptor
                foreach ($ACE in $SecDes.DACL)
                {
                    $UserName = $ACE.Trustee.Name      
                    If ($ACE.Trustee.Domain -ne $Null)
                    {
                        $UserName = "$($ACE.Trustee.Domain)\$UserName"
                    }    
                    If ($ACE.Trustee.Name -eq $Null)
                    {
                        $UserName = $ACE.Trustee.SIDString
                    }
                    
                    
                    If ($ACE.AccessMask -eq "2032127")
                    {
                        Write-Host $('=' * 90)
                        Write-Host "Share Name: $share" -ForegroundColor Green
                        Write-Host "Permision: Full Controll" -ForegroundColor Green
                        Write-Host ' '
                        $fShare = New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)
                        $fShare
                        Write-Host $('=' * 90)
                    }

                    If ($ACE.AccessMask -eq "1179785")
                    {
                        Write-Host $('=' * 90)
                        Write-Host "Share Name: $share" -ForegroundColor Green
                        Write-Host "Permision: Read" -ForegroundColor Green
                        Write-Host ' '
                        $fShare = New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)
                        $fShare
                        Write-Host $('=' * 90)
                    }

                    If ($ACE.AccessMask -eq "1179926")
                    {
                        Write-Host $('=' * 90)
                        Write-Host "Share Name: $share" -ForegroundColor Green
                        Write-Host "Permision Write" -ForegroundColor Green
                        Write-Host ' '
                        $fShare = New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)
                        $fShare
                        Write-Host $('=' * 90)
                    }
                }  
        
            }
            catch
            {
                Write-Host "Cannot list permisions for: $share" -ForegroundColor Red
            }
        }
    }
    
    
	if ($IPsList)
	{
		$IPs = Get-Content $IPsList
		foreach ($IP in $IPs)
		{
            Write-Host "Enumerating Share for $IP" -ForegroundColor Yellow  
            Write-Host " "
			Enumerate-SharePermisions($IP)
		}
	}
	else
	{
        Write-Host "Enumerating Share for: $ComputerName" -ForegroundColor Yellow
        Write-Host " "
		Enumerate-SharePermisions($ComputerName)
	}


}
