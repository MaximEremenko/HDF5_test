# HDF5 Fortran on Windows (VS2022 + ifx)

## Overview

This repository automates building HDF5 with Fortran bindings on Windows and verifies the installation with a Fortran smoke test.

The script `hdf5_fortran_vs_demo.bat` performs:

1. Intel oneAPI environment initialization (`ifx`).
2. HDF5 configure/build/install with `Visual Studio 2022` and `fortran=ifx`.
3. Fortran smoke test configure/build/run.
4. Deployment of runtime files and libraries to a standard Windows layout.

## Requirements

1. Visual Studio 2022 with C/C++ build tools.
2. Intel oneAPI HPC Toolkit (Fortran `ifx`).
3. CMake available in `PATH`.

## Repository Layout

1. `hdf5/`: HDF5 source submodule.
2. `fortran_demo/`: Fortran smoke-test project.
3. `hdf5_fortran_vs_demo.bat`: automation script.

## Clone

```bat
git clone --recurse-submodules https://github.com/MaximEremenko/HDF5_test.git
cd HDF5_test
```

If cloned without submodules:

```bat
git submodule update --init --recursive
```

## Build and Validate

Run from the repository root:

```bat
hdf5_fortran_vs_demo.bat
```

## Output Artifacts

After a successful run:

1. `build_demo_x64_VS2022\fortran_demo.h5`
2. `project\bin\hdf5_fortran_smoke.exe`
3. `project\bin\*.dll` (runtime DLLs)
4. `project\lib\*.lib` and `project\lib\*.a` (import/static libraries)

Run the deployed executable:

```bat
project\bin\hdf5_fortran_smoke.exe
```

## Manual HDF5 Configure/Build/Install

```bat
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64

set BUILD_DIR=build_x64_VS2022
set INSTALL_DIR=bin_x64_VS2022
rmdir /S /Q %BUILD_DIR%
rmdir /S /Q %INSTALL_DIR%
mkdir %INSTALL_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake ../hdf5 -G "Visual Studio 17 2022" -A x64 -T "fortran=ifx" ^
  -DCMAKE_INSTALL_PREFIX=../%INSTALL_DIR% ^
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

cmake --build . --config Release --target package
cmake --build . --config Release --target clean_cpack
cmake --build . --config Release --target install
cd ..
```

## Troubleshooting

1. `ifx` not found:
   Run `call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64`, then `where ifx`.
2. Generator/toolset errors:
   Confirm Visual Studio 2022 and C/C++ build tools are installed.
3. `MSB3061` or file access/lock errors:
   Close tools that may lock build files, delete build folders, and rerun.
