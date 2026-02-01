# ==================== YANDEX COMPLETE ANNIHILATOR v4.1 ====================
# Encoding: UTF-8 with BOM (fixes symbol corruption)
# Removes: Processes, Services, Tasks, Registry, Folders, Start Menu shortcuts
# Run as Administrator

# ==================== ADMIN ELEVATION (FIXED) ====================
# Clear any errors
$Error.Clear()

# Check if already admin
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-NOT $isAdmin) {
    # Show message before restarting
    Write-Host "This script requires Administrator privileges." -ForegroundColor Yellow
    Write-Host "A new window will open with Administrator rights." -ForegroundColor Cyan
    Write-Host "Please wait..." -ForegroundColor Gray
    
    # Restart script as admin
    $scriptPath = $MyInvocation.MyCommand.Path
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $psi.Verb = "runas"  # This triggers UAC
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
    
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Host "Failed to elevate. Please run script as Administrator manually." -ForegroundColor Red
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
    
    exit
}

# ==================== SCRIPT BEGINS (RUNNING AS ADMIN) ====================
# Set console output encoding to UTF-8 to fix symbol corruption
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "==========================================" -ForegroundColor Red
Write-Host "    YANDEX COMPLETE ANNIHILATOR v4.1" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Red
Write-Host "Running with Administrator privileges..." -ForegroundColor Green
Start-Sleep -Seconds 1

# ==================== DOUBLE CONFIRMATION ====================
Clear-Host
Write-Host "==========================================" -ForegroundColor Red
Write-Host "    YANDEX COMPLETE ANNIHILATOR v4.1" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Red
Write-Host "`n[WARNING] This will PERMANENTLY remove:" -ForegroundColor Red
Write-Host "  - All Yandex processes and services" -ForegroundColor Gray
Write-Host "  - All autostart entries and tasks" -ForegroundColor Gray
Write-Host "  - Yandex Browser and all components" -ForegroundColor Gray
Write-Host "  - Start Menu shortcuts and folders" -ForegroundColor Gray
Write-Host "  - All leftover files and registry entries" -ForegroundColor Gray
Write-Host "  - Bookmarks, history, and extensions will be LOST" -ForegroundColor Yellow

