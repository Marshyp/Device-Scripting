# Step 1: Check if C:\Program Files (x86)\TeamViewer exists
$teamViewerPath = "C:\Program Files (x86)\TeamViewer"
$teamViewerPath2 = "C:\Program Files (x86)\TeamViewer\*"
if (Test-Path $teamViewerPath -PathType Container) {
    Write-Output "TeamViewer directory found at $teamViewerPath."

    # Step 2: Check if TeamViewer or TeamViewer_Service.exe is running and end the processes if running
    $teamViewerProcesses = Get-Process -Name TeamViewer, TeamViewer_Service -ErrorAction SilentlyContinue
    if ($teamViewerProcesses) {
        Write-Output "TeamViewer or TeamViewer_Service process is running. Ending the processes..."
        $teamViewerProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force }
    }

    # Step 2.1: Check for any service containing the name "TeamViewer" and stop it if running
    $teamViewerServices = Get-Service | Where-Object { $_.Name -like "*TeamViewer*" -or $_.DisplayName -like "*TeamViewer*" }
    if ($teamViewerServices) {
        Write-Output "Found TeamViewer related service(s). Stopping the services..."
        foreach ($service in $teamViewerServices) {
            Write-Output "Attempting to stop service: $($service.Name)"
            Stop-Service -Name $service.Name -Force
            Start-Sleep -Seconds 5  # Wait for a few seconds to give the service time to stop

            # Verify the service has stopped
            $service.Refresh()
            if ($service.Status -ne 'Stopped') {
                Write-Output "Failed to stop service $($service.Name). Attempting to kill the associated process..."
                $serviceProcess = Get-WmiObject -Class Win32_Process | Where-Object { $_.Name -like "*TeamViewer*" }
                if ($serviceProcess) {
                    $serviceProcess.Terminate() | Out-Null
                    Write-Output "Process $($serviceProcess.Name) terminated."
                } else {
                    Write-Warning "Could not find associated process for service $($service.Name)."
                }

                # Verify again if the service has stopped
                $service.Refresh()
                if ($service.Status -ne 'Stopped') {
                    Write-Warning "Service $($service.Name) is still running. Manual intervention may be required."
                }
            } else {
                Write-Output "Service $($service.Name) stopped successfully."
            }
        }
    }

    # Step 3: Run uninstall.exe silently if it exists
    $uninstallPath = Join-Path -Path $teamViewerPath -ChildPath "uninstall.exe"
    if (Test-Path $uninstallPath -PathType Leaf) {
        Write-Output "Uninstalling TeamViewer silently..."
        Start-Process -FilePath $uninstallPath -ArgumentList "/S" -Wait -NoNewWindow
    } else {
        Write-Output "Uninstall executable not found at $uninstallPath."
    }

    # Step 4: Check if TeamViewer folder still exists and delete if it does
    if (Test-Path $teamViewerPath2 -PathType Container) {
        Write-Output "Deleting TeamViewer directory at $teamViewerPath."
        Remove-Item -Path $teamViewerPath2 -Force -Recurse
        Remove-Item -Path $teamViewerPath -Force -Recurse
    } else {
        Write-Output "TeamViewer directory has been successfully removed."
    }
} else {
    Write-Output "TeamViewer directory not found at $teamViewerPath."
}

# Step 5: Search for and delete registry keys related to TeamViewer in HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
$regPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
$teamViewerKeys = Get-ChildItem -Path $regPath | Where-Object { $_.PSChildName -like "*TeamViewer*" -or (Get-ItemProperty $_.PSPath).DisplayName -like "*TeamViewer*" }

if ($teamViewerKeys) {
    foreach ($key in $teamViewerKeys) {
        Write-Output "Deleting registry key: $($key.PSPath)"
        Remove-Item -Path $key.PSPath -Force -Recurse
    }
} else {
    Write-Output "No TeamViewer registry keys found."
}

$Folderpath = "C:\JMW-Deploy\TeamViewer\"
$Marker = "C:\JMW-Deploy\TeamViewer\TVMarkerFile.txt"

# Check if the file exists
if (-not (Test-Path -Path $Folderpath)) {
    # The file does not exist, create it
    New-Item -Path $FolderPath -ItemType Directory
    Write-Host "Directory created: $Folderpath" -ForegroundColor Yellow
    New-Item -Path $Marker -ItemType File
    Write-Host "Marker File Created" -ForegroundColor Yellow
} else {
    Write-Host "Directory already exists: $Folderpath" -ForegroundColor Green
    Write-Host "Creating Marker File"
    New-Item -Path $Marker -ItemType File
    Write-Host "Marker File created at: $Marker" -ForegroundColor Green
}
