cmake_minimum_required(VERSION 3.20)
project(hdf5_fortran_smoke LANGUAGES C Fortran)

find_package(HDF5 CONFIG REQUIRED COMPONENTS Fortran shared)

if (NOT DEFINED HDF5_FORTRAN_SHARED_LIBRARY)
  message(FATAL_ERROR "HDF5_FORTRAN_SHARED_LIBRARY was not exported by the installed HDF5 package.")
endif ()

add_executable(hdf5_fortran_smoke hdf5_fortran_smoke.f90)
target_link_libraries(hdf5_fortran_smoke PRIVATE ${HDF5_FORTRAN_SHARED_LIBRARY})

if (DEFINED HDF5_INCLUDE_DIR)
  target_include_directories(hdf5_fortran_smoke PRIVATE ${HDF5_INCLUDE_DIR})
endif ()
if (DEFINED HDF5_INCLUDE_DIR_FORTRAN)
  target_include_directories(hdf5_fortran_smoke PRIVATE ${HDF5_INCLUDE_DIR_FORTRAN})
endif ()
