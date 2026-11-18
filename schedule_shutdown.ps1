# Creates (or replaces) a Windows scheduled task that runs shutdown.py.
#
# Run it from PowerShell, in the folder that holds this file and shutdown.py:
#   powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1
#
# Defaults to every Wednesday at 23:00. To change that:
#   powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1 -Day Friday -Time 22:30
#   powershell -ExecutionPolicy Bypass -File .\schedule_shutdown.ps1 -Day "Monday,Wednesday"

param(
    [string]$Day = "Wednesday",
    [string]$Time = "23:00",
    [string]$TaskName = "ComputerOff"
)

# shutdown.py must sit next to this file.
$script = Join-Path $PSScriptRoot "shutdown.py"
if (-not (Test-Path $script)) {
    Write-Error "Cannot find $script. Keep schedule_shutdown.ps1 and shutdown.py in the same folder."
    exit 1
}

# Find the real python.exe. The task must start python.exe with the script as
# its argument; starting shutdown.py directly makes Windows ask which app to open it with.
$python = $null
foreach ($name in "python", "py") {
    if (Get-Command $name -ErrorAction SilentlyContinue) {
        $out = & $name -c "import sys; print(sys.executable)" 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) {
            $python = "$out".Trim()
            break
        }
    }
}
if (-not $python) {
    Write-Error "Python was not found. Install it from python.org and tick 'Add python.exe to PATH'."
    exit 1
}

# From here on, stop at the first error (for example a misspelled day name).
$ErrorActionPreference = "Stop"

$days = $Day -split "," | ForEach-Object { [System.DayOfWeek]($_.Trim()) }

$action  = New-ScheduledTaskAction -Execute $python -Argument "`"$script`""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $days -At $Time
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Force | Out-Null

Write-Host "Scheduled task '$TaskName' created."
Write-Host "  Runs:   $python `"$script`""
Write-Host "  When:   every $($days -join ', ') at $Time"
Write-Host "  Next:   $((Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo).NextRunTime)"
