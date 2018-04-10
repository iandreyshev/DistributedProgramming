@ECHO OFF

IF "%~1"=="" (
  GOTO InvalidArgs
)
IF "%~2"=="" (
  GOTO InvalidArgs
)
IF "%~3"=="" (
  GOTO InvalidArgs
)

SET BUILD_DIR=v%~1.%~2.%~3
SET CONFIG_DIR=config
SET CONFIG_EXT=json

SET BACKEND_NAME=backend
SET BACKEND_SRC=src\%BACKEND_NAME%
SET BACKEND_CONFIG=%BACKEND_SRC%\config.%CONFIG_EXT%
SET BACKEND_OUT=%BUILD_DIR%\%BACKEND_NAME%
SET BACKEND_OUT_FROM_PROJ=..\..\%BACKEND_OUT%
SET BACKEND_WINDOW_NAME=%BACKEND_NAME% %BUILD_DIR%

SET FRONTEND_NAME=frontend
SET FRONTEND_SRC=src\%FRONTEND_NAME%
SET FRONTEND_CONFIG=%FRONTEND_SRC%\config.%CONFIG_EXT%
SET FRONTEND_OUT=%BUILD_DIR%\%FRONTEND_NAME%
SET FRONTEND_OUT_FROM_PROJ=..\..\%FRONTEND_OUT%
SET FRONTEND_WINDOW_NAME=%FRONTEND_NAME% %BUILD_DIR%

SET TEXT_LISTENER_NAME=textListener
SET TEXT_LISTENER_SRC=src\%TEXT_LISTENER_NAME%
SET TEXT_LISTENER_OUT=%BUILD_DIR%\%TEXT_LISTENER_NAME%
SET TEXT_LISTENER_OUT_FROM_PROJ=..\..\%TEXT_LISTENER_OUT%

CALL :Clear

CALL :Build
IF %ERRORLEVEL% NEQ 0 GOTO BuildError

CALL :CopyConfig
CALL :CreateRunScript
CALL :CreateStopScript

ECHO Build completed!
EXIT /B 0

:Clear
  IF EXIST %BUILD_DIR% RD /s /q "%BUILD_DIR%"
  EXIT /B 0

:Build
  dotnet publish %BACKEND_SRC% -c Release -o %BACKEND_OUT_FROM_PROJ%
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
  dotnet publish %FRONTEND_SRC% -c Release -o %FRONTEND_OUT_FROM_PROJ%
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
  dotnet build %TEXT_LISTENER_SRC% -o %TEXT_LISTENER_OUT_FROM_PROJ%
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
  EXIT /B 0
  
:CopyConfig
  MD "%BUILD_DIR%\%CONFIG_DIR%"
  COPY "%BACKEND_CONFIG%" "%BUILD_DIR%\%CONFIG_DIR%\%BACKEND_NAME%.%CONFIG_EXT%"
  COPY "%FRONTEND_CONFIG%" "%BUILD_DIR%\%CONFIG_DIR%\%FRONTEND_NAME%.%CONFIG_EXT%"
  EXIT /B 0s

:CreateRunScript
  (
    @ECHO copy "%CONFIG_DIR%\%BACKEND_NAME%.%CONFIG_EXT%" "%BACKEND_NAME%\config.%CONFIG_EXT%"
    @ECHO copy "%CONFIG_DIR%\%FRONTEND_NAME%.%CONFIG_EXT%" "%FRONTEND_NAME%\config.%CONFIG_EXT%"
    @ECHO start "%FRONTEND_WINDOW_NAME%" dotnet %FRONTEND_NAME%\%FRONTEND_NAME%.dll
    @ECHO start "%BACKEND_WINDOW_NAME%" dotnet %BACKEND_NAME%\%BACKEND_NAME%.dll
	@ECHO start "%TEXT_LISTENER_NAME%" dotnet %TEXT_LISTENER_NAME%\%TEXT_LISTENER_NAME%.dll
  ) > %BUILD_DIR%\run.cmd
  EXIT /B 0

:CreateStopScript
  (
    @ECHO @ECHO OFF
    @ECHO
    @ECHO taskkill /IM dotnet.exe
  ) > %BUILD_DIR%\stop.cmd
  EXIT /B 0

:InvalidArgs
  ECHO Invalid build version. Usage: build.cmd major minor patch
  EXIT /B 1

:BuildError
  ECHO Error during build project...
  EXIT /B 2