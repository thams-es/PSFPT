function SimpleHTTPServer 
{
<#
.SYNOPSIS
A simple web server in PowerShell which could be used to list, delete, download and upload files over HTTP.

.DESCRIPTION
A simple web server in PowerShell which could be used to list, delete, download and upload files over HTTP.


.EXAMPLE
PS C:\> . .\Invoke-SimpleHTTPServer.ps1
PS C:\> SimpleHTTPServer

.PARAMETER HttpPort
The port number for the HTTP

.PARAMETER HttpsPport
The port number for HTTPS 

.LINK
https://gist.github.com/pmolchanov/0120a26a6ca8d88220a8
https://gist.github.com/zhilich/b8480f1d22f9b15d4fdde07ddc6fa4ed
https://4sysops.com/archives/building-a-web-server-with-powershell/#wrap-up

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222


#>   

[CmdletBinding()] Param( 

       [Parameter(Mandatory = $false)]
       [String]
       $HttpPort = "80" ,
       
       [Parameter(Mandatory = $false)]
       [String]
       $HttpsPort = "443"

    )






#Use the following commands to bind/unbind SSL cert
#netsh http add sslcert ipport=0.0.0.0:443 certhash=3badca4f8d38a85269085aba598f0a8a51f057ae "appid={00112233-4455-6677-8899-AABBCCDDEEFF}"
#netsh http delete sslcert ipport=0.0.0.0:443 
#For more information: https://stackoverflow.com/questions/11403333/httplistener-with-https-support



$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$HttpPort/")
$listener.Prefixes.Add("https://localhost:$HttpsPort/")
$listener.Start()

Write-Host "Listening at http://localhost:$HttpPort/ and https://localhost:$HttpsPort/..."

    while ($listener.IsListening)
    {
        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url
        $response = $context.Response
        $requestPath = $requestUrl.localpath
        Write-Host ''
        Write-Host "> $requestUrl"
        Write-Host "> $requestPath "
        
        
        if ($requestPath -eq "/kill") ####### Killing listener ############
        {
        $response.Close()
        $listener.Stop()
        return
        }


        if ($requestPath -eq "/list") ####### listinf directory ############
        {
        $list = Invoke-Expression dir
        $html = "<html><body><b>Directory listing:</b> <br> $list </br> </body></html>"
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    
        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"
        

        }


        
    if($requestPath -eq "/upload")  ####### uploading file ############
    {
      $Upload ='<html><body><form method="GET" enctype="multipart/form-data" action="/upload"><p><b>File to upload:</b><input type="file" name="filedata"></p><input type="submit" name="button" value="Upload"></form></body></html>'

      $test = (Set-Content -Path (Join-Path "." ($context.Request.QueryString[0])) -Value ($context.Request.QueryString[1]))
      $buffer = [System.Text.Encoding]::UTF8.GetBytes($Upload)
      $response.ContentLength64 = $buffer.Length
      $response.OutputStream.Write($buffer, 0, $buffer.Length)
      $response.Close()
    }



    if($requestPath -eq "/download")  ####### Download file ############
    {
        

        $currentDir = Get-Location
        $filePath = "$currentDir\" + $context.Request.QueryString[0]
        $filename = $context.Request.QueryString[0]
        Write-Host "Downloading: $filename" -ForegroundColor Yellow
        $buffer = [System.IO.File]::ReadAllBytes($filePath)
        $response.SendChunked = $FALSE
        $response.ContentType = "application/octet-stream"
        $response.AddHeader("Content-Disposition", "attachment; filename=$filename")
        $response.ContentLength64 = $buffer.Length

    }






    if($requestPath -eq "/delete") ####### Deleting file ############
    {
        $item = $context.Request.QueryString[0] 
        Write-Host "Removing $item"
        try
        {
            Remove-Item $item
            $html = "<html><body><b>$item</b> Removed successfuly! </body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }

        catch
        {
            $html = "<html><body>file <b>$item</b> Cannot not be found </body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
        }
    }


        else
        {
        $buffer = [System.Text.Encoding]::UTF8.GetBytes('<html><body>Hello world!</body></html>')
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    
        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"
        }

    
        
    }
}