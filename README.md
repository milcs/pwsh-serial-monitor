# Powershell Serial Monitor
_Author: Milan Štubljar (milan@stubljar.com)_

# How to execute
Run ```serial-monitor.cmd```

Edit the file and update your COM port. 
```powershell
$comPort    = 'COM3'    # Set to COM port of the monitor
```

# Output
The monitor will connect to COM port and starting receiving data.
Messages are printed on console and saved to ```serial.log``` as plain text and to ```serial.log.csv``` as CSV.

# Installation

You might need to deal with ExecutionPolicy.
There are really many ways to get around it; Check this [site](https://www.netspi.com/blog/technical/network-penetration-testing/15-ways-to-bypass-the-powershell-execution-policy/) for 15 ways to deal with it. 
