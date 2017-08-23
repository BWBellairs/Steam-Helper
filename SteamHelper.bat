@ECHO off
COLOR 03

REM --- Created by BWBellairs --- Version: 1.3.42

setlocal EnableExtensions EnableDelayedExpansion

:do_choice
TASKLIST /FI "IMAGENAME eq Steam.exe" 2>NUL | find /I /N "Steam.exe">NUL
IF "%ERRORLEVEL%"=="0" (

  ECHO Please close Steam or start updating your games in steam now.
  ECHO If you don't close steam, you will be taken staight to shutdown options
  TIMEOUT /t 20
  GOTO :do_shutdown_options

)

SET /P st_delay="Enter Number of Seconds to wait before starting steam: "
SET /A st_delay=%st_delay%
ECHO:

:do_shutdown_options
SET /P sh_delay_active="Want to shutdown after a delay or use Smart Shutdown? y/n "
ECHO %sh_delay_active%|FINDSTR /R /C:"^[y|n]$" > NUL
IF "%ERRORLEVEL%"=="1" GOTO :do_shutdown_options
ECHO:

SET "smart_shutdown_enabled="
SET "sh_mode="
SET "sh_delay="
IF "%sh_delay_active%"=="y" (

  :start_shutdown_enabled_loop
  SET /P smart_shutdown_enabled="Would you like to enable Smart Shutdown? Computer will shutdown when it has detected that Steam isn't downloading any updates for games. y/n "
  ECHO !smart_shutdown_enabled!|FINDSTR /R /C:"^[y|n]$" > NUL
  IF "!ERRORLEVEL!"=="1" GOTO :start_shutdown_enabled_loop

  IF NOT "!smart_shutdown_enabled!" EQU "y" (

    SET /P sh_delay="Enter Number of Seconds to wait before shutting down (Do an hour after the download eta) "
    SET /A sh_delay=%sh_delay%

  )

  :start_mode_loop
  ECHO %sh_mode%|FINDSTR /R /C:"^[s|h|r|S|H|R]$" > nul

  IF "!ERRORLEVEL!"=="1" (
 
   SET /P sh_mode="Shutdown mode restart(r) shutdown (s) hibernate/sleep (h): "
   GOTO :start_mode_loop

  )
 
  ECHO:

)

TASKLIST /FI "IMAGENAME eq Steam.exe" 2>NUL | find /I /N "Steam.exe">NUL
IF "%ERRORLEVEL%"=="1" (

  IF not defined sh_delay (
    
    ECHO Looks like Steam isn't active... Did the Process exit?
    SET /P st_delay="Enter Number of Seconds to wait before starting steam: "
    SET /A st_delay=%st_delay%
    ECHO:
  
  )

  ECHO Starting Steam in !st_delay! seconds
  TIMEOUT /t !st_delay! /nobreak


  ECHO:
  ECHO Starting Steam

  START steam://

  ECHO Steam launched

)

If "%sh_delay_active%" EQU "y" (
  
  IF NOT "%smart_shutdown_enabled%" EQU "y" (
    ECHO Starting Shutdown delay with mode %sh_mode%

    TIMEOUT /t %sh_delay% /nobreak

    ECHO Preparing to shutdown... if you wish to stop this, press WINDOWS KEY, type 'shutdown /a' then press ENTER
    ECHO Shutting down...

    SHUTDOWN /%sh_mode% /t 120
    PAUSE
    EXIT
  )
)

SET \A shutdown_attempts=0

IF "%sh_delay_active%" EQU "y" (

  IF "%smart_shutdown_enabled%" EQU "y" (

    ECHO Waiting for Steam to cease activity before shutting down

    :start_loop
    FOR /f "tokens=2 delims=," %%c in ('typeperf "\Process(Steam)\IO Data Operations/sec" -si 1 -sc 1 ^| find /V "\\"') do (
	
      IF %%c EQU "0.000000%" (

        SET /a shutdown_attempts=!shutdown_attempts!+1 

      ) ELSE (

        SET /a shutdown_attempts=0

      )  

      PING www.google.com -n 1 -w 1000 > nul
      IF "%ERRORLEVEL%"=="1" (SET internet_connected="false") else (SET internet_connected="true")

      IF "!internet_connected!"=="false" (SET /a shutdown_attempts=0)

      IF !shutdown_attempts!==10 GOTO :end_loop

      GOTO :start_loop
  
      :end_loop
      ECHO Preparing to shutdown... if you wish to stop this, press WINDOWS KEY, type 'shutdown /a' then press ENTER
      ECHO Shutting down...

      SHUTDOWN /%sh_mode% /t 120
      PAUSE
      EXIT
    )
  )
)

ECHO:
ECHO Program finished
ECHO:
ECHO -----------------------------------
ECHO BWBellairs' tips his fedora at you.
ECHO -----------------------------------
ECHO:
ECHO Press any key to exit

PAUSE
