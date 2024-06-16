function Write-Log() {   

    param (
        [ValidateSet("Error", "Information","Warning")] 
        [string]$LogType,
        [string]$LogMsg,
        [string]$LogFunction 
    )  
 
    if (!$IsLogFileCreated) {   
        Write-Host "Creating Log File..."   
        if (!(Test-Path -path $global:LogFilePath)) {  
            Write-Host "Please Provide Proper Log Path" -ForegroundColor Red   
        }   
        else {   

            $script:IsLogFileCreated = $True   
            Write-Host "Log File ($LogFile) Created..."   
            [string]$LogMessage = [System.String]::Format("[$(Get-Date)] - [{0}] -[{1}] - {2}", $LogType, $LogFunction, $LogMsg)   
            Add-Content -Path $global:LogFilePath -Value $LogMessage 
        }   
    }   
    else {   
        [string]$LogMessage = [System.String]::Format("[$(Get-Date)] - [{0}] -[{1}] - {2}", $LogType, $LogFunction, $LogMsg)    
        Add-Content -Path $global:LogFilePath -Value $LogMessage   
    }   
}

function Main {

    $DateTime = (Get-Date -Format "yyyyMMdd_HHmmss").ToString()
        
    $LogFilename = 'DiskCleanupScript'
    $global:LogFilePath = "D:\Logs\$LogFileName.log"

    $Paths = @('C:\windows\SoftwareDistribution\Download')
    try {
        $CleanupItems = Get-ChildItem -Path $Paths | select -ExpandProperty FullName
        Write-Log -LogType Information -LogFunction 'Main' -LogMsg "Found $($CleanupItems.Count) temp files to be cleaned up from the $env:COMPUTERNAME"
        if(!$CleanupItems){
            Write-Log -LogType Warning -LogFunction 'Main' -LogMsg "Could not find any temp files for cleanup operation on $env:COMPUTERNAME, hence terminating script"
            Exit            
        }
    }
    catch {
        Write-Log -LogType Error -LogFunction 'Main' -LogMsg "Error getting temp files for cleanup operation on $env:COMPUTERNAME"
    }
    foreach ($Item in $CleanupItems) {
        try {
            Remove-Item -Path $Item -Recurse -Force -ErrorAction SilentlyContinue 
            Write-Log -LogType Information "Successfully cleaned up $Item from $env:COMPUTERNAME" -LogFunction 'Main'
        }
        catch {
            Write-Log -LogType Error "Could not delete $Item from $env:COMPUTERNAME, $_" -LogFunction 'Main'
        }
    }
}

Main 