@echo off
setlocal enabledelayedexpansion

set "baseIP=192.168.178."
set "startIP=1"
set "endIP=254"

echo Pinging IP addresses from %baseIP%%startIP% to %baseIP%%endIP%...

for /L %%i in (%startIP%, 1, %endIP%) do (
    set "ip=%baseIP%%%i"    
    ping -n 1 -w 1 !ip! > nul
    if errorlevel 1 (
        REM !ip! is unreachable
	echo|set /p="."
    ) else (
        for /f "tokens=2" %%h in ('nslookup !ip! ^| find "Name:"') do (
            echo.
	    echo !ip! is reachable - Name: %%h
        )
    )
)

pause
