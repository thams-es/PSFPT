function Enumerate-Directory 
{
<#
.SYNOPSIS
A cmdlet to Enumerate directories inside C:\Windows\System32 which folder which are writable by non-admin users.

.DESCRIPTION
This script checks if the user can write in C:\Windows\System32 or any optional directory.

.PARAMETER dir
The directory to check for permissions (by default it will be "Windows\System32").

.PARAMETER user
The user to enumerate for it's permissions in specified directory.

.EXAMPLE
PS C:\> Enumerate-Directory
PS C:\> Enumerate-Directory -user POSH-DESKTOP\PC
PS C:\> Enumerate-Directory -dir C:\Users\PC\Docments\ -user POSH-DESKTOP\PC


.LINK
https://blogs.technet.microsoft.com/poshchap/2014/02/21/using-get-acl-to-identify-administrator-permissions/

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222

#>  


[CmdletBinding()] Param( 

    [Parameter(Mandatory = $false)]
    [String]
    $dir = 'C:\Windows\System32\',
    
    [Parameter(Mandatory = $false)]
    [String]
    $user = $env:UserName


)
    try
    {
    #$ErrorActionPreference = "Stop"
    $Directories = Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | Get-Acl
    }

    catch
    {
        Write-host "Test" -ForegroundColor Yellow
    }

    # finally
    # {
    #     $ErrorActionPreference = "Continue"
    # }

    foreach ($path in $Directories)
    {
        $ids = $path | Select-Object -ExpandProperty Access 
        
        foreach ($id in $ids)
        {
                
           if ($id.IdentityReference -like "*$user*")
            {
                Write-Host $Id.IdentityReference -ForegroundColor Green
                Write-Host $path.Path
            }
        }
    }
    
}
