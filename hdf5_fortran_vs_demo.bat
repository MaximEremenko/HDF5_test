@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"

set "SRC_DIR=%ROOT_DIR%\hdf5"
set "DEMO_SRC=%ROOT_DIR%\fortran_demo"
set "BUILD_DIR=%ROOT_DIR%\build_x64_VS2022"
set "INSTALL_DIR=%ROOT_DIR%\bin_x64_VS2022"
set "DEMO_BUILD=%ROOT_DIR%\build_demo_x64_VS2022"
set "PROJECT_DIR=%ROOT_DIR%\project"
set "PROJECT_BIN=%PROJECT_DIR%\bin"
set "PROJECT_LIB=%PROJECT_DIR%\lib"

echo [1/8] Loading Intel oneAPI environment...
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64
if errorlevel 1 (
  echo ERROR: failed to initialize Intel oneAPI environment.
  exit /b 1
)
where ifx >nul 2>&1
if errorlevel 1 (
  echo ERROR: ifx compiler not found after setvars.bat.
  exit /b 1
)

echo [2/8] Checking sources...
if not exist "%SRC_DIR%\CMakeLists.txt" (
  echo ERROR: HDF5 source tree not found at "%SRC_DIR%".
  exit /b 1
)
if not exist "%DEMO_SRC%\CMakeLists.txt" (
  echo ERROR: demo source tree not found at "%DEMO_SRC%".
  exit /b 1
)

echo [3/8] Cleaning build and install folders...
if exist "%BUILD_DIR%" rmdir /S /Q "%BUILD_DIR%"
if exist "%INSTALL_DIR%" rmdir /S /Q "%INSTALL_DIR%"
if exist "%DEMO_BUILD%" rmdir /S /Q "%DEMO_BUILD%"
if exist "%PROJECT_DIR%" rmdir /S /Q "%PROJECT_DIR%"
mkdir "%INSTALL_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%DEMO_BUILD%"
mkdir "%PROJECT_DIR%"
mkdir "%PROJECT_BIN%"
mkdir "%PROJECT_LIB%"

echo [4/8] Configuring HDF5 with VS2022 and ifx...
pushd "%BUILD_DIR%" >nul
cmake "%SRC_DIR%" -G "Visual Studio 17 2022" -A x64 -T "fortran=ifx" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" ^
  -DHDF5_BUILD_FORTRAN=ON ^
  -DHDF5_BUILD_HL_LIB=ON ^
  -DHDF5_BUILD_CPP_LIB=OFF ^
  -DHDF5_BUILD_JAVA=OFF ^
  -DHDF5_BUILD_TOOLS=OFF ^
  -DHDF5_BUILD_EXAMPLES=OFF ^
  -DBUILD_TESTING=OFF ^
  -DHDF5_ENABLE_ZLIB_SUPPORT=OFF ^
  -DHDF5_ENABLE_SZIP_SUPPORT=OFF ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
if errorlevel 1 (
  popd >nul
  echo ERROR: CMake configure failed.
  exit /b 1
)

echo [5/8] Building package and install targets...
cmake --build . --config Release --target package
if errorlevel 1 (
  popd >nul
  echo ERROR: package target failed.
  exit /b 1
)
cmake --build . --config Release --target clean_cpack >nul 2>&1
cmake --build . --config Release --target install
if errorlevel 1 (
  popd >nul
  echo ERROR: install target failed.
  exit /b 1
)
popd >nul

echo [6/8] Configuring and building Fortran smoke test...
cmake -S "%DEMO_SRC%" -B "%DEMO_BUILD%" -G "Visual Studio 17 2022" -A x64 -T "fortran=ifx" ^
  -DCMAKE_PREFIX_PATH="%INSTALL_DIR%"
if errorlevel 1 (
  echo ERROR: smoke-test configure failed.
  exit /b 1
)
cmake --build "%DEMO_BUILD%" --config Release
if errorlevel 1 (
  echo ERROR: smoke-test build failed.
  exit /b 1
)

