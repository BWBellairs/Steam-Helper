@ECHO off
COLOR 03

REM --- Created by BWBellairs --- Version: 1.4.8

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
SET "sh_delay_active=n"
CHOICE /M "Want to shutdown after a delay or use Smart Shutdown?"
IF "%ERRORLEVEL%"=="1" (
  SET "sh_delay_active=y"
)
ECHO:

SET "smart_shutdown_enabled="
SET "sh_mode="
SET "sh_delay="
IF "%sh_delay_active%"=="y" (

  SET "smart_shutdown_enabled=n"
  CHOICE /M "Would you like to enable Smart Shutdown? Computer will shutdown when it has detected that Steam isn't downloading any updates for games."
  IF "!ERRORLEVEL!"=="1" (
    SET "smart_shutdown_enabled=y"
  )

  IF NOT "!smart_shutdown_enabled!" EQU "y" (

    SET /P "sh_delay=Enter Number of Seconds to wait before shutting down (Do an hour after the download eta) "
    SET /A sh_delay=!sh_delay!

  )
 
  CHOICE /C rsh /M "Shutdown mode restart(r) shutdown (s) hibernate/sleep (h): "
  IF "!ERRORLEVEL!"=="1" (SET "sh_mode=r")
  IF "!ERRORLEVEL!"=="2" (SET "sh_mode=s")
  IF "!ERRORLEVEL!"=="3" (SET "sh_mode=h")
 
  ECHO:

)

TASKLIST /FI "IMAGENAME eq Steam.exe" 2>NUL | find /I /N "Steam.exe">NUL
IF "%ERRORLEVEL%"=="1" (

  ECHO Starting Steam in !st_delay! seconds
  TIMEOUT /t !st_delay! /nobreak

  ECHO:
  ECHO Starting Steam

  START steam://

  ECHO Steam launched
  
  REM Let's wait 15 seconds before starting the shutdown loop. (if steam updates, that doesn't matter as it will still be using disk/network)
  TIMEOUT /t 15 /nobreak

)

If "%sh_delay_active%" EQU "y" (
  
  IF NOT "!smart_shutdown_enabled!" EQU "y" (
    ECHO Starting Shutdown delay with mode %sh_mode%

    TIMEOUT /t !sh_delay! /nobreak

    ECHO Preparing to shutdown... if you wish to stop this, press WINDOWS KEY, type 'shutdown /a' then press ENTER
    ECHO Shutting down...

    IF "!sh_mode!"=="h" (SHUTDOWN /!sh_mode!
    )ELSE (SHUTDOWN /!sh_mode! /t 120)
    PAUSE
    EXIT
  )
)

SET \A shutdown_attempts=0

IF "%sh_delay_active%" EQU "y" (

  IF "!smart_shutdown_enabled!" EQU "y" (

    ECHO Waiting for Steam to cease activity before shutting down

    :start_loop
    FOR /f "tokens=2 delims=," %%c in ('typeperf "\Process(Steam)\IO Data Operations/sec" -si 1 -sc 1 ^| find /V "\\"') do (
	
      IF %%c EQU "0.000000%" (

        SET /a shutdown_attempts=!shutdown_attempts!+1 

      ) ELSE (

        SET /a shutdown_attempts=0

      )  

      PING www.google.com -n 1 -w 1000 > NUL
      IF "!ERRORLEVEL!"=="1" (SET internet_connected="false") else (SET internet_connected="true")

      IF "!internet_connected!"=="false" (SET /a shutdown_attempts=0)

      IF !shutdown_attempts!==10 GOTO :end_loop

      GOTO :start_loop
  
      :end_loop
      ECHO Preparing to shutdown... if you wish to stop this, press WINDOWS KEY, type 'shutdown /a' then press ENTER
      ECHO Shutting down...

      IF "!sh_mode!"=="h" (SHUTDOWN /!sh_mode!
      )ELSE (SHUTDOWN /!sh_mode! /t 120)
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
