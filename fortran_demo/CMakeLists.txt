cmake_minimum_required(VERSION 3.20)
project(hdf5_fortran_smoke LANGUAGES C Fortran)

find_package(HDF5 CONFIG REQUIRED COMPONENTS Fortran shared)

if (NOT DEFINED HDF5_FORTRAN_SHARED_LIBRARY)
  message(FATAL_ERROR "HDF5_FORTRAN_SHARED_LIBRARY was not exported by the installed HDF5 package.")
endif ()

if (WIN32)
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/project/bin")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/project/bin")
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/project/lib")

  foreach(cfg Debug Release RelWithDebInfo MinSizeRel)
    string(TOUPPER "${cfg}" CFG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CFG} "${CMAKE_BINARY_DIR}/project/bin")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CFG} "${CMAKE_BINARY_DIR}/project/bin")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CFG} "${CMAKE_BINARY_DIR}/project/lib")
  endforeach()
endif ()

add_executable(hdf5_fortran_smoke hdf5_fortran_smoke.f90)
target_link_libraries(hdf5_fortran_smoke PRIVATE ${HDF5_FORTRAN_SHARED_LIBRARY})

if (DEFINED HDF5_INCLUDE_DIR)
  target_include_directories(hdf5_fortran_smoke PRIVATE ${HDF5_INCLUDE_DIR})
endif ()
if (DEFINED HDF5_INCLUDE_DIR_FORTRAN)
  target_include_directories(hdf5_fortran_smoke PRIVATE ${HDF5_INCLUDE_DIR_FORTRAN})
endif ()

if (WIN32)
  add_custom_command(TARGET hdf5_fortran_smoke POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:hdf5_fortran_smoke> "$<TARGET_FILE_DIR:hdf5_fortran_smoke>"
    COMMAND_EXPAND_LISTS
  )
endif ()