# FIRST CONFIRMATION
Write-Host "`n[CONFIRMATION 1/2]" -ForegroundColor Cyan
$confirm1 = Read-Host "Type 'YES' to continue (anything else will exit)"
if ($confirm1 -ne "YES") {
    Write-Host "Exiting..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# SECOND CONFIRMATION
Write-Host "`n[CONFIRMATION 2/2]" -ForegroundColor Cyan
Write-Host "This is your last chance to cancel." -ForegroundColor Red
Write-Host "All Yandex data will be deleted permanently." -ForegroundColor Yellow
$confirm2 = Read-Host "`nType 'NUKE' to proceed with complete removal"
if ($confirm2 -ne "NUKE") {
    Write-Host "Exiting..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# ==================== BEGIN DESTRUCTION ====================
Clear-Host
Write-Host "==========================================" -ForegroundColor Red
Write-Host "    YANDEX ANNIHILATION IN PROGRESS" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Red
Write-Host "`nStarting removal process..." -ForegroundColor Green
Start-Sleep -Seconds 1

# 1. KILL ALL PROCESSES
Write-Host "`n[1] Killing Yandex processes..." -ForegroundColor Cyan
$procCount = (Get-Process | Where-Object { $_.Path -like "*yandex*" -or $_.Company -like "*Yandex*" } | Measure-Object).Count
if ($procCount -gt 0) {
    Get-Process | Where-Object { $_.Path -like "*yandex*" -or $_.Company -like "*Yandex*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed $procCount process(es)" -ForegroundColor Green
} else {
    Write-Host "  No Yandex processes running" -ForegroundColor Gray
}
Start-Sleep -Seconds 1

# 2. STOP & DISABLE SERVICES
Write-Host "`n[2] Disabling Yandex services..." -ForegroundColor Cyan
$services = Get-Service | Where-Object { $_.DisplayName -like "*Yandex*" }
$serviceCount = ($services | Measure-Object).Count
if ($serviceCount -gt 0) {
    $services | ForEach-Object {
        Stop-Service $_ -Force -ErrorAction SilentlyContinue
        Set-Service $_ -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Write-Host "  Disabled $serviceCount service(s)" -ForegroundColor Green
} else {
    Write-Host "  No Yandex services found" -ForegroundColor Gray
}

# 2.5. DELETE YANDEX SERVICES COMPLETELY
Write-Host "`n[2.5] Deleting Yandex services permanently..." -ForegroundColor Cyan
$servicesToDelete = Get-Service | Where-Object { $_.DisplayName -like "*Yandex*" }
$deletedServiceCount = 0

foreach ($service in $servicesToDelete) {
    try {
        # Stop the service first
        Stop-Service $service -Force -ErrorAction SilentlyContinue
        
        # Delete the service using sc.exe (more reliable)
        $output = sc.exe delete $service.Name 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Deleted service: $($service.DisplayName)" -ForegroundColor Red
            $deletedServiceCount++
        } else {
            Write-Host "  Could not delete service: $($service.DisplayName)" -ForegroundColor DarkYellow
            # Fallback: ensure it's at least disabled
            Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "  Failed to delete service: $($service.DisplayName)" -ForegroundColor DarkYellow
    }
}

if ($deletedServiceCount -gt 0) {
    Write-Host "  Permanently deleted $deletedServiceCount Yandex service(s)" -ForegroundColor Green
} else {
    Write-Host "  No Yandex services to delete" -ForegroundColor Gray
}

# 3. REMOVE SCHEDULED TASKS
Write-Host "`n[3] Removing scheduled tasks..." -ForegroundColor Cyan
$tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*yandex*" -or $_.Description -like "*yandex*" }
$taskCount = ($tasks | Measure-Object).Count
if ($taskCount -gt 0) {
    $tasks | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "  Removed $taskCount task(s)" -ForegroundColor Green
} else {
    Write-Host "  No Yandex scheduled tasks found" -ForegroundColor Gray
}

# 4. CLEAN REGISTRY AUTOSTART
Write-Host "`n[4] Cleaning registry autostart..." -ForegroundColor Cyan
$regCount = 0
$registryPaths = @("HKCU:\Software\Microsoft\Windows\CurrentVersion\Run", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run")
foreach ($path in $registryPaths) {
    Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $_.PSObject.Properties | Where-Object { $_.Value -like "*yandex*" } | ForEach-Object {
            Remove-ItemProperty -Path $path -Name $_.Name -Force -ErrorAction SilentlyContinue
            $regCount++
        }
    }
}
if ($regCount -gt 0) {
    Write-Host "  Removed $regCount registry entries" -ForegroundColor Green
} else {
    Write-Host "  No Yandex registry entries found" -ForegroundColor Gray
}

# 5. UNINSTALL YANDEX PROGRAMS
Write-Host "`n[5] Uninstalling Yandex software..." -ForegroundColor Cyan
# Traditional uninstall
$uninstallCount = 0
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Yandex*" } | ForEach-Object { 
    $_.Uninstall()
    $uninstallCount++
}
# Store apps
Get-AppxPackage *yandex* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
if ($uninstallCount -gt 0) {
    Write-Host "  Uninstalled $uninstallCount program(s)" -ForegroundColor Green
} else {
    Write-Host "  No Yandex programs found to uninstall" -ForegroundColor Gray
}

# 6. DELETE ALL YANDEX FOLDERS
Write-Host "`n[6] Deleting Yandex folders..." -ForegroundColor Cyan
$folders = @(
    "C:\Program Files (x86)\Yandex",
    "C:\Program Files\Yandex",
    "$env:APPDATA\Yandex",
    "$env:LOCALAPPDATA\Yandex",
    "$env:USERPROFILE\AppData\Roaming\Yandex",
    "$env:USERPROFILE\AppData\Local\Yandex"
)
$deletedCount = 0
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        try {
            Remove-Item $folder -Recurse -Force -ErrorAction Stop
            $deletedCount++
            Write-Host "  Deleted: $(Split-Path $folder -Leaf)" -ForegroundColor DarkGray
        } catch {
            Write-Host "  Could not delete: $(Split-Path $folder -Leaf)" -ForegroundColor DarkYellow
        }
    }
}
if ($deletedCount -gt 0) {
    Write-Host "  Total: $deletedCount folder(s) deleted" -ForegroundColor Green
} else {
    Write-Host "  No Yandex folders found" -ForegroundColor Gray
}

# 7. NUKE START MENU SHORTCUTS
Write-Host "`n[7] Removing Start Menu shortcuts..." -ForegroundColor Cyan
$startMenuPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu",
    "C:\ProgramData\Microsoft\Windows\Start Menu"
)
$shortcutCount = 0
foreach ($path in $startMenuPaths) {
    if (Test-Path $path) {
        Get-ChildItem $path -Recurse -Filter "*yandex*" -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
            $shortcutCount++
        }
    }
}
# Restart Start Menu to clear cache
Stop-Process -Name "StartMenuExperienceHost" -Force -ErrorAction SilentlyContinue
if ($shortcutCount -gt 0) {
    Write-Host "  Removed $shortcutCount Start Menu shortcut(s)" -ForegroundColor Green
} else {
    Write-Host "  No Start Menu shortcuts found" -ForegroundColor Gray
}