echo [7/8] Running smoke test...
if exist "%DEMO_BUILD%\project\bin" (
  set "PATH=%DEMO_BUILD%\project\bin;%INSTALL_DIR%\bin;%PATH%"
) else (
  set "PATH=%INSTALL_DIR%\bin;%PATH%"
)
set "SMOKE_EXE="
for %%F in (
  "%DEMO_BUILD%\project\bin\hdf5_fortran_smoke.exe"
  "%DEMO_BUILD%\project\bin\Release\hdf5_fortran_smoke.exe"
  "%DEMO_BUILD%\project\Release\hdf5_fortran_smoke.exe"
  "%DEMO_BUILD%\Release\hdf5_fortran_smoke.exe"
  "%DEMO_BUILD%\hdf5_fortran_smoke.exe"
) do (
  if not defined SMOKE_EXE if exist "%%~fF" set "SMOKE_EXE=%%~fF"
)
if not defined SMOKE_EXE (
  echo ERROR: smoke-test executable not found.
  exit /b 1
)
pushd "%DEMO_BUILD%" >nul
"%SMOKE_EXE%"
set "SMOKE_RC=%ERRORLEVEL%"
popd >nul
if not "%SMOKE_RC%"=="0" (
  echo ERROR: smoke test failed with exit code %SMOKE_RC%.
  exit /b %SMOKE_RC%
)

echo [8/8] Creating deploy folder with exe and DLLs...
if not defined SMOKE_EXE (
  echo ERROR: smoke-test executable not found.
  exit /b 1
)

copy /Y "%SMOKE_EXE%" "%PROJECT_BIN%\hdf5_fortran_smoke.exe" >nul
if errorlevel 1 (
  echo ERROR: failed to copy smoke-test executable.
  exit /b 1
)

if exist "%DEMO_BUILD%\project\bin\*.dll" copy /Y "%DEMO_BUILD%\project\bin\*.dll" "%PROJECT_BIN%\" >nul
if exist "%DEMO_BUILD%\project\bin\Release\*.dll" copy /Y "%DEMO_BUILD%\project\bin\Release\*.dll" "%PROJECT_BIN%\" >nul
if exist "%DEMO_BUILD%\project\Release\*.dll" copy /Y "%DEMO_BUILD%\project\Release\*.dll" "%PROJECT_BIN%\" >nul
if exist "%DEMO_BUILD%\Release\*.dll" copy /Y "%DEMO_BUILD%\Release\*.dll" "%PROJECT_BIN%\" >nul
if exist "%DEMO_BUILD%\*.dll" copy /Y "%DEMO_BUILD%\*.dll" "%PROJECT_BIN%\" >nul

if exist "%INSTALL_DIR%\bin\*.dll" (
  copy /Y "%INSTALL_DIR%\bin\*.dll" "%PROJECT_BIN%\" >nul
)
if exist "%INSTALL_DIR%\lib\*.dll" (
  copy /Y "%INSTALL_DIR%\lib\*.dll" "%PROJECT_BIN%\" >nul
)
if exist "%INSTALL_DIR%\lib\*.lib" (
  copy /Y "%INSTALL_DIR%\lib\*.lib" "%PROJECT_LIB%\" >nul
)
if exist "%INSTALL_DIR%\lib\*.a" (
  copy /Y "%INSTALL_DIR%\lib\*.a" "%PROJECT_LIB%\" >nul
)

for %%D in (libifcoremd.dll libifportmd.dll libmmd.dll svml_dispmd.dll libiomp5md.dll) do (
  for /f "delims=" %%P in ('where %%D 2^>nul') do (
    if not exist "%PROJECT_BIN%\%%~nxP" copy /Y "%%P" "%PROJECT_BIN%\" >nul
  )
)

echo.
echo SUCCESS
echo HDF5 install: %INSTALL_DIR%
echo Demo output: %DEMO_BUILD%\fortran_demo.h5
echo Deploy exe: %PROJECT_BIN%\hdf5_fortran_smoke.exe
echo Deploy runtime DLLs: %PROJECT_BIN%
echo Deploy import/static libs: %PROJECT_LIB%
exit /b 0
