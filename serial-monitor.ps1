############################################
# Serial Monitor
#
#  v1.00 Milc 2024-02-01 Initial version
#
#  Author: Milan Stubljar of Stubljar d.o.o. (milan@stubljar.com)

# Command Line Params Handling
Param(
    [Parameter(Mandatory=$false)][ValidateSet("true", "false", "yes", "no", "0", "1")][string]$reset_now="false"
)

$forceReset = $false
switch($reset_now.ToLower()) {
    "1" { $forceReset = $true }
    "yes" { $forceReset = $true }
    "true" { $forceReset = $true }
    default { $forceReset = $false }
}

#
# GLOBAL SETTINGS:
#

$version    = "PC Serial Monitor v1.0"   # Version String
$environment= 'Development'
$comPort    = 'COM3'    # Set to COM port of the monitor
$logFileName= 'serial.log'
$maxRetry   = 50        # Max Retries
$retrySleep = 5000      # Delay between Retries
$boudRate   = 9600

#
# INTERALS - DO NOT CHANGE
#

$openCnt = 0
$isOpen = $false
$port= new-Object System.IO.Ports.SerialPort $comPort,$boudRate,None,8,one

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Critical','Debug')]
        [string]$Severity = 'Information',

        [Parameter()]
        [System.ConsoleColor]$ForegroundColor = 'Gray'
    )

    [hashtable]$levels = [ordered]@{
        Information = 'INFO';
        Error = "ERROR";
        Debug = 'DEBUG';
        Warning = 'WARN';
        Critical = 'CRITICAL'
    }

    if ($True)
    {
        [pscustomobject]@{
            Message = $Message
        } | Export-Csv -Path "$logFileName" -Append -NoTypeInformation
        
        [pscustomobject]@{
            Time = (Get-Date -f "yyyy-MM-dd HH:mm:ss.ffff")
            Message = $Message
            Severity = $Severity
        } | Export-Csv -Path "$logFileName.csv" -Append -NoTypeInformation
        
    }
    $Time = (Get-Date -f "yyyy-MM-dd HH:mm:ss.ffff")
    Write-Host "$Time [$($levels[$Severity])] $Message" -ForegroundColor $ForegroundColor
 } # Write-Log

function Open-Serial()
{
    try 
    {
        $port.Open()
        return $true
    }
    catch
    {
      Write-Log -Message $_.Exception.Message -Severity "Error" -ForegroundColor Red
    }
    return $false
} # Open-Serial

# Open Serial Port with retry
function Open-Serial-Port()
{
    while (-Not($isOpen = Open-Serial) -and ($openCnt -lt $maxRetry))
    {
        $openCnt += 1
        Write-Log "Retrying in 5 sec." -Severity "Error" -ForegroundColor Red
        Start-Sleep -Milliseconds $retrySleep
    }

    if ($isOpen -eq $false)
    {
        Write-Log "Could not open serial port. Aborting." -Severity "Error" -ForegroundColor Red
        exit
    }
    Write-Log "Serial port $comPort succesfully opened." -ForegroundColor Green
} # Open-Serial-Port

function Read-Serial()
{
    # Attempt to read from serial
    $stopwatch = New-Object System.Diagnostics.Stopwatch
    $stopwatch.Start()
    while ($stopwatch.ElapsedMilliseconds -lt 1000)
    {
        if ($port.BytesToRead -gt 0)
        {
            $so = $port.ReadLine()
            Write-Log "Received: $so"
        }
        Start-Sleep -Milliseconds 100
    }
    $stopwatch.Stop()
} # Read-Serial


# MAIN
# MAIN
# MAIN

try {
	if ($environment -eq "Development")
	{
		$host.UI.RawUI.WindowTitle = "$version $environment @ $comPort"
	} else {
		$host.UI.RawUI.WindowTitle = $version
	}
    Write-Log "$version by Milc 2024-01-02" -ForegroundColor Cyan

    Write-Log "ForceReset (-reset_now): $forceReset" -ForegroundColor Magenta

    Open-Serial-Port
    [console]::TreatControlCAsInput = $true

    $n = 0
    while ($true) {
        $n+=1

        # Output the version string
        if ($n % 25 -eq 0) {
          Write-Host " "
          Write-Log $version -ForegroundColor Cyan
        }

        Read-Serial

        # Check if CTRL-C was pressed and exit gracefully
        if ([Console]::KeyAvailable) {
          $key = [Console]::ReadKey($true)
          if ($key.key -eq "C" -and $key.modifiers -eq "Control") { 
            Write-Log "Detected Ctrl-C. Housekeeping and exiting."
            $port.Close()
            exit
          }
        }

        # Wait some time before next PING
        # Write-Log "Sleeping for $($pingSleep/1000)s"
        # Start-Sleep -Milliseconds $pingSleep

    } # while ($true)
    $port.Close()

} finally {

   # No matter what the user did, reset the console to process Ctrl-C inputs 'normally'
    [console]::TreatControlCAsInput = $false

    if ($isOpen -eq $false) {
        $port.Close()
    }
}

# Last line, well almost.