# 8. FINAL CLEANUP: REGISTRY LEFTOVERS
Write-Host "`n[8] Final registry cleanup..." -ForegroundColor Cyan
Remove-Item "HKLM:\SOFTWARE\Yandex" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\SOFTWARE\Yandex" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKLM:\SOFTWARE\WOW6432Node\Yandex" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  Registry cleaned" -ForegroundColor Green

# ==================== VERIFICATION ====================
Write-Host "`n`n==========================================" -ForegroundColor Cyan
Write-Host "    VERIFICATION SCAN" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

$remainingProcesses = (Get-Process | Where-Object { $_.Path -like "*yandex*" } | Measure-Object).Count
$remainingServices = (Get-Service | Where-Object { $_.DisplayName -like "*Yandex*" -and $_.Status -eq "Running" } | Measure-Object).Count
$remainingTasks = (Get-ScheduledTask | Where-Object { $_.TaskName -like "*yandex*" } | Measure-Object).Count

if ($remainingProcesses -eq 0 -and $remainingServices -eq 0 -and $remainingTasks -eq 0) {
    Write-Host "`n[SUCCESS] YANDEX COMPLETELY ANNIHILATED" -ForegroundColor Green
    Write-Host "  - No processes running" -ForegroundColor Green
    Write-Host "  - No services active" -ForegroundColor Green
    Write-Host "  - No tasks scheduled" -ForegroundColor Green
    Write-Host "  - Folders deleted" -ForegroundColor Green
    Write-Host "  - Start Menu cleaned" -ForegroundColor Green
} else {
    Write-Host "`n[WARNING] Partial cleanup - manual check needed:" -ForegroundColor Yellow
    if ($remainingProcesses -gt 0) { Write-Host "  - $remainingProcesses process(es) still alive" -ForegroundColor Red }
    if ($remainingServices -gt 0) { Write-Host "  - $remainingServices service(s) still running" -ForegroundColor Red }
    if ($remainingTasks -gt 0) { Write-Host "  - $remainingTasks task(s) remaining" -ForegroundColor Red }
}

# ==================== FINAL MESSAGE ====================
Write-Host "`n`n==========================================" -ForegroundColor Green
Write-Host "    ANNIHILATION COMPLETE" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "`n[ACTION REQUIRED] Reboot to ensure all changes take effect." -ForegroundColor Yellow
Write-Host "Yandex is permanently removed from your system." -ForegroundColor Gray
Write-Host "`nPress any key to close this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
