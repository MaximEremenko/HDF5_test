# HDF5 Fortran on Windows (VS2022 + ifx) Demo

This project demonstrates how to build and package HDF5 with Fortran bindings on Windows using Visual Studio 2022 tools and Intel `ifx`.

## Goal

Answer to:

`Do you know how to install the HDF5 library including Fortran bindings on Windows?`

Yes. This repo provides a one-click batch script that:

1. Loads Intel oneAPI environment (`ifx`).
2. Configures HDF5 with `-G "Visual Studio 17 2022" -T "fortran=ifx"`.
3. Builds package/install targets.
4. Builds and runs a Fortran smoke test linked against installed HDF5.

## Prerequisites

Install these first:

1. Visual Studio 2022 with C++ build tools.
2. Intel oneAPI HPC Toolkit (Fortran `ifx`).
3. CMake (available in `PATH`).

Expected source layout:

1. `hdf5/` (HDF5 source tree)
2. `fortran_demo/` (smoke test CMake project)
3. `hdf5_fortran_vs_demo.bat`

## Clone with submodules

Clone this repo and fetch `hdf5` submodule in one step:

```bat
git clone --recurse-submodules https://github.com/MaximEremenko/HDF5_test.git
cd HDF5_test
```

If you already cloned without submodules:

```bat
git submodule update --init --recursive
```

## One-click run

From the repository root (for example, `c:\Projects\HDF5_test`):

```bat
hdf5_fortran_vs_demo.bat
```

Main output folders:

1. `build_x64_VS2022`
2. `bin_x64_VS2022`
3. `build_demo_x64_VS2022`
4. `project`

If successful, the demo creates:

1. `build_demo_x64_VS2022\fortran_demo.h5`
2. `project\bin\hdf5_fortran_smoke.exe` (Fortran app)
3. `project\bin\*.dll` (runtime DLLs for direct launch)
4. `project\lib\*.lib` and `project\lib\*.a` (import/static libraries)

Run deployed exe:

```bat
project\bin\hdf5_fortran_smoke.exe
```

## Manual command sequence

The batch script uses this flow:

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
   Run `call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64` and verify `where ifx`.
2. CMake generator/toolset error:
   Ensure Visual Studio 2022 is installed and supports C++ tools.
3. MSBuild `MSB3061` access denied in `VCTargetsPath`:
   Close processes that may lock build files (indexers, antivirus, IDE background scans), delete build folder, rerun.
